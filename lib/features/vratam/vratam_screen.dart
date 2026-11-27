import 'package:material_ui/material_ui.dart';

import '../common/pending_screen.dart';

enum VratamTab { katha, samagri, sankalpam, vidhanam, tracker, udyapanam }

/// Scheduled for Phase A screen group 3 (Ayyappa vratam, sample 3).
class VratamScreen extends StatelessWidget {
  const VratamScreen({super.key, required this.vratamId, this.initialTab = VratamTab.tracker});
  final String vratamId;
  final VratamTab initialTab;

  @override
  Widget build(BuildContext context) => PendingScreen(title: (l) => l.tracker, group: 3, asTab: false);
}
