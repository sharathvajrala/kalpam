import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../l10n/gen/app_localizations.dart';
import 'ritual_screen.dart';

/// Today home: the morning and evening rituals with today's done-state.
/// The streak lives here (and in trackers), never inside the sanctum.
class RitualsCard extends StatelessWidget {
  const RitualsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    final p = app.panchang;
    final streak = app.ritualStreak(RitualSlot.morning);
    return GoldCard(
      key: const ValueKey('rituals-card'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Bi((l) => l.dailyRituals, style: tt.labelLarge?.copyWith(color: K.gold))),
          if (streak > 1) Text(context.l.streak(streak), style: tt.labelMedium?.copyWith(color: K.success)),
        ]),
        const SizedBox(height: 6),
        _RitualRow(
          slot: RitualSlot.morning,
          icon: Icons.wb_sunny_outlined,
          title: (l) => l.morningRitual,
          when: context.l.atSunrise(fmtTime(context, p.sunrise)),
        ),
        const Divider(height: 1),
        _RitualRow(
          slot: RitualSlot.evening,
          icon: Icons.light_outlined,
          title: (l) => l.eveningRitual,
          when: context.l.atSunset(fmtTime(context, p.sunset)),
        ),
        if (!app.ritualDone(RitualSlot.morning)) ...[
          const SizedBox(height: 4),
          const ArchanaFormChips(slot: RitualSlot.morning),
          const SizedBox(height: 6),
        ],
      ]),
    );
  }
}

class _RitualRow extends StatelessWidget {
  const _RitualRow({required this.slot, required this.icon, required this.title, required this.when});
  final RitualSlot slot;
  final IconData icon;
  final String Function(AppLocalizations) title;
  final String when;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    final done = app.ritualDone(slot);
    return InkWell(
      key: ValueKey('ritual-${slot.name}'),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RitualScreen(slot: slot))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: done ? K.success.withValues(alpha: 0.15) : K.ivoryDeep,
            child: Icon(done ? Icons.check : icon, color: done ? K.success : K.maroon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Bi(title, style: tt.titleSmall),
              const SizedBox(height: 2),
              Text(done ? context.l.doneToday : when, style: tt.bodySmall?.copyWith(color: done ? K.success : K.inkSoft)),
            ]),
          ),
          // Elder Mode: the whole row is the button (large text leaves no
          // room for a second one beside it).
          if (!done && !app.elderMode)
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RitualScreen(slot: slot))),
              style: FilledButton.styleFrom(backgroundColor: K.goldSoft, foregroundColor: K.maroonDeep),
              child: Bi((l) => l.begin, style: tt.labelLarge, align: CrossAxisAlignment.center),
            ),
          if (!done && app.elderMode) const Icon(Icons.chevron_right, size: 32, color: K.maroon),
        ]),
      ),
    );
  }
}
