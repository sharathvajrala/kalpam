import 'package:material_ui/material_ui.dart';

import '../../core/rituals/daily_rituals.dart';
import '../../features/rituals/ritual_screen.dart';
import '../../features/vratam/vratam_screen.dart';
import '../app.dart';
import '../app_state.dart';

/// Opens the screen a notification points to. Every tap first returns to
/// Today; ritual and vratam payloads then open their screen on top.
void openNotificationPayload(AppState app, String payload) {
  final nav = KalpamApp.navigatorKey.currentState;
  if (nav == null || !app.onboarded) {
    // Not built yet (cold start from a notification): retry after a frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (KalpamApp.navigatorKey.currentState != null && app.onboarded) openNotificationPayload(app, payload);
    });
    return;
  }
  nav.popUntil((r) => r.isFirst);
  KalpamShell.go(0);
  final parts = payload.split(':');
  Widget? screen;
  switch (parts.first) {
    case 'ritual':
      screen = RitualScreen(slot: parts.length > 1 && parts[1] == 'evening' ? RitualSlot.evening : RitualSlot.morning);
    case 'vratam' || 'samagri':
      final id = parts.length > 1 ? parts[1] : '';
      if (app.repo.vratams.containsKey(id)) {
        final tab = parts.first == 'samagri'
            ? VratamTab.samagri
            : (parts.length > 2 && parts[2] == 'udyapanam' ? VratamTab.udyapanam : VratamTab.tracker);
        screen = VratamScreen(vratamId: id, initialTab: tab);
      }
  }
  if (screen != null) nav.push(MaterialPageRoute(builder: (_) => screen!));
}
