import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../l10n/gen/app_localizations.dart';

/// Temporary, clearly-labelled screen for a feature whose screen group is
/// not built yet. Tracked in project-docs/BUILD_LOG.md; none ships to users.
class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key, required this.title, required this.group, required this.asTab});
  final String Function(AppLocalizations l) title;
  final int group;
  final bool asTab;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final body = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GoldCard(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.construction_outlined, color: K.gold, size: 36),
            const SizedBox(height: 12),
            Bi(title, style: tt.titleLarge, align: CrossAxisAlignment.center),
            const SizedBox(height: 8),
            Text('Screen group $group — in review queue', style: tt.bodySmall, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
    if (asTab) return SafeArea(child: body);
    return Scaffold(appBar: AppBar(title: Bi(title, style: tt.titleLarge)), body: body);
  }
}
