import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/app/notifications/notification_scheduler.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/features/settings/settings_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<AppState> boot(WidgetTester t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    SharedPreferences.setMockInitialValues({
      'onboarded': true, 'lang': 'en', 'deity': 'ayyappa', 'city': 'hyderabad',
      'remindMorning': '05:30', 'remindEvening': '18:30',
      'profiles': '[{"id":"p1","name":"Sharath","gotra":"Bharadwaja"}]', 'activeProfile': 'p1',
      'notifPrefs': '{"permissionAsked":true}',
    });
    final repo = await t.runAsync(() => PackRepository.load((p) => File(p).readAsString()));
    final fixed = DateTime.parse('2026-11-27T04:00:00+05:30');
    final state = AppState(repo: repo!, prefs: await SharedPreferences.getInstance(), clock: () => fixed);
    KalpamShell.tabIndex.value = 0;
    return state;
  }

  testWidgets('Join the Sankalpam asks the days (41 prefilled) and a check-in time', (t) async {
    final state = await boot(t);
    await t.pumpWidget(KalpamApp(state: state));
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(const ValueKey('hero-join')));
    await t.tap(find.byKey(const ValueKey('hero-join')));
    await t.pumpAndSettle();

    expect(find.text('How many days will you keep it?'), findsOneWidget);
    expect(find.text('The standard count is 41 days.'), findsOneWidget);
    expect((t.widget<Text>(find.byKey(const Key('join-days')))).data, '41');
    await t.tap(find.byKey(const Key('join-days-plus')));
    await t.pump();
    expect((t.widget<Text>(find.byKey(const Key('join-days')))).data, '42');
    await t.tap(find.byKey(const Key('join-days-21')));
    await t.pump();
    expect((t.widget<Text>(find.byKey(const Key('join-days')))).data, '21');
    expect(find.text('5:30 AM'), findsOneWidget, reason: 'check-in time prefilled from the morning reminder');

    await t.ensureVisible(find.byKey(const Key('join-begin')));
    await t.tap(find.byKey(const Key('join-begin')));
    await t.pumpAndSettle();
    final r = state.deekshas['ayyappa_mandala']!;
    expect(r.totalDays, 21);
    expect(r.reminder, '05:30');
    expect(r.startDate, state.today);
  });

  testWidgets('Settings: notification toggles, Subhodayam time, quiet hours, coming up', (t) async {
    final state = await boot(t);
    final scheduler = NotificationScheduler(state, MemoryNotificationPort(), debounce: Duration.zero);
    await t.runAsync(scheduler.start);
    addTearDown(scheduler.dispose);
    await t.pumpWidget(KalpamApp(state: state));
    await t.pumpAndSettle();
    final nav = KalpamApp.navigatorKey.currentState!;
    nav.push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    await t.pumpAndSettle();

    final settingsList = find.descendant(of: find.byType(SettingsScreen), matching: find.byType(Scrollable)).first;
    await t.scrollUntilVisible(find.byKey(const ValueKey('notif-festivals')), 300, scrollable: settingsList);
    await t.ensureVisible(find.byKey(const ValueKey('notif-festivals')));
    await t.pumpAndSettle();
    expect(find.text('Subhodayam Panchangam at sunrise'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('notif-festivals')));
    await t.pumpAndSettle();
    expect(state.notificationPrefs.enabled(NotifType.festivals), isFalse);

    await t.ensureVisible(find.byKey(const ValueKey('sunrise-offset-30')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('sunrise-offset-30')));
    await t.pumpAndSettle();
    expect(state.notificationPrefs.sunriseOffsetMin, 30);
    expect(find.text('10:00 PM'), findsOneWidget, reason: 'quiet hours from');

    await t.runAsync(scheduler.refresh);
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('Coming up'), 200, scrollable: settingsList);
    expect(find.text('Sandhya time'), findsWidgets);
  });
}
