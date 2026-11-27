/// Pooja state machine shared by Hands-on and Watch modes.
///
/// * Hands-on: the voice guide speaks the instruction, then WAITS. The step
///   completes only after the required number of actions, recognised either
///   by [recognizer] (raw input from the Flutter sanctum) or reported by the
///   3D engine as `actionDone`.
/// * Watch Mode: the step's [WatchChoreography] timeline is sent to the
///   sanctum cue by cue; the step completes when the timeline ends.
///
/// Every pooja opens with the spoken Sankalpam and ends with the god's
/// closing. No points or streaks exist in here (reverence rule).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/content/models.dart';
import 'choreography.dart';
import 'gestures.dart';
import 'sanctum_bridge.dart';

enum PoojaMode { handsOn, watch }

enum PoojaStatus { notStarted, running, paused, closing, completed }

/// Global gate: while any pooja is active, no notifications may fire.
class NotificationGate {
  NotificationGate._();
  static final ValueNotifier<bool> poojaActive = ValueNotifier(false);
  static bool get allowNotifications => !poojaActive.value;
}

/// Where spoken guidance goes (device TTS today, recorded voice later).
abstract class VoicePort {
  void speak(String text);
  void stop();
}

class SilentVoice implements VoicePort {
  final List<String> log = [];
  @override
  void speak(String text) => log.add(text);
  @override
  void stop() {}
}

class PoojaSession extends ChangeNotifier {
  PoojaSession({
    required this.deity,
    required this.vidhanam,
    required this.mode,
    required this.bridge,
    required this.lang,
    this.sankalpamText = '',
    VoicePort? voice,
    this.timeScale = 1.0,
    this.choreography = const WatchChoreography(),
  }) : voice = voice ?? SilentVoice() {
    _sub = bridge.events.listen(_onEvent);
  }

  final DeityPack deity;
  final PoojaVidhanam vidhanam;
  PoojaMode mode;
  final SanctumBridge bridge;
  final String lang;

  /// Generated for the active family profile, city and day.
  final String sankalpamText;
  final VoicePort voice;

  /// Watch Mode timing multiplier (tests use small values).
  final double timeScale;
  final WatchChoreography choreography;

  late final StreamSubscription<SanctumEvent> _sub;
  PoojaStatus status = PoojaStatus.notStarted;
  int stepIndex = 0;
  int actionsDone = 0;
  double stepProgress = 0;
  String? chosenOption;
  final List<Timer> _timers = [];
  late UpacharaRecognizer recognizer = NoopRecognizer(GestureSink(onAction: () {}));

  PoojaStep get step => vidhanam.steps[stepIndex];
  int get stepCount => vidhanam.steps.length;
  bool get isLastStep => stepIndex == stepCount - 1;
  bool get isActive => status == PoojaStatus.running || status == PoojaStatus.closing;
  double get overallProgress => (stepIndex + (actionsDone / step.target).clamp(0, 1)) / stepCount;

  /// Archana: index of the name being offered now.
  int get nameIndex => step.names.isEmpty ? 0 : actionsDone.clamp(0, step.names.length - 1);

  Future<void> start() async {
    status = PoojaStatus.running;
    NotificationGate.poojaActive.value = true;
    bridge.send(SanctumCommand.loadSanctum(deity.sceneId, alankaram: 'daily'));
    _enterStep();
    notifyListeners();
  }

  void _cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  void _after(double seconds, void Function() f) =>
      _timers.add(Timer(Duration(milliseconds: (seconds * 1000 * timeScale).round()), f));

  String _spokenFor(PoojaStep s) {
    if (s.upachara == 'sankalpam' && sankalpamText.isNotEmpty) return sankalpamText;
    final m = s.mantra.of(lang);
    if (mode == PoojaMode.watch) return m.isNotEmpty ? m : s.title.of(lang);
    final i = s.instruction.of(lang);
    return m.isEmpty ? i : '$i $m';
  }

  void _enterStep() {
    _cancelTimers();
    actionsDone = 0;
    stepProgress = 0;
    chosenOption = step.options.isNotEmpty ? step.options.first : null;
    if (step.upachara == 'closing') status = PoojaStatus.closing;
    voice.speak(_spokenFor(step));

    if (mode == PoojaMode.watch || step.action == PoojaAction.none) {
      recognizer = NoopRecognizer(GestureSink(onAction: () {}));
      _playTimeline();
    } else {
      recognizer = UpacharaRecognizer.forAction(
        step.action,
        GestureSink(
          onAction: _registerAction,
          onProgress: (v) {
            stepProgress = v;
            bridge.emit(SanctumEvent(SanctumEventType.progress, upachara: step.upachara, value: v));
            notifyListeners();
          },
          onEffect: (e) => bridge.send(SanctumCommand('effect', {'upachara': step.upachara, 'effect': e})),
        ),
      );
      bridge.send(SanctumCommand.beginStep(step.upachara, action: step.action, target: step.target, option: chosenOption));
    }
  }

  void _playTimeline() {
    bridge.send(SanctumCommand.autoPerform(step.upachara, option: chosenOption));
    final tl = choreography.forStep(step, closingType: deity.closingType, option: chosenOption);
    for (final c in tl.cues) {
      _after(c.at, () {
        bridge.send(SanctumCommand('cue', {'upachara': step.upachara, 'cue': c.type.name, 'arg': c.arg}));
        if (c.type == CueType.highlightName) {
          actionsDone = c.arg as int;
          notifyListeners();
        }
      });
    }
    _after(tl.duration, _complete);
  }

  void chooseOption(String option) {
    chosenOption = option;
    bridge.send(SanctumCommand.beginStep(step.upachara, action: step.action, target: step.target, option: option));
    notifyListeners();
  }

  void _registerAction() {
    if (!isActive || mode == PoojaMode.watch) return;
    actionsDone++;
    stepProgress = 0;
    final effect = WatchChoreography.effectOfAction(step.upachara);
    if (effect != null) {
      bridge.send(SanctumCommand('cue', {'upachara': step.upachara, 'cue': effect.name, 'arg': null}));
    }
    if (step.action == PoojaAction.archana && actionsDone < step.target) {
      voice.speak(step.names[nameIndex].script);
    }
    if (actionsDone >= step.target) {
      _complete();
    } else {
      notifyListeners();
    }
  }

  void _onEvent(SanctumEvent e) {
    if (!isActive) return;
    if (e.upachara != null && e.upachara != step.upachara) return;
    if (e.type == SanctumEventType.actionDone) _registerAction();
  }

  /// Elder-friendly escape hatch: perform just this step for me.
  void performForMe() {
    if (!isActive) return;
    _cancelTimers();
    _playTimeline();
    notifyListeners();
  }

  void switchMode(PoojaMode m) {
    if (m == mode) return;
    mode = m;
    if (isActive) _enterStep();
    notifyListeners();
  }

  void pause() {
    if (!isActive) return;
    _cancelTimers();
    voice.stop();
    status = PoojaStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (status != PoojaStatus.paused) return;
    status = step.upachara == 'closing' ? PoojaStatus.closing : PoojaStatus.running;
    _enterStep();
    notifyListeners();
  }

  void _complete() {
    _cancelTimers();
    actionsDone = step.target;
    if (isLastStep) {
      status = PoojaStatus.completed;
      NotificationGate.poojaActive.value = false;
      bridge.send(const SanctumCommand('closeSanctum', {}));
    } else {
      stepIndex++;
      _enterStep();
    }
    notifyListeners();
  }

  void end() {
    _cancelTimers();
    voice.stop();
    if (status != PoojaStatus.completed) {
      status = PoojaStatus.completed;
      bridge.send(const SanctumCommand('closeSanctum', {}));
    }
    NotificationGate.poojaActive.value = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimers();
    _sub.cancel();
    NotificationGate.poojaActive.value = false;
    super.dispose();
  }
}
