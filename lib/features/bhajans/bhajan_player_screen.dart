import 'package:material_ui/material_ui.dart';

import '../common/pending_screen.dart';

/// Scheduled for Phase A screen group 4 (see docs/BUILD_LOG.md).
/// Replaced with the full screen after Sharath reviews group 1.
class BhajanPlayerScreen extends StatelessWidget {
  const BhajanPlayerScreen({super.key, required this.bhajanId});
  final String bhajanId;

  @override
  Widget build(BuildContext context) => PendingScreen(title: (l) => l.tabBhajans, group: 4, asTab: false);
}
