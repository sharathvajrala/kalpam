import 'package:material_ui/material_ui.dart';

import '../common/pending_screen.dart';

/// Scheduled for Phase A screen group 5 (see project-docs/BUILD_LOG.md).
/// Replaced with the full screen after Sharath reviews group 1.
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) => PendingScreen(title: (l) => l.tabGroups, group: 5, asTab: true);
}
