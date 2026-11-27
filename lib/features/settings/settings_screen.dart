import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../today/city_picker_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _gotra;

  @override
  void initState() {
    super.initState();
    final app = AppScope.read(context);
    _name = TextEditingController(text: app.devoteeName);
    _gotra = TextEditingController(text: app.gotra);
  }

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
          ]),
        ),
        const SizedBox(height: 12),
        GoldCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Bi((l) => l.aboutYou, style: tt.titleMedium?.copyWith(color: K.maroon)),
            const SizedBox(height: 4),
            Text(l.aboutYouDesc, style: tt.bodySmall),
            const SizedBox(height: 12),
            TextField(controller: _name, decoration: InputDecoration(labelText: l.yourName, border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _gotra, decoration: InputDecoration(labelText: '${l.gotra} (${l.optional})', border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined, color: K.maroon),
              title: Text(context.t(app.city.name)),
              subtitle: Text(l.city),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CityPickerScreen())),
            ),
            const SizedBox(height: 6),
            FilledButton(
              onPressed: () async {
                await app.setProfile(name: _name.text.trim(), gotraV: _gotra.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.save)));
                }
              },
              child: Text(l.save),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        Center(child: Text('Kalpam 1.0.0 · ${l.tagline}', style: tt.bodySmall, textAlign: TextAlign.center)),
      ]),
    );
  }
}
