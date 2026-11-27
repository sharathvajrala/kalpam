import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/chant/playlist.dart';
import '../../core/content/models.dart';
import '../../core/voice/voice_guide.dart';

/// Bhajan player: big karaoke lyrics, playlist with auto-advance and loop.
/// Without a licensed recording the voice guide reads each line, and the
/// screen says so.
class BhajanPlayerScreen extends StatefulWidget {
  const BhajanPlayerScreen({super.key, required this.bhajanId, this.playlistIds});
  final String bhajanId;

  /// The queue (e.g. the season playlist); defaults to just this bhajan.
  final List<String>? playlistIds;

  @override
  State<BhajanPlayerScreen> createState() => _BhajanPlayerScreenState();
}

class _BhajanPlayerScreenState extends State<BhajanPlayerScreen> with SingleTickerProviderStateMixin {
  late final BhajanPlaylist _list;
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    final repo = AppScope.read(context).repo;
    final ids = (widget.playlistIds ?? [widget.bhajanId]).where(repo.bhajans.containsKey).toList();
    if (!ids.contains(widget.bhajanId)) ids.insert(0, widget.bhajanId);
    final items = ids.map((id) => repo.bhajans[id]!).toList();
    _list = BhajanPlaylist(items, start: ids.indexOf(widget.bhajanId), onLineStart: _read)..addListener(_onChange);
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      _list.advance(dt.clamp(0, 0.1));
    });
  }

  void _read(TextLine line, int _) {
    if (_list.current.audio.isPlaceholder) VoiceGuide.instance.speak(line.script, lang: 'te');
  }

  void _onChange() {
    if (_list.playing && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!_list.playing && _ticker.isActive) {
      _ticker.stop();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _list.dispose();
    VoiceGuide.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final b = _list.current;
    final e = _list.engine;
    return Scaffold(
      appBar: AppBar(title: BiL(b.title, style: tt.titleLarge)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Wrap(spacing: 8, runSpacing: 6, children: [
            if (_list.items.length > 1)
              Text(context.l.bhajanOf(_list.index + 1, _list.items.length), style: tt.labelMedium?.copyWith(color: K.gold)),
            Text(context.l.aboutMin((b.durationSec / 60).round()), style: tt.bodySmall?.copyWith(color: K.inkSoft)),
            if (!b.lyricsVerified) PlaceholderChip(context.l.lyricsSample),
            if (b.audio.isPlaceholder) PlaceholderChip(context.l.voiceReads),
          ]),
          const SizedBox(height: 12),
          Bi((l) => l.lyrics, style: tt.titleMedium?.copyWith(color: K.maroon)),
          const SizedBox(height: 8),
          for (final (i, line) in b.lyrics.indexed) _lyric(context, i, line),
          const SizedBox(height: 8),
          Text(b.source, style: tt.bodySmall?.copyWith(color: K.inkSoft)),
          if (_list.items.length > 1) ...[
            const SizedBox(height: 16),
            GoldCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Bi((l) => l.upNext, style: tt.titleSmall?.copyWith(color: K.maroon)),
                for (final (i, item) in _list.items.indexed)
                  ListTile(
                    key: ValueKey('queue-${item.id}'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(i == _list.index ? Icons.graphic_eq : Icons.music_note_outlined,
                        color: i == _list.index ? K.maroon : K.gold),
                    title: Text(context.t(item.title),
                        style: tt.bodyMedium?.copyWith(fontWeight: i == _list.index ? FontWeight.w700 : null)),
                    onTap: () => _list.jumpTo(i),
                  ),
              ]),
            ),
          ],
          if (e.finished && _list.finished) ...[
            const SizedBox(height: 12),
            Center(child: Bi((l) => l.chantComplete, style: tt.titleMedium, align: CrossAxisAlignment.center)),
          ],
        ],
      ),
      bottomNavigationBar: _controls(context),
    );
  }

  Widget _lyric(BuildContext context, int i, TextLine line) {
    final tt = Theme.of(context).textTheme;
    final e = _list.engine;
    final current = i == e.lineIndex && !e.finished;
    final base = tt.titleLarge?.copyWith(fontFamily: K.teluguSerif, height: 1.5, fontSize: 22);
    Widget script = Text(line.script, style: base?.copyWith(color: current ? K.ink : K.ink.withValues(alpha: 0.75)));
    if (current) {
      final p = e.lineProgress;
      script = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(colors: const [K.maroon, K.maroon, K.inkSoft, K.inkSoft], stops: [0, p, p, 1]).createShader(r),
        child: Text(line.script, key: const ValueKey('current-lyric'), style: base?.copyWith(fontWeight: FontWeight.w700)),
      );
    }
    return GestureDetector(
      onTap: () => e.seekLine(i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: current ? K.goldSoft.withValues(alpha: 0.35) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: current ? K.gold : Colors.transparent),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          script,
          Text(line.translit, style: tt.bodyMedium?.copyWith(color: K.inkSoft, fontStyle: FontStyle.italic)),
        ]),
      ),
    );
  }

  Widget _controls(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final e = _list.engine;
    return Container(
      decoration: const BoxDecoration(color: K.maroonDeep, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: e.finished ? 1 : (e.lineIndex + e.lineProgress) / e.lines.length,
              minHeight: 3,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(K.goldBright),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              key: const ValueKey('bhajan-loop'),
              tooltip: context.l.loopPlaylist,
              onPressed: () => _list.setLoop(!_list.loop),
              icon: Icon(Icons.repeat, color: _list.loop ? K.goldBright : Colors.white38),
            ),
            const Spacer(),
            IconButton(onPressed: _list.items.length > 1 ? _list.previous : null, icon: const Icon(Icons.skip_previous, color: K.goldSoft, size: 32)),
            const SizedBox(width: 8),
            IconButton.filled(
              key: const ValueKey('bhajan-play'),
              tooltip: _list.playing ? context.l.pause : context.l.listen,
              onPressed: _list.toggle,
              style: IconButton.styleFrom(backgroundColor: K.goldBright, foregroundColor: K.maroonDeep, minimumSize: const Size(64, 64)),
              icon: Icon(_list.playing ? Icons.pause : Icons.play_arrow, size: 36),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: _list.items.length > 1 ? _list.next : null, icon: const Icon(Icons.skip_next, color: K.goldSoft, size: 32)),
            const Spacer(),
            const SizedBox(width: 48),
          ]),
          Text(context.l.offlineLyrics, style: tt.labelSmall?.copyWith(color: Colors.white54)),
        ]),
      ),
    );
  }
}
