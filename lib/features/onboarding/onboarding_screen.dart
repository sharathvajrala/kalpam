import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/profile/family_profile.dart';
import '../common/deity_avatar.dart';
import '../common/profile_form.dart';
import '../today/city_chooser.dart';

/// Onboarding collects exactly the approved required set — language, god,
/// city, name, gotram, reminder times — plus optional janma nakshatram.
/// Required steps cannot be skipped.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;
  static const _pages = 5;
  final _name = TextEditingController();
  final _gotra = TextEditingController();
  int? _nakshatra;
  ReminderTime _morning = const ReminderTime(5, 30);
  ReminderTime _evening = const ReminderTime(18, 30);

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    _gotra.dispose();
    super.dispose();
  }

  bool _canProceed(BuildContext context) => switch (_index) {
        2 => context.app.hasCity,
        3 => _name.text.trim().isNotEmpty && _gotra.text.trim().isNotEmpty,
        _ => true,
      };

  void _next() {
    FocusScope.of(context).unfocus();
    if (_index < _pages - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _back() => _page.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

  Future<void> _finish() async {
    final app = AppScope.read(context);
    await app.saveFamilyProfile(name: _name.text, gotra: _gotra.text, janmaNakshatra: _nakshatra);
    await app.setReminders(morning: _morning, evening: _evening);
    await app.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ok = _canProceed(context);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 12, 0),
            child: Row(children: [
              if (_index > 0)
                IconButton(onPressed: _back, icon: const Icon(Icons.arrow_back, color: K.maroon))
              else
                const SizedBox(width: 12),
              Text('కల్పం', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(width: 8),
              Text('Kalpam', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: K.gold)),
            ]),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(), // required steps can't be swiped past
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
                ListView(padding: const EdgeInsets.all(20), children: [
                  const SizedBox(height: 12),
                  Bi((l) => l.aboutYou, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(context.l.aboutYouDesc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: K.inkSoft)),
                  const SizedBox(height: 20),
                  ProfileFields(
                    name: _name,
                    gotra: _gotra,
                    nakshatra: _nakshatra,
                    onNakshatra: (v) => setState(() => _nakshatra = v),
                    onChanged: () => setState(() {}),
                  ),
                ]),
                ListView(padding: const EdgeInsets.all(20), children: [
                  const SizedBox(height: 12),
                  Bi((l) => l.reminders, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(context.l.remindersDesc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: K.inkSoft)),
                  const SizedBox(height: 20),
                  ReminderFields(
                    morning: _morning,
                    evening: _evening,
                    onMorning: (v) => setState(() => _morning = v),
                    onEvening: (v) => setState(() => _evening = v),
                  ),
                ]),
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
              FilledButton(
                key: const ValueKey('onboarding-next'),
                onPressed: ok ? _next : null,
                child: Text(_index == _pages - 1 ? context.l.begin : context.l.next),
              ),
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
