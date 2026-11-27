import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/content/models.dart';
import '../../l10n/gen/app_localizations.dart';
import 'chant_player_screen.dart';

String categoryLabel(AppLocalizations l, String c) => switch (c) {
      'sahasranamam' => l.catSahasranamam,
      'ashtottaram' => l.catAshtottaram,
      'chalisa' => l.catChalisa,
      'suprabhatam' => l.catSuprabhatam,
      'saranam' => l.catSaranam,
      'keertana' => l.catKeertana,
      'mantram' => l.catMantram,
      'namavali' => l.catNamavali,
      'namajapam' => l.catNamajapam,
      _ => l.catStotram,
    };

/// One stotra in the library. Sample texts carry a visible "Sample" flag.
class StotraTile extends StatelessWidget {
  const StotraTile({super.key, required this.stotra});
  final StotraItem stotra;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      key: ValueKey('stotra-${stotra.id}'),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChantPlayerScreen(stotraId: stotra.id))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          const Icon(Icons.menu_book_outlined, color: K.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BiL(stotra.title, style: tt.titleSmall),
              const SizedBox(height: 2),
              Text('${categoryLabel(context.l, stotra.category)} · ${context.l.linesCount(stotra.lines.length)}',
                  style: tt.bodySmall?.copyWith(color: K.inkSoft)),
            ]),
          ),
          if (!stotra.complete)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(border: Border.all(color: K.saffron), borderRadius: BorderRadius.circular(10)),
              child: Text(context.l.sampleShort, style: tt.labelSmall?.copyWith(color: K.saffron)),
            ),
          const Icon(Icons.play_circle_outline, color: K.maroon),
        ]),
      ),
    );
  }
}
