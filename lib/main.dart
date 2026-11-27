import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'app/notifications/notification_routes.dart';
import 'app/notifications/notification_scheduler.dart';
import 'core/content/pack_repository.dart';
import 'features/sannidhanam/pooja_screen.dart';

/// Optional fixed date for demos / screenshots:
/// `flutter run --dart-define=KALPAM_NOW=2026-12-20T07:30:00+05:30`
const _fixedNow = String.fromEnvironment('KALPAM_NOW');

/// Demo recordings only: speeds up Watch Mode (`--dart-define=KALPAM_DEMO_SPEED=6`).
const _demoSpeed = int.fromEnvironment('KALPAM_DEMO_SPEED', defaultValue: 1);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PoojaScreen.debugTimeScale = 1 / _demoSpeed;
  final repo = await PackRepository.load(rootBundle.loadString);
  final prefs = await SharedPreferences.getInstance();
  final fixed = _fixedNow.isEmpty ? null : DateTime.parse(_fixedNow);
  final state = AppState(repo: repo, prefs: prefs, clock: fixed == null ? null : () => fixed);
  // Local notifications: real scheduling on phones; web previews keep the
  // plan in memory (Settings shows it under "Coming up").
  final scheduler = NotificationScheduler(state, kIsWeb ? MemoryNotificationPort() : LocalNotificationPort())
    ..onTap = (payload) => openNotificationPayload(state, payload);
  runApp(KalpamApp(state: state));
  unawaited(scheduler.start());
}
