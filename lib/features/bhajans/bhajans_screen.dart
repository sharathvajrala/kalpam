import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/content/models.dart';
import 'bhajan_player_screen.dart';

/// Bhajans tab: the flagship season playlist on top (it becomes the home
/// playlist in its season), then your god's bhajans, then every other god.
class BhajansScreen extends StatelessWidget {
  const BhajansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    final repo = app.repo;
    final season = app.hero?.season;
    final seasonIds = (season?.bhajanSet ?? const <String>[]).where(repo.bhajans.containsKey).toList();

    List<String> idsFor(DeityPack d) => d.bhajans.where(repo.bhajans.containsKey).toList();
    final gods = [app.deity, ...repo.deities.values.where((d) => d.id != app.deity.id)].where((d) => idsFor(d).isNotEmpty);

    Widget section(Widget title, List<String> ids, {Key? key, bool playAll = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GoldCard(
            key: key,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Title and Play all side by side; stacked when text is large.
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (playAll) title else SizedBox(width: double.infinity, child: title),
                  if (playAll)
                    FilledButton.icon(
                      key: const ValueKey('season-play-all'),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => BhajanPlayerScreen(bhajanId: ids.first, playlistIds: ids))),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(context.l.playAll),
                    ),
                ],
              ),
              for (final (i, id) in ids.indexed) ...[
                if (i > 0) const Divider(height: 1),
                _BhajanTile(bhajan: repo.bhajans[id]!, queue: ids),
              ],
            ]),
          ),
        );

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, context.app.elderMode ? 120 : 24), // room for the Elder Mode mic
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
            child: Bi((l) => l.tabBhajans, style: tt.headlineMedium?.copyWith(color: K.maroon)),
          ),
          if (seasonIds.isNotEmpty)
            section(
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Bi((l) => l.seasonPlaylist, style: tt.labelLarge?.copyWith(color: K.gold)),
                BiL(season!.title, style: tt.titleMedium?.copyWith(color: K.maroon)),
              ]),
              seasonIds,
              key: const ValueKey('season-playlist'),
              playAll: true,
            ),
          for (final d in gods) section(BiL(d.name, style: tt.titleMedium?.copyWith(color: K.maroon)), idsFor(d)),
        ],
      ),
    );
  }
}

class _BhajanTile extends StatelessWidget {
  const _BhajanTile({required this.bhajan, required this.queue});
  final BhajanItem bhajan;
  final List<String> queue;
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      key: ValueKey('bhajan-${bhajan.id}'),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BhajanPlayerScreen(bhajanId: bhajan.id, playlistIds: queue))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          const Icon(Icons.music_note_outlined, color: K.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BiL(bhajan.title, style: tt.titleSmall),
              Text(context.l.aboutMin((bhajan.durationSec / 60).round()), style: tt.bodySmall?.copyWith(color: K.inkSoft)),
            ]),
          ),
          if (!bhajan.lyricsVerified)
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
