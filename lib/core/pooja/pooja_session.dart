/// Pooja state machine shared by Hands-on and Watch modes.
///
/// The voice guide WAITS at each step: in Hands-on mode a step only completes
/// when the sanctum reports the required number of actions. In Watch Mode the
/// session asks the sanctum to auto-perform and advances on its report (or a
/// timer if the renderer is silent).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../content/models.dart';
import 'sanctum_bridge.dart';

enum PoojaMode { handsOn, watch }

enum PoojaStatus { notStarted, running, paused, closing, completed }

/// Global gate: while any pooja is active, no notifications may fire.
class NotificationGate {
  NotificationGate._();
  static final ValueNotifier<bool> poojaActive = ValueNotifier(false);
  static bool get allowNotifications => !poojaActive.value;
}

class PoojaSession extends ChangeNotifier {
  PoojaSession({
    required this.deity,
    required this.vidhanam,
    required this.mode,
    required this.bridge,
    this.timeScale = 1.0,
  }) {
    _sub = bridge.events.listen(_onEvent);
  }

  final DeityPack deity;
  final PoojaVidhanam vidhanam;
  PoojaMode mode;
  final SanctumBridge bridge;

  /// Watch Mode timing multiplier (tests use small values).
  final double timeScale;

  late final StreamSubscription<SanctumEvent> _sub;
  PoojaStatus status = PoojaStatus.notStarted;
  int stepIndex = 0;
  int actionsDone = 0;
  double stepProgress = 0;
  String? chosenOption;
  Timer? _autoTimer;

  PoojaStep get step => vidhanam.steps[stepIndex];
  int get stepCount => vidhanam.steps.length;
  bool get isLastStep => stepIndex == stepCount - 1;
  double get overallProgress => (stepIndex + (actionsDone / step.target).clamp(0, 1)) / stepCount;

  Future<void> start() async {
    status = PoojaStatus.running;
    NotificationGate.poojaActive.value = true;
    bridge.send(SanctumCommand.loadSanctum(deity.sceneId, alankaram: 'daily'));
    _enterStep();
    notifyListeners();
  }

  void _enterStep() {
    actionsDone = 0;
    stepProgress = 0;
    chosenOption = step.options.isNotEmpty ? step.options.first : null;
    _autoTimer?.cancel();
    if (step.upachara == 'closing') status = PoojaStatus.closing;
    if (mode == PoojaMode.watch || step.action == PoojaAction.none) {
      bridge.send(SanctumCommand.autoPerform(step.upachara, option: chosenOption));
      final ms = (step.autoDurationSec * 1000 * timeScale).round();
      _autoTimer = Timer(Duration(milliseconds: ms), () => _complete());
    } else {
      bridge.send(SanctumCommand.beginStep(step.upachara, action: step.action, target: step.target, option: chosenOption));
    }
  }

  void chooseOption(String option) {
    chosenOption = option;
    bridge.send(SanctumCommand.beginStep(step.upachara, action: step.action, target: step.target, option: option));
    notifyListeners();
  }

  void _onEvent(SanctumEvent e) {
    if (status != PoojaStatus.running && status != PoojaStatus.closing) return;
    if (e.upachara != null && e.upachara != step.upachara) return;
    switch (e.type) {
      case SanctumEventType.actionDone:
        if (mode == PoojaMode.watch) return; // timer drives watch mode
        actionsDone++;
        if (actionsDone >= step.target) {
          _complete();
        } else {
          notifyListeners();
        }
      case SanctumEventType.progress:
        stepProgress = e.value ?? 0;
        notifyListeners();
      default:
        break;
    }
  }

  /// Elder-friendly escape hatch: perform this step for me.
  void performForMe() {
    if (status != PoojaStatus.running && status != PoojaStatus.closing) return;
    bridge.send(SanctumCommand.autoPerform(step.upachara, option: chosenOption));
    _autoTimer?.cancel();
    final ms = (step.autoDurationSec * 500 * timeScale).round();
    _autoTimer = Timer(Duration(milliseconds: ms), _complete);
  }

  void switchMode(PoojaMode m) {
    if (m == mode) return;
    mode = m;
    if (status == PoojaStatus.running) _enterStep();
    notifyListeners();
  }

  void pause() {
    if (status != PoojaStatus.running) return;
    _autoTimer?.cancel();
    status = PoojaStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (status != PoojaStatus.paused) return;
    status = PoojaStatus.running;
    _enterStep();
    notifyListeners();
  }

  void _complete() {
    _autoTimer?.cancel();
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
    _autoTimer?.cancel();
    if (status != PoojaStatus.completed) {
      status = PoojaStatus.completed;
      bridge.send(const SanctumCommand('closeSanctum', {}));
    }
    NotificationGate.poojaActive.value = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _sub.cancel();
    NotificationGate.poojaActive.value = false;
    super.dispose();
  }
}
