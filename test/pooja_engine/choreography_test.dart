import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/core/content/localized.dart';
import 'package:kalpam/core/content/models.dart';
import 'package:kalpam/pooja_engine/choreography.dart';

PoojaStep _step(String u, {int target = 1, int dur = 10}) => PoojaStep(
      upachara: u,
      title: const LocalizedText({'en': 'x'}),
      instruction: const LocalizedText({'en': 'x'}),
      mantra: const LocalizedText({'en': ''}),
      voice: MediaRef.none,
      action: PoojaAction.tap,
      target: target,
      autoDurationSec: dur,
    );

void main() {
  const c = WatchChoreography();

  test('every timeline opens with the mantra and stays inside the step', () {
    for (final u in ['deepam', 'pushpam', 'dhoopam', 'aarti', 'abhishekam', 'coconut', 'bell', 'shankh', 'pradakshina',
      'naivedyam', 'vastram', 'namaskaram', 'closing']) {
      final tl = c.forStep(_step(u, target: 3), closingType: 'curtains');
      expect(tl.cues.first.type, CueType.speak, reason: u);
      for (final cue in tl.cues) {
        expect(cue.at, inInclusiveRange(0, tl.duration), reason: '$u $cue');
      }
      for (var i = 1; i < tl.cues.length; i++) {
        expect(tl.cues[i].at, greaterThanOrEqualTo(tl.cues[i - 1].at));
      }
    }
  });

  test('aarti circles match the target and are preceded by the bell', () {
    final tl = c.forStep(_step('aarti', target: 3, dur: 20), closingType: 'aarti');
    expect(tl.cues.where((q) => q.type == CueType.aartiCircle).length, 3);
    final bell = tl.cues.indexWhere((q) => q.type == CueType.bell);
    final first = tl.cues.indexWhere((q) => q.type == CueType.aartiCircle);
    expect(bell, lessThan(first));
  });

  test('abhishekam pours the chosen liquid', () {
    final tl = c.forStep(_step('abhishekam'), closingType: 'aarti', option: 'milk');
    expect(tl.cues.singleWhere((q) => q.type == CueType.pour).arg, 'milk');
  });

  test('Ayyappa closing: Harivarasanam plays, then the curtains close', () {
    final tl = c.forStep(_step('closing', dur: 30), closingType: 'curtains');
    final audio = tl.cues.singleWhere((q) => q.type == CueType.playClosingAudio);
    final curtains = tl.cues.singleWhere((q) => q.type == CueType.curtainsClose);
    expect(audio.at, lessThan(curtains.at));
    final other = c.forStep(_step('closing', dur: 30), closingType: 'aarti');
    expect(other.cues.any((q) => q.type == CueType.curtainsClose), isFalse);
  });

  test('archana: one highlighted name and one flower per name, in order', () {
    final names = List.generate(16, (i) => TextLine(id: 'n$i', script: 'name $i', translit: 'n$i', meaning: const LocalizedText({'en': ''})));
    final step = PoojaStep.archana(title: const LocalizedText({'en': 'Archana'}), instruction: const LocalizedText({'en': 'Offer'}), names: names);
    expect(step.target, 16);
    final tl = c.forStep(step, closingType: 'curtains');
    final hl = tl.cues.where((q) => q.type == CueType.highlightName).toList();
    expect(hl.map((q) => q.arg), List.generate(16, (i) => i));
    expect(tl.cues.where((q) => q.type == CueType.flowers).length, 16);
    expect(hl.last.at, lessThan(tl.duration));
  });

  test('hands-on effects mirror the watch visuals', () {
    expect(WatchChoreography.effectOfAction('deepam'), CueType.lightLamp);
    expect(WatchChoreography.effectOfAction('naivedyam'), CueType.offerTray);
    expect(WatchChoreography.effectOfAction('namaskaram'), isNull);
  });
}
