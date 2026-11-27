import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/content/models.dart';
import '../../core/profile/family_profile.dart';

/// Joining a mala / vratam: how many days (the pack's standard count
/// prefilled, editable 1-90), the start date, and the daily check-in time.
/// Returns true when the Sankalpam was begun.
Future<bool> showJoinVratamSheet(BuildContext context, VratamPack vratam, {DateTime? suggestedStart}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: K.ivory,
    showDragHandle: true,
    builder: (_) => JoinVratamSheet(vratam: vratam, suggestedStart: suggestedStart),
  );
  return ok ?? false;
}

class JoinVratamSheet extends StatefulWidget {
  const JoinVratamSheet({super.key, required this.vratam, this.suggestedStart});
  final VratamPack vratam;
  final DateTime? suggestedStart;

  static const minDays = 1, maxDays = 90;

  @override
  State<JoinVratamSheet> createState() => _JoinVratamSheetState();
}

class _JoinVratamSheetState extends State<JoinVratamSheet> {
  late int _days = widget.vratam.defaultDays.clamp(JoinVratamSheet.minDays, JoinVratamSheet.maxDays);
  late DateTime _start = widget.suggestedStart ?? AppScope.read(context).today;
  late ReminderTime _time = AppScope.read(context).morningReminder ?? const ReminderTime(5, 30);

  int get _min => widget.vratam.minDays.clamp(JoinVratamSheet.minDays, JoinVratamSheet.maxDays);
  int get _max => widget.vratam.maxDays.clamp(_min, JoinVratamSheet.maxDays);

  void _set(int d) => setState(() => _days = d.clamp(_min, _max));

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l = context.l;
    final tt = Theme.of(context).textTheme;
    final standard = widget.vratam.defaultDays;
    final presets = {standard, 11, 21, 41, 48}.where((d) => d >= _min && d <= _max).toList()..sort();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BiL(widget.vratam.name, style: tt.titleLarge?.copyWith(color: K.maroon)),
          const SizedBox(height: 16),
          Bi((l) => l.joinDaysTitle, style: tt.titleMedium),
          const SizedBox(height: 4),
          Text(l.joinDaysStandard(standard), style: tt.bodySmall?.copyWith(color: K.inkSoft)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton.outlined(
              key: const Key('join-days-minus'),
              tooltip: '−',
              onPressed: _days > _min ? () => _set(_days - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: Column(children: [
                Text('$_days', key: const Key('join-days'), style: tt.displaySmall?.copyWith(color: K.maroon, fontWeight: FontWeight.w700)),
                Text(l.nDays(_days).replaceFirst('$_days ', ''), style: tt.labelMedium),
              ]),
            ),
            const SizedBox(width: 16),
            IconButton.outlined(
              key: const Key('join-days-plus'),
              tooltip: '+',
              onPressed: _days < _max ? () => _set(_days + 1) : null,
              icon: const Icon(Icons.add),
            ),
          ]),
          Slider(
            key: const Key('join-days-slider'),
            value: _days.toDouble(),
            min: _min.toDouble(),
            max: _max.toDouble(),
            divisions: _max > _min ? _max - _min : null,
            activeColor: K.maroon,
            onChanged: (v) => _set(v.round()),
          ),
          Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [
            for (final d in presets)
              ChoiceChip(
                key: Key('join-days-$d'),
                selected: _days == d,
                onSelected: (_) => _set(d),
                label: Text(l.nDays(d)),
              ),
          ]),
          const SizedBox(height: 12),
          GoldCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              ListTile(
                key: const Key('join-start'),
                leading: const Icon(Icons.event_outlined, color: K.maroon),
                title: Bi((l) => l.startsOn, style: tt.titleSmall),
                trailing: Text(fmtDate(context, _start), style: tt.labelLarge),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _start,
                    firstDate: app.today.subtract(const Duration(days: 60)),
                    lastDate: app.today.add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => _start = DateTime.utc(d.year, d.month, d.day));
                },
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('join-time'),
                leading: const Icon(Icons.notifications_active_outlined, color: K.maroon),
                title: Bi((l) => l.checkInTime, style: tt.titleSmall),
                trailing: Text(_time.display, style: tt.labelLarge),
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute));
                  if (t != null) setState(() => _time = ReminderTime(t.hour, t.minute));
                },
              ),
            ]),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('join-begin'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: () async {
              await app.startDeeksha(widget.vratam.id, _start, _days, reminder: _time);
              if (context.mounted) Navigator.pop(context, true);
            },
            child: Bi((l) => l.beginSankalpam, style: tt.titleMedium?.copyWith(color: Colors.white), secondaryColor: Colors.white70, align: CrossAxisAlignment.center),
          ),
        ]),
      ),
    );
  }
}
