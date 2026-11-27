import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/content/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../pooja_engine/pooja_session.dart';
import '../../pooja_engine/sanctum_bridge.dart';
import '../../pooja_engine/tts_voice.dart';
import 'placeholder_sanctum.dart';

/// The pooja itself: the sanctum fills the screen, a calm HUD below shows
/// the step, its mantra and what to do. No points, no streaks, no
/// notifications while this screen is open (NotificationGate).
class PoojaScreen extends StatefulWidget {
  const PoojaScreen({
    super.key,
    required this.deity,
    required this.vidhanam,
    required this.mode,
    required this.sankalpamText,
    this.voice,
    this.timeScale,
    this.useSensors,
  });

  /// Test hooks: fast Watch Mode, no platform sensors.
  static double debugTimeScale = 1;
  static bool debugUseSensors = true;

  final DeityPack deity;
  final PoojaVidhanam vidhanam;
  final PoojaMode mode;
  final String sankalpamText;
  final VoicePort? voice;
  final double? timeScale;
  final bool? useSensors;

  @override
  State<PoojaScreen> createState() => _PoojaScreenState();
}

class _PoojaScreenState extends State<PoojaScreen> {
  final _bridge = SanctumBridge();
  late final PoojaSession _session;
  StreamSubscription<AccelerometerEvent>? _accel;
  final _clock = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    final lang = AppScope.read(context).lang;
    _session = PoojaSession(
      deity: widget.deity,
      vidhanam: widget.vidhanam,
      mode: widget.mode,
      bridge: _bridge,
      lang: lang,
      sankalpamText: widget.sankalpamText,
      voice: widget.voice ?? TtsVoice(lang),
      timeScale: widget.timeScale ?? PoojaScreen.debugTimeScale,
    );
    if (widget.useSensors ?? PoojaScreen.debugUseSensors) {
      try {
        _accel = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
          (e) => _session.recognizer.accel(e.x, e.y, e.z, _clock.elapsedMicroseconds / 1e6),
          onError: (_) {},
          cancelOnError: true,
        );
      } catch (_) {}
    }
    // let the sanctum subscribe first, then begin
    WidgetsBinding.instance.addPostFrameCallback((_) => _session.start());
  }

  @override
  void dispose() {
    _accel?.cancel();
    _session.end();
    _session.dispose();
    super.dispose();
  }

  String Function(AppLocalizations) _hint(PoojaAction a) => switch (a) {
        PoojaAction.tap => (l) => l.hintTap,
        PoojaAction.dragCircle => (l) => l.hintCircle,
        PoojaAction.shower => (l) => l.hintShower,
        PoojaAction.pour => (l) => l.hintPour,
        PoojaAction.swipeDown => (l) => l.hintSwipeDown,
        PoojaAction.shake => (l) => l.hintShake,
        PoojaAction.blow => (l) => l.hintBlow,
        PoojaAction.walkAround => (l) => l.hintWalk,
        PoojaAction.archana => (l) => l.hintArchana,
        PoojaAction.none => (l) => l.beingPerformed,
      };

  String _liquid(AppLocalizations l, String id) => switch (id) {
        'water' => l.liquidWater,
        'milk' => l.liquidMilk,
        'panchamrutam' => l.liquidPanchamrutam,
        'ghee' => l.liquidGhee,
        _ => id,
      };

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0A06),
        body: ListenableBuilder(
          listenable: _session,
          builder: (context, _) => Stack(children: [
            // The sanctum keeps a temple-like 3:4 frame above the HUD.
            Positioned(
              top: MediaQuery.paddingOf(context).top + 96,
              left: 0,
              right: 0,
              bottom: 250,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRect(child: PlaceholderSanctum(bridge: _bridge, deity: widget.deity, recognizer: () => _session.recognizer)),
                ),
              ),
            ),
            Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: _topBar(context))),
            Positioned(left: 0, right: 0, bottom: 0, child: _session.status == PoojaStatus.completed ? _complete(context) : _hud(context)),
          ]),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final s = _session;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton(
            key: const Key('pooja-close'),
            tooltip: context.l.endPooja,
            icon: const Icon(Icons.close, color: K.goldSoft),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(context.t(widget.vidhanam.name),
                style: tt.titleMedium?.copyWith(color: K.goldSoft), overflow: TextOverflow.ellipsis),
          ),
          if (s.status != PoojaStatus.completed)
            Text(context.l.stepOf(s.stepIndex + 1, s.stepCount), style: tt.labelMedium?.copyWith(color: K.goldSoft)),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: s.overallProgress,
              minHeight: 3,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(K.goldBright),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 12, top: 8), child: PlaceholderChip(context.l.placeholderSanctum)),
      ]),
    );
  }

  Widget _hud(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final s = _session;
    final step = s.step;
    final watching = s.mode == PoojaMode.watch || step.action == PoojaAction.none;
    final paused = s.status == PoojaStatus.paused;
    final archana = step.action == PoojaAction.archana && step.names.isNotEmpty;
    final mantra = step.mantra.of(context.app.lang);
    final onDark = tt.bodyMedium?.copyWith(color: Colors.white);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, K.maroonDeep.withValues(alpha: 0.92), K.maroonDeep],
          stops: const [0, 0.18, 1],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          BiL(step.title, style: tt.headlineSmall?.copyWith(color: K.goldSoft), secondaryColor: Colors.white70),
          const SizedBox(height: 8),
          if (archana) ...[
            Text(context.l.nameOf(s.nameIndex + 1, step.names.length), style: tt.labelMedium?.copyWith(color: K.goldSoft)),
            const SizedBox(height: 4),
            Text(step.names[s.nameIndex].script,
                key: const Key('archana-name'),
                style: tt.headlineSmall?.copyWith(color: Colors.white, fontFamily: K.teluguSerif)),
            Text(step.names[s.nameIndex].translit, style: tt.bodySmall?.copyWith(color: Colors.white70)),
          ] else if (step.upachara == 'sankalpam' && widget.sankalpamText.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(child: Text(widget.sankalpamText, style: onDark?.copyWith(height: 1.5))),
            )
          else ...[
            if (!watching) Text(context.t(step.instruction), style: onDark),
            if (mantra.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(mantra, style: tt.titleMedium?.copyWith(color: K.goldSoft, fontFamily: K.teluguSerif, height: 1.5)),
            ],
          ],
          if (step.options.isNotEmpty && !watching) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              for (final o in step.options)
                ChoiceChip(
                  key: Key('option-$o'),
                  selected: s.chosenOption == o,
                  onSelected: (_) => s.chooseOption(o),
                  label: Text(_liquid(context.l, o)),
                ),
            ]),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Icon(watching ? Icons.visibility_outlined : Icons.touch_app_outlined, color: K.goldBright, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                watching ? context.l.beingPerformed : _hint(step.action)(context.l),
                key: const Key('gesture-hint'),
                style: tt.labelLarge?.copyWith(color: K.goldBright),
              ),
            ),
            if (!watching && step.target > 1)
              Text(context.l.countOf(s.actionsDone, step.target), style: tt.labelLarge?.copyWith(color: Colors.white)),
          ]),
          if (!watching && s.stepProgress > 0) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(value: s.stepProgress, minHeight: 2, backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(K.saffron)),
          ],
          const SizedBox(height: 14),
          Row(children: [
            if (!watching)
              Expanded(
                child: FilledButton.tonal(
                  key: const Key('do-for-me'),
                  onPressed: s.performForMe,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: K.goldSoft, foregroundColor: K.maroonDeep),
                  child: Text(context.l.doItForMe),
                ),
              ),
            if (!watching) const SizedBox(width: 10),
            OutlinedButton.icon(
              key: const Key('pause'),
              onPressed: paused ? s.resume : s.pause,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), foregroundColor: Colors.white, side: const BorderSide(color: K.goldSoft)),
              icon: Icon(paused ? Icons.play_arrow : Icons.pause),
              label: Text(paused ? context.l.resume : context.l.pause),
            ),
            if (watching) const Spacer(),
            const SizedBox(width: 10),
            _ModeSwitch(session: s),
          ]),
        ]),
      ),
    );
  }

  Widget _complete(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final god = context.t(widget.deity.name);
    return Container(
      color: K.maroonDeep.withValues(alpha: 0.94),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.local_florist, color: K.goldBright, size: 34),
          const SizedBox(height: 10),
          Bi((l) => l.poojaComplete, style: tt.headlineSmall?.copyWith(color: K.goldSoft), align: CrossAxisAlignment.center,
              secondaryColor: Colors.white70),
          const SizedBox(height: 8),
          Text(context.l.poojaCompleteMsg(god), textAlign: TextAlign.center, style: tt.bodyLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(context.t(widget.deity.closingName), textAlign: TextAlign.center, style: tt.bodySmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 18),
          FilledButton(
            key: const Key('pooja-done'),
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: K.goldBright, foregroundColor: K.maroonDeep),
            child: Text(context.l.backToToday),
          ),
        ]),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.session});
  final PoojaSession session;
  @override
  Widget build(BuildContext context) {
    final watch = session.mode == PoojaMode.watch;
    return IconButton.filled(
      key: const Key('switch-mode'),
      tooltip: watch ? context.l.modeHandsOn : context.l.modeWatch,
      style: IconButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: K.goldSoft, minimumSize: const Size(52, 52)),
      onPressed: () => session.switchMode(watch ? PoojaMode.handsOn : PoojaMode.watch),
      icon: Icon(watch ? Icons.back_hand_outlined : Icons.visibility_outlined),
    );
  }
}
