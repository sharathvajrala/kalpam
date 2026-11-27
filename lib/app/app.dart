import 'package:material_ui/material_ui.dart';

import '../features/bhajans/bhajans_screen.dart';
import '../features/grantham/grantham_screen.dart';
import '../features/groups/groups_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/sannidhanam/sannidhanam_screen.dart';
import '../features/today/today_screen.dart';
import '../l10n/gen/app_localizations.dart';
import 'app_scope.dart';
import 'app_state.dart';
import 'theme.dart';

class KalpamApp extends StatelessWidget {
  const KalpamApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'Kalpam',
          debugShowCheckedModeBanner: false,
          theme: kalpamTheme(elder: state.elderMode),
          locale: Locale(state.lang),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) {
            // Elder Mode: large text everywhere.
            final mq = MediaQuery.of(context);
            final scale = state.elderMode ? 1.3 : 1.0;
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.linear(mq.textScaler.scale(1) * scale)),
              child: child!,
            );
          },
          home: state.onboarded ? const KalpamShell() : const OnboardingScreen(),
        ),
      ),
    );
  }
}

/// Bottom tab shell: Today, Sannidhanam, Grantham, Bhajans, Groups.
class KalpamShell extends StatefulWidget {
  const KalpamShell({super.key});
  static final tabIndex = ValueNotifier<int>(const int.fromEnvironment('KALPAM_TAB'));

  /// Lets any screen switch tabs (e.g. My God -> Sannidhanam).
  static void go(int i) => tabIndex.value = i;

  @override
  State<KalpamShell> createState() => _KalpamShellState();
}

class _KalpamShellState extends State<KalpamShell> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: KalpamShell.tabIndex,
      builder: (context, index, _) => Scaffold(
        // Hidden tabs keep their state but stop animating (the sanctum
        // ticker must not run off-screen).
        body: IndexedStack(index: index, children: [
          for (final (i, tab) in const [TodayScreen(), SannidhanamScreen(), GranthamScreen(), BhajansScreen(), GroupsScreen()].indexed)
            TickerMode(enabled: i == index, child: tab),
        ]),
        bottomNavigationBar: _BiTabBar(index: index),
      ),
    );
  }
}

/// Bottom tab bar with bilingual labels (primary language + secondary script),
/// per the design rule that every label is bilingual.
class _BiTabBar extends StatelessWidget {
  const _BiTabBar({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = context.l, l2 = context.l2;
    final elder = context.app.elderMode;
    final tabs = [
      (Icons.wb_sunny_outlined, Icons.wb_sunny, l.tabToday, l2.tabToday),
      (Icons.temple_hindu_outlined, Icons.temple_hindu, l.tabSannidhanam, l2.tabSannidhanam),
      (Icons.menu_book_outlined, Icons.menu_book, l.tabGrantham, l2.tabGrantham),
      (Icons.library_music_outlined, Icons.library_music, l.tabBhajans, l2.tabBhajans),
      (Icons.groups_outlined, Icons.groups, l.tabGroups, l2.tabGroups),
    ];
    return Material(
      color: K.card,
      child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: K.gold.withValues(alpha: 0.5)))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == index,
                    button: true,
                    label: '${tabs[i].$3}, ${tabs[i].$4}',
                    child: InkWell(
                      key: ValueKey('tab-$i'),
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => KalpamShell.go(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: i == index ? K.goldSoft : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(i == index ? tabs[i].$2 : tabs[i].$1, color: K.maroon, size: elder ? 28 : 24),
                          ),
                          const SizedBox(height: 3),
                          Text(tabs[i].$3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                  fontSize: elder ? 13 : 11,
                                  fontWeight: i == index ? FontWeight.w700 : FontWeight.w600,
                                  color: K.maroon)),
                          Text(tabs[i].$4,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(fontSize: elder ? 11 : 9, color: K.inkSoft)),
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
