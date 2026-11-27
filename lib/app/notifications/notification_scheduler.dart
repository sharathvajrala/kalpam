/// Keeps the device's local notification schedule equal to the planner's
/// output. Re-plans on app open and resume (which also covers a timezone or
/// clock change), whenever app state changes (city, ritual done, checklist,
/// Settings), and when a pooja ends. While a pooja is active
/// (NotificationGate) every pending notification is cancelled.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../pooja_engine/pooja_session.dart';
import '../app_state.dart';
import 'notification_planner.dart';

/// Device side of notifications, so the scheduler is testable.
abstract class NotificationPort {
  Future<void> init(void Function(String payload) onTap);
  Future<void> replaceAll(List<PlannedNotification> list);
  Future<void> cancelAll();

  /// Asks for permission to show notifications (Android 13+, iOS).
  Future<bool> requestPermission();

  /// Android only: whether exact alarms are allowed (null elsewhere).
  Future<bool?> canScheduleExact();
  Future<void> requestExact();
}

/// Web previews and tests: remembers the schedule, shows nothing.
class MemoryNotificationPort implements NotificationPort {
  List<PlannedNotification> scheduled = [];
  int replaceCount = 0;
  @override
  Future<void> init(void Function(String payload) onTap) async {}
  @override
  Future<void> replaceAll(List<PlannedNotification> list) async {
    scheduled = [...list];
    replaceCount++;
  }

  @override
  Future<void> cancelAll() async => scheduled = [];
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<bool?> canScheduleExact() async => null;
  @override
  Future<void> requestExact() async {}
}

/// flutter_local_notifications on Android / iOS. Times are absolute UTC
/// instants computed from the user's city, so no timezone database is needed.
class LocalNotificationPort implements NotificationPort {
  final _plugin = FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init(void Function(String payload) onTap) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      ),
      onDidReceiveNotificationResponse: (r) => onTap(r.payload ?? 'today'),
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) onTap(launch!.notificationResponse?.payload ?? 'today');
  }

  static NotificationDetails _details(PlannedNotification n) {
    final (id, name) = switch (n.kind.type) {
      NotifType.subhodayam => ('subhodayam', 'Subhodayam'),
      NotifType.morningRitual || NotifType.eveningRitual => ('rituals', 'Daily rituals'),
      NotifType.festivals => ('festivals', 'Festivals'),
      NotifType.vratam => ('vratam', 'Mala and vratam'),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(id, name, styleInformation: BigTextStyleInformation(n.body)),
      iOS: DarwinNotificationDetails(threadIdentifier: id),
    );
  }

  @override
  Future<void> replaceAll(List<PlannedNotification> list) async {
    await _plugin.cancelAllPendingNotifications();
    final exact = await canScheduleExact() ?? false;
    for (final n in list) {
      await _plugin.zonedSchedule(
        id: n.id,
        scheduledDate: tz.TZDateTime.from(n.at, tz.UTC),
        notificationDetails: _details(n),
        androidScheduleMode: exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
        title: n.title,
        body: n.body,
        payload: n.payload,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAllPendingNotifications();

  @override
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) return await _android?.requestNotificationsPermission() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<bool?> canScheduleExact() async =>
      defaultTargetPlatform == TargetPlatform.android ? await _android?.canScheduleExactNotifications() : null;

  @override
  Future<void> requestExact() async => _android?.requestExactAlarmsPermission();
}

class NotificationScheduler {
  NotificationScheduler(this.app, this.port, {this.debounce = const Duration(milliseconds: 400)});

  /// The running scheduler (Settings reads [upcoming] and the port from it).
  static NotificationScheduler? instance;

  final AppState app;
  final NotificationPort port;
  final Duration debounce;

  /// The schedule as last sent to the device (empty while a pooja runs).
  final upcoming = ValueNotifier<List<PlannedNotification>>(const []);

  /// Notification taps, by payload (the app routes them).
  void Function(String payload)? onTap;

  String? _signature;
  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  Future<void> start() async {
    instance = this;
    await port.init((p) => onTap?.call(p));
    app.addListener(_changed);
    NotificationGate.poojaActive.addListener(refresh);
    _lifecycle = AppLifecycleListener(onResume: refresh);
    await refresh();
  }

  void dispose() {
    _timer?.cancel();
    app.removeListener(_changed);
    NotificationGate.poojaActive.removeListener(refresh);
    _lifecycle?.dispose();
    if (identical(instance, this)) instance = null;
  }

  void _changed() {
    _timer?.cancel();
    _timer = Timer(debounce, refresh);
  }

  /// Re-plans now. Unchanged plans are not re-sent to the device.
  Future<void> refresh() async {
    _timer?.cancel();
    if (NotificationGate.poojaActive.value) {
      if (_signature != '') {
        await port.cancelAll();
        _signature = '';
        upcoming.value = const [];
      }
      return;
    }
    if (app.onboarded && !app.notificationPrefs.permissionAsked) {
      // Asked once, after onboarding chose the reminder times.
      await app.setNotificationPrefs(app.notificationPrefs.copyWith(permissionAsked: true));
      await port.requestPermission();
    }
    final plan = NotificationPlanner(app).plan();
    final sig = plan.map((n) => n.signature).join('\n');
    if (sig == _signature) return;
    _signature = sig;
    await port.replaceAll(plan);
    upcoming.value = plan;
  }
}
