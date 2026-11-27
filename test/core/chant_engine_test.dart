import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/core/chant/chant_engine.dart';
import 'package:kalpam/core/content/localized.dart';
import 'package:kalpam/core/content/models.dart';

TextLine _l(String tr, {(int, int)? sung, (int, int)? learn}) =>
    TextLine(id: tr, script: tr, translit: tr, meaning: const LocalizedText({'en': ''}), tSung: sung, tLearn: learn);

void main() {
  test('cue points from the recording win over the estimate; Learn is slower', () {
    final e = ChantEngine(lines: [_l('Harivarasanam vishwamohanam', sung: (0, 4000)), _l('Om')]);
    expect(e.lineDuration(0), 4);
    e.setMode(ChantMode.learn);
    expect(e.lineDuration(0), 8, reason: 'no learn cue: twice the sung time');
    expect(e.lineDuration(1), greaterThan(ChantEngine(lines: [_l('Om')]).lineDuration(0)));
  });

  test('plays line by line with karaoke progress and finishes', () {
    final started = <int>[];
    final e = ChantEngine(lines: [_l('a', sung: (0, 1000)), _l('b', sung: (1000, 3000))], onLineStart: (_, i) => started.add(i));
    e.play();
    e.advance(0.5);
    expect(e.lineProgress, closeTo(0.5, 1e-9));
    e.advance(0.6);
    expect(e.lineIndex, 1);
    expect(e.lineProgress, closeTo(0.05, 1e-9));
    e.advance(5);
    expect(e.finished, isTrue);
    expect(e.playing, isFalse);
    expect(started, [0, 1]);
  });

  test('repeat-line ×11 chants each line 11 times and can count beads', () {
    final e = ChantEngine(lines: [_l('a', sung: (0, 1000)), _l('b', sung: (0, 1000))])
      ..setRepeat(11)
      ..countRepeatsOnMala = true;
    e.play();
    for (var i = 0; i < 10; i++) {
      e.advance(1);
    }
    expect(e.lineIndex, 0);
    expect(e.repeatIndex, 10);
    e.advance(1);
    expect(e.lineIndex, 1);
    expect(e.japa.count, 11);
    expect(ChantEngine.repeatChoices, [1, 11, 21, 108]);
  });

  test('japa mala: 108 beads per mala, target 1,008', () {
    final j = JapaCounter(target: 1008);
    var malas = 0;
    for (var i = 0; i < 216; i++) {
      if (j.tap()) malas++;
    }
    expect(malas, 2);
    expect(j.malas, 2);
    expect(j.bead, 0);
    expect(j.reachedTarget, isFalse);
    expect(j.progress, closeTo(216 / 1008, 1e-9));
    j.reset();
    expect(j.count, 0);
  });
}
