/// Bhajan playlist: a queue of bhajans played one after another, each with
/// karaoke lyrics through [ChantEngine]. Season playlists (the flagship's
/// bhajan set) and per-god lists use the same controller. Audio-agnostic:
/// the licensed player will feed positions in through [advance] too.
library;

import 'package:flutter/foundation.dart';

import '../content/models.dart';
import 'chant_engine.dart';

class BhajanPlaylist extends ChangeNotifier {
  BhajanPlaylist(this.items, {int start = 0, this.loop = false, this.onLineStart}) : index = start.clamp(0, items.length - 1) {
    _load();
  }

  final List<BhajanItem> items;
  int index;
  bool loop;
  void Function(TextLine line, int index)? onLineStart;
  late ChantEngine engine;
  bool finished = false;

  BhajanItem get current => items[index];
  bool get playing => engine.playing;

  void _load() {
    engine = ChantEngine(lines: current.lyrics, onLineStart: onLineStart)..addListener(_onEngine);
  }

  void _onEngine() => notifyListeners();

  /// Moves to the next bhajan once the current one ends (outside the
  /// engine's own notification, so the old engine can be disposed safely).
  void _afterTick() {
    if (!engine.finished || finished) return;
    if (index + 1 < items.length) {
      _goTo(index + 1, autoplay: true);
    } else if (loop) {
      _goTo(0, autoplay: true);
    } else {
      finished = true;
      notifyListeners();
    }
  }

  void _goTo(int i, {required bool autoplay}) {
    engine.removeListener(_onEngine);
    engine.dispose();
    index = i;
    finished = false;
    _load();
    if (autoplay) engine.play();
    notifyListeners();
  }

  void play() {
    if (finished) _goTo(0, autoplay: true);
    engine.play();
  }

  void toggle() => engine.playing ? engine.pause() : play();
  void next() => _goTo((index + 1) % items.length, autoplay: engine.playing);
  void previous() => _goTo((index - 1 + items.length) % items.length, autoplay: engine.playing);
  void jumpTo(int i) => _goTo(i, autoplay: true);

  void setLoop(bool v) {
    loop = v;
    notifyListeners();
  }

  void advance(double seconds) {
    engine.advance(seconds);
    _afterTick();
  }

  @override
  void dispose() {
    engine.removeListener(_onEngine);
    engine.dispose();
    super.dispose();
  }
}
