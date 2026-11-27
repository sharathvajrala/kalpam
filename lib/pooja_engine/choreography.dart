/// Watch Mode choreography: for every upachara, a timeline of cues the
/// sanctum performs by itself, like a temple deeparadhana. The same cue
/// vocabulary is what the Unity sanctum implements (ARCHITECTURE.md).
library;

import '../core/content/models.dart';

enum CueType {
  /// Voice guide / chant line.
  speak,
  lightLamp,
  flowers,
  aartiCircle,
  dhoopCircle,
  pour,
  coconut,
  bell,
  shankh,
  walkAround,
  offerTray,
  drape,
  highlightName,
  curtainsClose,
  playClosingAudio,
  focusIdol,
}

class Cue {
  const Cue(this.at, this.type, [this.arg]);

  /// Seconds from the start of the step.
  final double at;
  final CueType type;
  final Object? arg;

  @override
  String toString() => 'Cue(${at.toStringAsFixed(1)}s ${type.name}${arg == null ? '' : ' $arg'})';
}

class StepTimeline {
  const StepTimeline(this.cues, this.duration);
  final List<Cue> cues;
  final double duration;
}

class WatchChoreography {
  const WatchChoreography();

  /// Timeline for [step] in Watch Mode. [closingType] comes from the deity
  /// pack ("curtains" for Ayyappa: nada closes as Harivarasanam plays).
  StepTimeline forStep(PoojaStep step, {required String closingType, String? option}) {
    final d = step.autoDurationSec.toDouble();
    final cues = <Cue>[const Cue(0, CueType.speak, 'mantra'), const Cue(0, CueType.focusIdol)];
    void repeat(CueType t, int n, double start, double gap, [Object? arg]) {
      for (var i = 0; i < n; i++) {
        cues.add(Cue(start + i * gap, t, arg));
      }
    }

    switch (step.upachara) {
      case 'deepam':
        cues.add(Cue(d * 0.25, CueType.lightLamp));
      case 'pushpam' || 'mantrapushpam':
        repeat(CueType.flowers, step.target.clamp(1, 5), d * 0.15, d * 0.25, 20);
      case 'dhoopam':
        repeat(CueType.dhoopCircle, step.target, d * 0.1, d * 0.28);
      case 'aarti':
        cues.add(Cue(d * 0.02, CueType.bell));
        repeat(CueType.aartiCircle, step.target, d * 0.1, d * 0.28);
      case 'abhishekam':
        cues.add(Cue(d * 0.1, CueType.pour, option ?? 'water'));
      case 'coconut':
        cues.add(Cue(d * 0.4, CueType.coconut));
      case 'bell':
        repeat(CueType.bell, step.target, d * 0.1, d * 0.25);
      case 'shankh':
        cues.add(Cue(d * 0.15, CueType.shankh));
      case 'pradakshina':
        repeat(CueType.walkAround, step.target, d * 0.05, d * 0.31);
      case 'naivedyam' || 'tambulam':
        cues.add(Cue(d * 0.3, CueType.offerTray, step.upachara));
      case 'vastram' || 'yagnopavitam':
        cues.add(Cue(d * 0.3, CueType.drape, step.upachara));
      case 'archana':
        final gap = step.names.isEmpty ? d : d / step.names.length;
        for (var i = 0; i < step.names.length; i++) {
          cues.add(Cue(i * gap, CueType.highlightName, i));
          cues.add(Cue(i * gap + gap * 0.4, CueType.flowers, 1));
        }
      case 'closing':
        if (closingType == 'curtains') {
          cues.add(const Cue(0, CueType.playClosingAudio));
          cues.add(Cue(d * 0.3, CueType.curtainsClose));
        } else {
          cues.add(const Cue(0, CueType.bell));
          cues.add(Cue(d * 0.1, CueType.aartiCircle));
          cues.add(const Cue(0, CueType.playClosingAudio));
        }
    }
    cues.sort((a, b) => a.at.compareTo(b.at));
    return StepTimeline(cues, d);
  }

  /// Effect a hands-on action leaves in the scene, so both modes look alike.
  static CueType? effectOfAction(String upachara) => switch (upachara) {
        'deepam' => CueType.lightLamp,
        'pushpam' || 'mantrapushpam' => CueType.flowers,
        'coconut' => CueType.coconut,
        'bell' => CueType.bell,
        'shankh' => CueType.shankh,
        'naivedyam' || 'tambulam' => CueType.offerTray,
        'vastram' || 'yagnopavitam' => CueType.drape,
        _ => null,
      };
}
