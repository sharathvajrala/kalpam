import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/chant/chant_engine.dart';
import '../../core/content/models.dart';
import '../../core/voice/voice_guide.dart';
import 'stotra_tile.dart';

/// Chant-along player (sample 4): the current line fills karaoke-style,
/// Sung or slow Learn mode, repeat-line ×11/21/108, meaning toggle and the
/// japa mala counter with bead progress.
class ChantPlayerScreen extends StatefulWidget {
  const ChantPlayerScreen({super.key, required this.stotraId});
  final String stotraId;

  @override
  State<ChantPlayerScreen> createState() => _ChantPlayerScreenState();
}

class _ChantPlayerScreenState extends State<ChantPlayerScreen> with SingleTickerProviderStateMixin {
  late final StotraItem _stotra;
  late final ChantEngine _engine;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _meaning = true;
  late final AppState _app;
  final _lineKeys = <GlobalKey>[];
  int _shownLine = -1;

  @override
  void initState() {
    super.initState();
    final app = _app = AppScope.read(context);
    _stotra = app.repo.stotras[widget.stotraId]!;
    _lineKeys.addAll(List.generate(_stotra.lines.length, (_) => GlobalKey()));
    _engine = ChantEngine(
      lines: _stotra.lines,
      mode: app.elderMode ? ChantMode.learn : ChantMode.sung,
      japa: JapaCounter(target: app.japaTarget(_stotra.id), initial: app.japaCount(_stotra.id)),
      // No licensed recording yet: the voice guide reads each line (flagged).
      onLineStart: _stotra.sung.isPlaceholder ? (l, _) => VoiceGuide.instance.speak(l.script, lang: 'te') : null,
    )..addListener(_onEngine);
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      _engine.advance(dt.clamp(0, 0.1));
    });
  }

  void _onEngine() {
    // The ticker runs only while chanting.
    if (_engine.playing && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!_engine.playing && _ticker.isActive) {
      _ticker.stop();
    }
    if (_engine.lineIndex != _shownLine) {
      _shownLine = _engine.lineIndex;
      final ctx = _lineKeys[_shownLine].currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.3, duration: const Duration(milliseconds: 350));
    }
    setState(() {});
  }

  void _saveJapa() => _app.saveJapa(_stotra.id, _engine.japa.count, _engine.japa.target);

  @override
  void dispose() {
    _saveJapa();
    _ticker.dispose();
    _engine.dispose();
    VoiceGuide.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final e = _engine;
    return Scaffold(
      appBar: AppBar(title: BiL(_stotra.title, style: tt.titleLarge)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(children: [
            Expanded(
              child: SegmentedButton<ChantMode>(
                key: const ValueKey('chant-mode'),
                segments: [
                  ButtonSegment(value: ChantMode.sung, label: Bi((l) => l.sung, style: tt.labelLarge, align: CrossAxisAlignment.center)),
                  ButtonSegment(value: ChantMode.learn, label: Bi((l) => l.learnMode, style: tt.labelLarge, align: CrossAxisAlignment.center)),
                ],
                selected: {e.mode},
                onSelectionChanged: (v) => e.setMode(v.first),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const ValueKey('meaning-toggle'),
              tooltip: context.l.meaning,
              isSelected: _meaning,
              onPressed: () => setState(() => _meaning = !_meaning),
              icon: const Icon(Icons.translate),
              color: _meaning ? K.maroon : K.inkSoft,
            ),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            Text('${categoryLabel(context.l, _stotra.category)} · ${context.l.linesCount(_stotra.lines.length)}',
                style: tt.bodySmall?.copyWith(color: K.inkSoft)),
            if (!_stotra.complete) PlaceholderChip(context.l.sampleText),
            if (_stotra.sung.isPlaceholder) PlaceholderChip(context.l.voiceReads),
          ]),
          const SizedBox(height: 12),
          for (final (i, line) in _stotra.lines.indexed) _line(context, i, line),
          const SizedBox(height: 8),
          Text('${context.l.sourceLabel}: ${_stotra.source}', style: tt.bodySmall?.copyWith(color: K.inkSoft)),
          const SizedBox(height: 16),
          _JapaCard(japa: e.japa, engine: e, onChanged: _saveJapa),
        ],
      ),
      bottomNavigationBar: _controls(context),
    );
  }

  Widget _line(BuildContext context, int i, TextLine line) {
    final tt = Theme.of(context).textTheme;
    final e = _engine;
    final current = i == e.lineIndex;
    final done = i < e.lineIndex || (e.finished);
    final base = tt.titleLarge?.copyWith(fontFamily: K.teluguSerif, height: 1.5, fontSize: 21);
    Widget script = Text(line.script, style: base?.copyWith(color: done ? K.maroon.withValues(alpha: 0.55) : K.ink));
    if (current && !e.finished) {
      // Karaoke fill: maroon up to the progress point, soft ink after it.
      final p = e.lineProgress;
      script = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(
          colors: const [K.maroon, K.maroon, K.inkSoft, K.inkSoft],
          stops: [0, p, p, 1],
        ).createShader(r),
        child: Text(line.script, key: const ValueKey('current-line'), style: base?.copyWith(fontWeight: FontWeight.w700)),
      );
    }
    return GestureDetector(
      key: _lineKeys[i],
      onTap: () => e.seekLine(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
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
          if (_meaning && context.t(line.meaning).isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(context.t(line.meaning), style: tt.bodySmall?.copyWith(color: K.ink)),
          ],
        ]),
      ),
    );
  }

  Widget _controls(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final e = _engine;
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
          Row(children: [
            Text(e.finished ? context.l.chantComplete : context.l.lineOf(e.lineIndex + 1, e.lines.length),
                style: tt.labelMedium?.copyWith(color: K.goldSoft)),
            const Spacer(),
            if (e.repeat > 1) Text(context.l.repeatOf(e.repeatIndex + 1, e.repeat), style: tt.labelMedium?.copyWith(color: K.goldSoft)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: e.previous, icon: const Icon(Icons.skip_previous, color: K.goldSoft, size: 32)),
            const SizedBox(width: 8),
            IconButton.filled(
              key: const ValueKey('chant-play'),
              tooltip: e.playing ? context.l.pause : context.l.listen,
              onPressed: e.toggle,
              style: IconButton.styleFrom(backgroundColor: K.goldBright, foregroundColor: K.maroonDeep, minimumSize: const Size(64, 64)),
              icon: Icon(e.playing ? Icons.pause : Icons.play_arrow, size: 36),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: e.next, icon: const Icon(Icons.skip_next, color: K.goldSoft, size: 32)),
          ]),
          Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, children: [
            Text(context.l.repeatLine, style: tt.labelMedium?.copyWith(color: Colors.white70)),
            for (final n in ChantEngine.repeatChoices)
              Padding(
                padding: EdgeInsets.zero,
                child: ChoiceChip(
                  key: ValueKey('repeat-$n'),
                  selected: e.repeat == n,
                  onSelected: (_) => e.setRepeat(n),
                  label: Text('×$n'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}

class _JapaCard extends StatelessWidget {
  const _JapaCard({required this.japa, required this.engine, required this.onChanged});
  final JapaCounter japa;
  final ChantEngine engine;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: japa,
      builder: (context, _) => GoldCard(
        key: const ValueKey('japa-card'),
        child: Column(children: [
          Align(alignment: Alignment.centerLeft, child: Bi((l) => l.japaCounter, style: tt.titleMedium?.copyWith(color: K.maroon))),
          const SizedBox(height: 6),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text('${context.l.japaTarget} ', style: tt.labelMedium),
            for (final t in const [108, 1008])
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ChoiceChip(
                  key: ValueKey('japa-target-$t'),
                  selected: japa.target == t,
                  onSelected: (_) {
                    japa.setTarget(t);
                    onChanged();
                  },
                  label: Text(t == 1008 ? '1,008' : '108'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ]),
          const SizedBox(height: 12),
          GestureDetector(
            key: const ValueKey('japa-tap'),
            onTap: () {
              final mala = japa.tap();
              mala ? HapticFeedback.heavyImpact() : HapticFeedback.selectionClick();
              onChanged();
            },
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _BeadsPainter(japa.bead, japa.reachedTarget),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${japa.count}', style: tt.displaySmall?.copyWith(color: K.maroon, fontWeight: FontWeight.w700)),
                    Text('/ ${japa.target == 1008 ? '1,008' : japa.target}', style: tt.bodyMedium?.copyWith(color: K.inkSoft)),
                    const SizedBox(height: 4),
                    Text(japa.reachedTarget ? context.l.malaDone(japa.count) : context.l.tapToCount,
                        style: tt.labelMedium?.copyWith(color: japa.reachedTarget ? K.success : K.gold)),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Text(context.l.malasCount(japa.malas), style: tt.bodySmall),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                japa.reset();
                onChanged();
              },
              icon: const Icon(Icons.restart_alt, size: 18),
              label: Text(context.l.reset),
            ),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: engine.countRepeatsOnMala,
            onChanged: (v) {
              engine.countRepeatsOnMala = v;
              (context as Element).markNeedsBuild();
            },
            title: Text(context.l.countRepeats, style: tt.bodyMedium),
          ),
        ]),
      ),
    );
  }
}

/// 108 beads around a ring; beads chanted so far in this mala glow gold.
class _BeadsPainter extends CustomPainter {
  _BeadsPainter(this.bead, this.complete);
  final int bead;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 8;
    for (var i = 0; i < JapaCounter.beadsPerMala; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / JapaCounter.beadsPerMala;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      final lit = complete || i < bead;
      canvas.drawCircle(p, i == 0 ? 5 : 3.2, Paint()..color = lit ? K.goldBright : K.goldSoft.withValues(alpha: 0.6));
    }
    // Meru bead at the top
    canvas.drawCircle(c + Offset(0, -r - 10), 6, Paint()..color = K.maroon);
  }

  @override
  bool shouldRepaint(_BeadsPainter old) => old.bead != bead || old.complete != complete;
}
