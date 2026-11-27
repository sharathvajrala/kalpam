import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/panchangam/names.dart';
import '../../core/profile/family_profile.dart';

/// Name + gotram (required) and janma nakshatram (optional) — the complete,
/// approved set of personal fields. Used in onboarding and family profiles.
class ProfileFields extends StatelessWidget {
  const ProfileFields({
    super.key,
    required this.name,
    required this.gotra,
    required this.nakshatra,
    required this.onNakshatra,
    this.onChanged,
  });
  final TextEditingController name, gotra;
  final int? nakshatra;
  final ValueChanged<int?> onNakshatra;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextField(
        key: const ValueKey('field-name'),
        controller: name,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => onChanged?.call(),
        decoration: InputDecoration(labelText: '${l.yourName} *', border: const OutlineInputBorder()),
      ),
      const SizedBox(height: 14),
      TextField(
        key: const ValueKey('field-gotra'),
        controller: gotra,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => onChanged?.call(),
        decoration: InputDecoration(labelText: '${l.gotra} *', helperText: l.gotraHelp, border: const OutlineInputBorder()),
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<int?>(
        key: const ValueKey('field-nakshatra'),
        initialValue: nakshatra,
        isExpanded: true,
        decoration: InputDecoration(labelText: '${l.janmaNakshatram} (${l.optional})', border: const OutlineInputBorder()),
        items: [
          DropdownMenuItem<int?>(value: null, child: Text(l.notSet)),
          for (var i = 0; i < 27; i++)
            DropdownMenuItem<int?>(value: i + 1, child: Text('${context.t(nakshatraNames[i])} · ${context.t2(nakshatraNames[i])}')),
        ],
        onChanged: onNakshatra,
      ),
    ]);
  }
}

/// Morning + evening reminder time rows.
class ReminderFields extends StatelessWidget {
  const ReminderFields({super.key, required this.morning, required this.evening, required this.onMorning, required this.onEvening});
  final ReminderTime morning, evening;
  final ValueChanged<ReminderTime> onMorning, onEvening;

  @override
  Widget build(BuildContext context) {
    Future<void> pick(ReminderTime current, ValueChanged<ReminderTime> done) async {
      final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: current.hour, minute: current.minute));
      if (t != null) done(ReminderTime(t.hour, t.minute));
    }

    Widget row(Key key, IconData icon, String Function(dynamic) label, ReminderTime v, ValueChanged<ReminderTime> on) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GoldCard(
            key: key,
            onTap: () => pick(v, on),
            child: Row(children: [
              Icon(icon, color: K.saffron),
              const SizedBox(width: 12),
              Expanded(child: Bi((l) => label(l), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: K.maroon))),
              Text(v.display, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined, size: 18, color: K.gold),
            ]),
          ),
        );
    return Column(children: [
      row(const ValueKey('remind-morning'), Icons.wb_twilight, (l) => l.morningReminder, morning, onMorning),
      row(const ValueKey('remind-evening'), Icons.nights_stay_outlined, (l) => l.eveningReminder, evening, onEvening),
    ]);
  }
}
