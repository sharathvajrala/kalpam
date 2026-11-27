import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/notifications/notification_planner.dart';
import '../../app/notifications/notification_scheduler.dart';
import '../../app/theme.dart';
import '../../core/profile/family_profile.dart';
import '../../core/tracker/deeksha_tracker.dart';
import '../../l10n/gen/app_localizations.dart';

/// Settings → Notifications: one switch per type, the Subhodayam time,
/// quiet hours, a one-time Android timing note, and what is coming up.
class NotificationsCard extends StatelessWidget {
  const NotificationsCard({super.key});

  static String Function(AppLocalizations) _label(NotifType t) => switch (t) {
        NotifType.subhodayam => (l) => l.nTypeSubhodayam,
        NotifType.morningRitual => (l) => l.nTypeMorning,
        NotifType.eveningRitual => (l) => l.nTypeEvening,
        NotifType.festivals => (l) => l.nTypeFestivals,
        NotifType.vratam => (l) => l.nTypeVratam,
      };

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final prefs = app.notificationPrefs;
    final l = context.l;
    final tt = Theme.of(context).textTheme;
    final scheduler = NotificationScheduler.instance;

    Future<void> pickTime(ReminderTime current, void Function(ReminderTime) done) async {
      final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: current.hour, minute: current.minute));
      if (t != null) done(ReminderTime(t.hour, t.minute));
    }

    return GoldCard(
      key: const ValueKey('notifications-card'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Bi((l) => l.notifications, style: tt.titleMedium?.copyWith(color: K.maroon)),
        const SizedBox(height: 4),
        Text(l.notificationsDesc, style: tt.bodySmall),
        const SizedBox(height: 4),
        for (final t in NotifType.values)
          SwitchListTile(
            key: ValueKey('notif-${t.name}'),
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: prefs.enabled(t),
            onChanged: (on) => app.setNotificationPrefs(prefs.toggled(t, on)),
            title: Bi(_label(t), style: tt.bodyLarge),
          ),
        const SizedBox(height: 8),
        Bi((l) => l.subhodayamTime, style: tt.titleSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 4, children: [
          for (final m in NotificationPrefs.offsetChoices)
            ChoiceChip(
              key: ValueKey('sunrise-offset-$m'),
              selected: prefs.sunriseOffsetMin == m,
              onSelected: prefs.enabled(NotifType.subhodayam) ? (_) => app.setNotificationPrefs(prefs.copyWith(sunriseOffsetMin: m)) : null,
              label: Text(m == 0 ? '${l.atSunriseShort} · ${fmtTime(context, app.panchang.sunrise)}' : l.minAfterSunrise(m)),
            ),
        ]),
        const SizedBox(height: 12),
        Bi((l) => l.quietHours, style: tt.titleSmall),
        Row(children: [
          Expanded(
            child: ListTile(
              key: const ValueKey('quiet-from'),
              contentPadding: EdgeInsets.zero,
              title: Text(l.fromTime, style: tt.labelMedium),
              subtitle: Text(prefs.quietFrom.display, style: tt.titleMedium),
              onTap: () => pickTime(prefs.quietFrom, (v) => app.setNotificationPrefs(prefs.copyWith(quietFrom: v))),
            ),
          ),
          Expanded(
            child: ListTile(
              key: const ValueKey('quiet-to'),
              contentPadding: EdgeInsets.zero,
              title: Text(l.toTime, style: tt.labelMedium),
              subtitle: Text(prefs.quietTo.display, style: tt.titleMedium),
              onTap: () => pickTime(prefs.quietTo, (v) => app.setNotificationPrefs(prefs.copyWith(quietTo: v))),
            ),
          ),
        ]),
        if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb && !prefs.exactExplained) ...[
          const SizedBox(height: 4),
          _ExactTimingNote(scheduler: scheduler),
        ],
        if (scheduler != null) ...[
          const SizedBox(height: 12),
          Bi((l) => l.comingUp, style: tt.titleSmall),
          const SizedBox(height: 4),
          ValueListenableBuilder<List<PlannedNotification>>(
            valueListenable: scheduler.upcoming,
            builder: (context, list, _) => list.isEmpty
                ? Text(l.nothingScheduled, style: tt.bodySmall?.copyWith(color: K.inkSoft))
                : Column(children: [for (final n in list.take(6)) _UpcomingRow(n)]),
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            key: const ValueKey('allow-notifications'),
            onPressed: () => scheduler.port.requestPermission(),
            icon: const Icon(Icons.notifications_outlined, color: K.maroon),
            label: Text(l.allowNotifications),
          ),
        ],
      ]),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow(this.n);
  final PlannedNotification n;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    final day = DeekshaRecord.civil(app.city.local(n.at));
    final when = day == app.today ? fmtTime(context, n.at) : '${fmtDate(context, day)} · ${fmtTime(context, n.at)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 118, child: Text(when, style: tt.labelMedium?.copyWith(color: K.gold))),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n.title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(n.body.split('\n').first, style: tt.bodySmall?.copyWith(color: K.inkSoft), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }
}

/// Shown once on Android: why exact timing and battery settings matter.
/// Never blocks the app; inexact timing is used without the permission.
class _ExactTimingNote extends StatelessWidget {
  const _ExactTimingNote({required this.scheduler});
  final NotificationScheduler? scheduler;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l = context.l;
    final tt = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('exact-note'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: K.ivoryDeep, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Bi((l) => l.exactTitle, style: tt.titleSmall?.copyWith(color: K.maroon)),
        const SizedBox(height: 4),
        Text(l.exactDesc, style: tt.bodySmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          if (scheduler != null)
            OutlinedButton(
              onPressed: () async {
                await scheduler!.port.requestExact();
                await scheduler!.refresh();
              },
              child: Text(l.allowExact),
            ),
          TextButton(
            onPressed: () => app.setNotificationPrefs(app.notificationPrefs.copyWith(exactExplained: true)),
            child: Text(l.gotIt),
          ),
        ]),
      ]),
    );
  }
}
