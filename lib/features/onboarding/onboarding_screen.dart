import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../today/city_chooser.dart';
import '../common/deity_avatar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;
  static const _pages = 4;
  final _name = TextEditingController();
  final _gotra = TextEditingController();

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    _gotra.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final app = AppScope.read(context);
    await app.setProfile(name: _name.text.trim(), gotraV: _gotra.text.trim());
    await app.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(children: [
              Text('కల్పం', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(width: 8),
              Text('Kalpam', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: K.gold)),
              const Spacer(),
              if (_index > 0) TextButton(onPressed: _finish, child: Text(context.l.skip)),
            ]),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                _LanguagePage(onPick: (code) async {
                  await app.setLang(code);
                  _next();
                }),
                _GodPage(onPick: (id) async {
                  await app.setProfile(deity: id);
                  _next();
                }),
                _CityPage(onChosen: _next),
                _AboutPage(name: _name, gotra: _gotra),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(children: [
              for (var i = 0; i < _pages; i++)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: i == _index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: i == _index ? K.maroon : K.goldSoft, borderRadius: BorderRadius.circular(4)),
                ),
              const Spacer(),
              FilledButton(onPressed: _next, child: Text(_index == _pages - 1 ? context.l.begin : context.l.next)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.onPick});
  final ValueChanged<String> onPick;
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    Widget option(String code, String native, String english) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GoldCard(
            onTap: () => onPick(code),
            color: app.lang == code ? K.goldSoft.withValues(alpha: 0.5) : null,
            child: Row(children: [
              Expanded(child: BiPair(native, english, style: Theme.of(context).textTheme.titleLarge)),
              if (app.lang == code) const Icon(Icons.check_circle, color: K.maroon),
            ]),
          ),
        );
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 24),
      Bi((l) => l.welcome, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Bi((l) => l.tagline, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: K.inkSoft)),
      const SizedBox(height: 28),
      Bi((l) => l.language, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      option('te', 'తెలుగు', 'Telugu'),
      option('en', 'English', 'ఇంగ్లీష్'),
    ]);
  }
}

class _GodPage extends StatelessWidget {
  const _GodPage({required this.onPick});
  final ValueChanged<String> onPick;
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final gods = app.repo.deities.values.toList();
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 12),
      Bi((l) => l.chooseGod, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 20),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
        children: [
          for (final d in gods)
            GoldCard(
              key: ValueKey('god-${d.id}'),
              onTap: () => onPick(d.id),
              color: app.deityId == d.id ? K.goldSoft.withValues(alpha: 0.5) : null,
              padding: const EdgeInsets.all(12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                DeityAvatar(deity: d, size: 64),
                const SizedBox(height: 10),
                BiL(d.name, align: CrossAxisAlignment.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: K.maroon), maxLines: 1),
              ]),
            ),
        ],
      ),
    ]);
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage({required this.name, required this.gotra});
  final TextEditingController name, gotra;
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 12),
      Bi((l) => l.aboutYou, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(context.l.aboutYouDesc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: K.inkSoft)),
      const SizedBox(height: 20),
      TextField(controller: name, decoration: InputDecoration(labelText: context.l.yourName, border: const OutlineInputBorder())),
      const SizedBox(height: 14),
      TextField(
          controller: gotra,
          decoration: InputDecoration(labelText: '${context.l.gotra} (${context.l.optional})', border: const OutlineInputBorder())),
    ]);
  }
}

class _CityPage extends StatelessWidget {
  const _CityPage({required this.onChosen});
  final VoidCallback onChosen;
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 12),
      Bi((l) => l.chooseCity, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(context.l.cityWhy, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: K.inkSoft)),
      const SizedBox(height: 16),
      CityChooser(onChosen: onChosen),
    ]);
  }
}
