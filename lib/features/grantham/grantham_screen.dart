import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/content/models.dart';
import 'stotra_tile.dart';

/// Grantham tab: the built-in stotra library. Parayanam today on top, then
/// the library by god (your god first) or by category.
class GranthamScreen extends StatefulWidget {
  const GranthamScreen({super.key});
  @override
  State<GranthamScreen> createState() => _GranthamScreenState();
}

class _GranthamScreenState extends State<GranthamScreen> {
  bool _byGod = true;

  /// Phase A core set leads the library (Ayyappa set, Vishnu and Lalitha
  /// Sahasranamam, Hanuman Chalisa).
  static const coreOrder = ['ayyappa_saranam_108', 'harivarasanam', 'maladharana_mantram', 'vishnu_sahasranamam', 'lalitha_sahasranamam', 'hanuman_chalisa'];

  int _rank(StotraItem s) {
    final i = coreOrder.indexOf(s.id);
    return i < 0 ? coreOrder.length : i;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    final all = app.repo.stotras.values.toList()..sort((a, b) => _rank(a).compareTo(_rank(b)));
    final today = app.repo.parayanamFor(app.today.weekday);

    Widget group(Widget title, List<StotraItem> items) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GoldCard(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              title,
              for (final (i, s) in items.indexed) ...[
                if (i > 0) const Divider(height: 1),
                StotraTile(stotra: s),
              ],
            ]),
          ),
        );

    final groups = <Widget>[];
    if (_byGod) {
      final gods = [app.deity, ...app.repo.deities.values.where((d) => d.id != app.deity.id)];
      gods.sort((a, b) {
        if (a.id == app.deity.id) return -1;
        if (b.id == app.deity.id) return 1;
        int r(d) => all.indexWhere((s) => s.deityIds.contains(d.id));
        return r(a).compareTo(r(b));
      });
      for (final d in gods) {
        final items = all.where((s) => s.deityIds.contains(d.id)).toList();
        if (items.isNotEmpty) groups.add(group(BiL(d.name, style: tt.titleMedium?.copyWith(color: K.maroon)), items));
      }
    } else {
      final cats = <String, List<StotraItem>>{};
      for (final s in all) {
        cats.putIfAbsent(s.category, () => []).add(s);
      }
      for (final e in cats.entries) {
        groups.add(group(Bi((l) => categoryLabel(l, e.key), style: tt.titleMedium?.copyWith(color: K.maroon)), e.value));
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
            child: Bi((l) => l.tabGrantham, style: tt.headlineMedium?.copyWith(color: K.maroon)),
          ),
          if (today.isNotEmpty)
            group(Bi((l) => l.parayanamToday, style: tt.titleMedium?.copyWith(color: K.gold)), today),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(spacing: 8, children: [
              ChoiceChip(
                key: const ValueKey('grantham-by-god'),
                selected: _byGod,
                onSelected: (_) => setState(() => _byGod = true),
                label: Bi((l) => l.byGod, style: tt.labelLarge),
              ),
              ChoiceChip(
                key: const ValueKey('grantham-by-category'),
                selected: !_byGod,
                onSelected: (_) => setState(() => _byGod = false),
                label: Bi((l) => l.byCategory, style: tt.labelLarge),
              ),
            ]),
          ),
          ...groups,
        ],
      ),
    );
  }
}
