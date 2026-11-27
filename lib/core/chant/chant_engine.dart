/// Chant-along engine (Grantham, sample 4): karaoke line timing, Sung and
/// slow Learn modes, repeat-line ×11/21/108, and the japa mala counter.
///
/// Pure Dart: time is fed in through [advance], so the same engine runs on
/// a Flutter ticker, on the licensed audio player's position stream once
/// recordings land (cue points per line: TextLine.tSung / tLearn), and in
/// tests. Until a recording exists, line timing is estimated from the text
/// and the voice guide may read each line (flagged "recording coming soon").
library;

import 'package:flutter/foundation.dart';

import '../content/models.dart';

enum ChantMode { sung, learn }

/// Japa / mala counter: 108 beads per mala, target 108 or 1,008.
class JapaCounter extends ChangeNotifier {
  JapaCounter({this.target = 108, int initial = 0}) : _count = initial;

  static const beadsPerMala = 108;
  int target;
  int _count;

  int get count => _count;

  /// Bead position within the current mala (0..107).
  int get bead => _count % beadsPerMala;
  int get malas => _count ~/ beadsPerMala;
  bool get reachedTarget => _count >= target;
  double get progress => (_count / target).clamp(0, 1);

  /// One bead. Returns true when this bead completes a mala.
  bool tap() {
    _count++;
    notifyListeners();
    return _count % beadsPerMala == 0;
  }

  void setTarget(int t) {
    target = t;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

class ChantEngine extends ChangeNotifier {
  ChantEngine({required this.lines, this.mode = ChantMode.sung, this.repeat = 1, JapaCounter? japa, this.onLineStart})
      : japa = japa ?? JapaCounter();

  final List<TextLine> lines;
  ChantMode mode;

  /// How many times each line is chanted before moving on (1, 11, 21, 108).
  int repeat;
  final JapaCounter japa;

  /// When true, each completed repetition also counts one japa bead.
  bool countRepeatsOnMala = false;

  /// Called at the start of every line repetition (voice guide hook).
  void Function(TextLine line, int index)? onLineStart;

  int lineIndex = 0;
  int repeatIndex = 0; // 0-based
  double _t = 0; // seconds into the current repetition
  bool playing = false;
  bool finished = false;

  static const repeatChoices = [1, 11, 21, 108];

  TextLine get line => lines[lineIndex];

  /// Karaoke fill of the current line, 0..1.
  double get lineProgress => (_t / lineDuration(lineIndex)).clamp(0, 1);

  /// Seconds for one repetition of line [i] in the current mode: the
  /// recording's cue points when present, else an estimate from the text.
  /// Learn Mode is slower and leaves a pause to repeat after the voice.
  double lineDuration(int i) {
    final l = lines[i];
    final cue = mode == ChantMode.sung ? l.tSung : (l.tLearn ?? l.tSung);
    if (cue != null) {
      final d = (cue.$2 - cue.$1) / 1000;
      return mode == ChantMode.learn && l.tLearn == null ? d * 2 : d;
    }
    final syllables = estimateSyllables(l.translit.isNotEmpty ? l.translit : l.script);
    final sung = (syllables * 0.32).clamp(2.0, 14.0);
    return mode == ChantMode.sung ? sung : sung * 1.8 + 1.5;
  }

  /// Vowel groups in the transliteration (a rough syllable count).
  static int estimateSyllables(String s) {
    final m = RegExp('[aeiouAEIOU]+').allMatches(s).length;
    return m == 0 ? (s.length / 3).ceil() : m;
  }

  void play() {
    if (lines.isEmpty) return;
    if (finished) restart();
    playing = true;
    if (_t == 0) onLineStart?.call(line, lineIndex);
    notifyListeners();
  }

  void pause() {
    playing = false;
    notifyListeners();
  }

  void toggle() => playing ? pause() : play();

  void restart() {
    lineIndex = 0;
    repeatIndex = 0;
    _t = 0;
    finished = false;
  }

  void setMode(ChantMode m) {
    mode = m;
    _t = 0;
    notifyListeners();
  }

  void setRepeat(int n) {
    repeat = n;
    repeatIndex = repeatIndex.clamp(0, n - 1);
    notifyListeners();
  }

  void seekLine(int i) {
    lineIndex = i.clamp(0, lines.length - 1);
    repeatIndex = 0;
    _t = 0;
    finished = false;
    if (playing) onLineStart?.call(line, lineIndex);
    notifyListeners();
  }

  void next() => seekLine(lineIndex + 1);
  void previous() => seekLine(lineIndex - 1);

  /// Advances time by [seconds] (from a ticker, or the audio position).
  void advance(double seconds) {
    if (!playing || lines.isEmpty) return;
    _t += seconds;
    var changed = false;
    while (playing && _t >= lineDuration(lineIndex)) {
      _t -= lineDuration(lineIndex);
      changed = true;
      if (countRepeatsOnMala) japa.tap();
      if (repeatIndex + 1 < repeat) {
        repeatIndex++;
      } else if (lineIndex + 1 < lines.length) {
        repeatIndex = 0;
        lineIndex++;
      } else {
        playing = false;
        finished = true;
        _t = 0;
        break;
      }
      onLineStart?.call(line, lineIndex);
    }
    if (changed || playing) notifyListeners();
  }
}
