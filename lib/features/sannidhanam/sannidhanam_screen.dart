import 'package:material_ui/material_ui.dart';

import '../common/pending_screen.dart';

/// Scheduled for Phase A screen group 2 (see docs/BUILD_LOG.md).
/// Replaced with the full screen after Sharath reviews group 1.
class SannidhanamScreen extends StatelessWidget {
  const SannidhanamScreen({super.key});

  @override
  Widget build(BuildContext context) => PendingScreen(title: (l) => l.tabSannidhanam, group: 2, asTab: true);
}
