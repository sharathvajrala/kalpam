import 'package:material_ui/material_ui.dart';

import '../common/pending_screen.dart';

/// Scheduled for Phase A screen group 3 (see docs/BUILD_LOG.md).
/// Replaced with the full screen after Sharath reviews group 1.
class GranthamScreen extends StatelessWidget {
  const GranthamScreen({super.key});

  @override
  Widget build(BuildContext context) => PendingScreen(title: (l) => l.tabGrantham, group: 3, asTab: true);
}
