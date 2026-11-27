import 'package:material_ui/material_ui.dart';

import '../common/pending_screen.dart';

/// Scheduled for Phase A screen group 3 (see docs/BUILD_LOG.md).
/// Replaced with the full screen after Sharath reviews group 1.
class ChantPlayerScreen extends StatelessWidget {
  const ChantPlayerScreen({super.key, required this.stotraId});
  final String stotraId;

  @override
  Widget build(BuildContext context) => PendingScreen(title: (l) => l.chanting, group: 3, asTab: false);
}
