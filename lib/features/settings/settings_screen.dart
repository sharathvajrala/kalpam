import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/panchangam/names.dart';
import '../../core/profile/family_profile.dart';
import '../common/profile_form.dart';
import '../today/city_picker_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l = context.l;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Bi((l) => l.settings, style: tt.titleLarge)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        GoldCard(
          child: SwitchListTile(
            key: const ValueKey('elder-switch'),
            contentPadding: EdgeInsets.zero,
            value: app.elderMode,
            onChanged: app.setElderMode,
            title: Bi((l) => l.elderMode, style: tt.titleMedium?.copyWith(color: K.maroon)),
            subtitle: Text(l.elderModeDesc),
          ),
        ),
        const SizedBox(height: 12),
        GoldCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Bi((l) => l.language, style: tt.titleMedium?.copyWith(color: K.maroon)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'te', label: Text('తెలుగు')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {app.lang},
              onSelectionChanged: (s) => app.setLang(s.first),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined, color: K.maroon),
              title: Text(app.hasCity ? context.t(app.city.name) : l.cityNotSet),
              subtitle: Text(l.city),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CityPickerScreen())),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const _FamilyProfilesCard(),
        const SizedBox(height: 12),
        GoldCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Bi((l) => l.reminders, style: tt.titleMedium?.copyWith(color: K.maroon)),
            const SizedBox(height: 4),
            Text(l.remindersDesc, style: tt.bodySmall),
            const SizedBox(height: 12),
            ReminderFields(
              morning: app.morningReminder ?? const ReminderTime(5, 30),
              evening: app.eveningReminder ?? const ReminderTime(18, 30),
              onMorning: (v) => app.setReminders(morning: v),
              onEvening: (v) => app.setReminders(evening: v),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const _DataCard(),
        const SizedBox(height: 20),
        Center(child: Text('Kalpam 1.0.0 · ${l.tagline}', style: tt.bodySmall, textAlign: TextAlign.center)),
      ]),
    );
  }
}

class _FamilyProfilesCard extends StatelessWidget {
  const _FamilyProfilesCard();
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    return GoldCard(
      key: const ValueKey('family-profiles'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Bi((l) => l.familyProfiles, style: tt.titleMedium?.copyWith(color: K.maroon)),
        const SizedBox(height: 4),
        Text(context.l.familyProfilesDesc, style: tt.bodySmall),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: app.activeProfile?.id,
          onChanged: (id) => id == null ? null : app.switchProfile(id),
          child: Column(children: [
            for (final p in app.profiles)
              ListTile(
                key: ValueKey('profile-${p.id}'),
                contentPadding: EdgeInsets.zero,
                leading: Radio<String>(value: p.id),
                title: Text(p.name),
                subtitle: Text([
                  '${context.l.gotra}: ${p.gotra}',
                  if (p.janmaNakshatra != null) context.t(nakshatraNames[p.janmaNakshatra! - 1]),
                ].join(' · ')),
                onTap: () => app.switchProfile(p.id),
                trailing: IconButton(
                  tooltip: context.l.editProfile,
                  icon: const Icon(Icons.edit_outlined, color: K.gold),
                  onPressed: () => showProfileEditor(context, existing: p),
                ),
              ),
          ]),
        ),
        TextButton.icon(
          key: const ValueKey('add-profile'),
          onPressed: () => showProfileEditor(context),
          icon: const Icon(Icons.person_add_alt, color: K.maroon),
          label: Text(context.l.addProfile),
        ),
      ]),
    );
  }
}

/// Add / edit a family profile in a bottom sheet.
Future<void> showProfileEditor(BuildContext context, {FamilyProfile? existing}) {
  final app = AppScope.read(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: K.ivory,
    showDragHandle: true,
    builder: (ctx) => _ProfileEditor(existing: existing, canRemove: existing != null && app.profiles.length > 1),
  );
}

class _ProfileEditor extends StatefulWidget {
  const _ProfileEditor({this.existing, required this.canRemove});
  final FamilyProfile? existing;
  final bool canRemove;
  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _gotra = TextEditingController(text: widget.existing?.gotra ?? '');
  late int? _nak = widget.existing?.janmaNakshatra;

  @override
  void dispose() {
    _name.dispose();
    _gotra.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l = context.l;
    final ok = _name.text.trim().isNotEmpty && _gotra.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Bi((l) => widget.existing == null ? l.addProfile : l.editProfile, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ProfileFields(
          name: _name,
          gotra: _gotra,
          nakshatra: _nak,
          onNakshatra: (v) => setState(() => _nak = v),
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        Row(children: [
          if (widget.canRemove)
            TextButton(
              onPressed: () async {
                await app.removeFamilyProfile(widget.existing!.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(l.remove, style: const TextStyle(color: K.saffron)),
            ),
          const Spacer(),
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          const SizedBox(width: 8),
          FilledButton(
            key: const ValueKey('profile-save'),
            onPressed: ok
                ? () async {
                    await app.saveFamilyProfile(id: widget.existing?.id, name: _name.text, gotra: _gotra.text, janmaNakshatra: _nak);
                    if (context.mounted) Navigator.pop(context);
                  }
                : null,
            child: Text(l.save),
          ),
        ]),
      ]),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard();
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l = context.l;
    final tt = Theme.of(context).textTheme;
    return GoldCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Bi((l) => l.yourData, style: tt.titleMedium?.copyWith(color: K.maroon)),
        const SizedBox(height: 4),
        Text(l.yourDataDesc, style: tt.bodySmall),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const ValueKey('export-data'),
          onPressed: () => SharePlus.instance.share(ShareParams(text: app.exportAll(), subject: 'Kalpam data export')),
          icon: const Icon(Icons.ios_share),
          label: Text(l.exportData),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('delete-all'),
          style: OutlinedButton.styleFrom(foregroundColor: K.saffron, side: const BorderSide(color: K.saffron)),
          onPressed: () async {
            final yes = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: K.ivory,
                title: Text(l.deleteAll),
                content: Text(l.deleteAllConfirm),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                  FilledButton(
                    key: const ValueKey('delete-all-confirm'),
                    style: FilledButton.styleFrom(backgroundColor: K.saffron),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(l.deleteAll),
                  ),
                ],
              ),
            );
            if (yes == true) {
              await app.deleteAll();
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            }
          },
          icon: const Icon(Icons.delete_forever_outlined),
          label: Text(l.deleteAll),
        ),
      ]),
    );
  }
}
