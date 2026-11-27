import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import 'pooja_setup_screen.dart';

/// Sannidhanam tab: the user's god's sanctum with mode and length pickers.
class SannidhanamScreen extends StatelessWidget {
  const SannidhanamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      child: PoojaSetupBody(
        deityId: app.deityId,
        header: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Bi((l) => l.tabSannidhanam, style: tt.headlineMedium?.copyWith(color: K.maroon)),
            const SizedBox(height: 4),
            BiL(app.repo.deities[PoojaSetupBodyGate.openFor(app.deityId)]!.greeting, style: tt.bodyMedium?.copyWith(color: K.inkSoft)),
          ]),
        ),
      ),
    );
  }
}
