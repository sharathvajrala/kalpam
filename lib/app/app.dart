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
  static final tabIndex = ValueNotifier<int>(0);

  /// Lets any screen switch tabs (e.g. My God -> Sannidhanam).
  static void go(int i) => tabIndex.value = i;

  @override
  State<KalpamShell> createState() => _KalpamShellState();
}

class _KalpamShellState extends State<KalpamShell> {
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return ValueListenableBuilder<int>(
      valueListenable: KalpamShell.tabIndex,
      builder: (context, index, _) => Scaffold(
        body: IndexedStack(index: index, children: const [
          TodayScreen(),
          SannidhanamScreen(),
          GranthamScreen(),
          BhajansScreen(),
          GroupsScreen(),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: KalpamShell.go,
          destinations: [
            NavigationDestination(icon: const Icon(Icons.wb_sunny_outlined), selectedIcon: const Icon(Icons.wb_sunny), label: l.tabToday),
            NavigationDestination(icon: const Icon(Icons.temple_hindu_outlined), selectedIcon: const Icon(Icons.temple_hindu), label: l.tabSannidhanam),
            NavigationDestination(icon: const Icon(Icons.menu_book_outlined), selectedIcon: const Icon(Icons.menu_book), label: l.tabGrantham),
            NavigationDestination(icon: const Icon(Icons.library_music_outlined), selectedIcon: const Icon(Icons.library_music), label: l.tabBhajans),
            NavigationDestination(icon: const Icon(Icons.groups_outlined), selectedIcon: const Icon(Icons.groups), label: l.tabGroups),
          ],
        ),
      ),
    );
  }
}
