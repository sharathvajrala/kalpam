import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/core/content/models.dart';
import 'package:kalpam/pooja_engine/gestures.dart';

class _Rec {
  int actions = 0;
  final progress = <double>[];
  final effects = <String>[];
  late final sink = GestureSink(onAction: () => actions++, onProgress: progress.add, onEffect: effects.add);
}

/// Points on a circle around the idol; [dir] 1 = clockwise on screen.
void _circle(UpacharaRecognizer r, {double turns = 1, int dir = 1, double radius = 0.2}) {
  r.down(Vec(0.5 + radius, 0.5), 0);
  final n = (64 * turns).round();
  for (var i = 1; i <= n; i++) {
    final a = dir * i * 2 * math.pi / 64;
    r.move(Vec(0.5 + radius * math.cos(a), 0.5 + radius * math.sin(a)), i / 64);
  }
  r.up(const Vec(0.7, 0.5), 2);
}

void main() {
  test('forAction maps every pooja action', () {
    final r = _Rec();
    for (final a in PoojaAction.values) {
      expect(UpacharaRecognizer.forAction(a, r.sink), isA<UpacharaRecognizer>());
    }
    expect(UpacharaRecognizer.forAction(PoojaAction.dragCircle, r.sink), isA<CircleRecognizer>());
    expect(UpacharaRecognizer.forAction(PoojaAction.archana, r.sink), isA<ArchanaRecognizer>());
  });

  test('aarti: one action per clockwise circle, counter-clockwise ignored', () {
    final r = _Rec();
    final c = CircleRecognizer(r.sink);
    _circle(c, turns: 3.05);
    expect(r.actions, 3);
    _circle(c, turns: 2, dir: -1);
    expect(r.actions, 3, reason: 'anticlockwise does not count');
    expect(r.effects.first, startsWith('plate:'));
  });

  test('aarti: jitter at the centre is ignored', () {
    final r = _Rec();
    final c = CircleRecognizer(r.sink);
    _circle(c, turns: 2, radius: 0.03);
    expect(r.actions, 0);
  });

  test('flower shower needs a real upward swipe', () {
    final r = _Rec();
    final s = ShowerRecognizer(r.sink);
    s.down(const Vec(0.5, 0.8), 0);
    s.move(const Vec(0.5, 0.75), 0.1);
    s.up(const Vec(0.5, 0.74), 0.2);
    expect(r.actions, 0);
    s.down(const Vec(0.5, 0.8), 1);
    s.move(const Vec(0.5, 0.6), 1.1);
    s.up(const Vec(0.5, 0.5), 1.2);
    expect(r.actions, 1);
    expect(r.effects, contains('flowers:25'));
  });

  test('abhishekam fills by dragging down', () {
    final r = _Rec();
    final p = PourRecognizer(r.sink);
    p.down(const Vec(0.5, 0.1), 0);
    for (var y = 0.15; y <= 0.86; y += 0.05) {
      p.move(Vec(0.5, y), y);
    }
    expect(r.actions, 1);
    expect(r.progress.reduce(math.max), closeTo(1, 1e-9));
  });

  test('abhishekam fills by tilting the phone for 3 seconds', () {
    final r = _Rec();
    final p = PourRecognizer(r.sink);
    // tilted ~60° forward: gravity mostly on z
    for (var t = 0.0; t <= 3.2; t += 0.1) {
      p.accel(0, 9.81 * math.cos(60 * math.pi / 180), 9.81 * math.sin(60 * math.pi / 180), t);
    }
    expect(r.actions, 1);
    final upright = _Rec();
    final q = PourRecognizer(upright.sink);
    for (var t = 0.0; t <= 5; t += 0.1) {
      q.accel(0, 9.81, 0, t);
    }
    expect(upright.actions, 0, reason: 'upright phone never pours');
  });

  test('coconut breaks on a firm downward swipe (distance or speed)', () {
    final r = _Rec();
    final s = SwipeDownRecognizer(r.sink);
    s.down(const Vec(0.5, 0.3), 0);
    s.up(const Vec(0.5, 0.35), 0.1);
    expect(r.actions, 0);
    s.down(const Vec(0.5, 0.3), 1);
    s.up(const Vec(0.5, 0.35), 1.05, velocity: const Vec(0, 2));
    expect(r.actions, 1);
    s.down(const Vec(0.5, 0.3), 2);
    s.up(const Vec(0.5, 0.55), 2.4);
    expect(r.actions, 2);
  });

  test('bell: shake peaks are debounced; tap fallback works', () {
    final r = _Rec();
    final b = ShakeRecognizer(r.sink);
    b.accel(0, 9.81, 0, 0);
    expect(r.actions, 0);
    b.accel(20, 15, 0, 0.1);
    b.accel(-20, 15, 0, 0.2); // same swing
    expect(r.actions, 1);
    b.accel(20, 15, 0, 0.6);
    expect(r.actions, 2);
    b.tap(const Vec(0.5, 0.5));
    expect(r.actions, 3);
    expect(r.effects.where((e) => e == 'bell').length, 3);
  });

  test('shankh: sustained blow or a long hold', () {
    final r = _Rec();
    final s = BlowRecognizer(r.sink);
    s.mic(0.8, 0);
    s.mic(0.8, 0.3);
    s.mic(0.1, 0.4); // breath broke
    s.mic(0.8, 0.5);
    s.mic(0.8, 0.9);
    expect(r.actions, 0);
    s.mic(0.8, 1.2);
    s.mic(0.8, 1.5);
    expect(r.actions, 1, reason: 'one blow = one shankh');
    s.holdStart(3);
    s.holdEnd(3.3);
    expect(r.actions, 1, reason: 'short hold');
    s.holdStart(4);
    s.holdEnd(5);
    expect(r.actions, 2);
  });

  test('pradakshina: 1.5 screen widths of sweeping = one round', () {
    final r = _Rec();
    final w = WalkAroundRecognizer(r.sink);
    w.down(const Vec(0.1, 0.5), 0);
    for (var i = 0; i < 3; i++) {
      w.move(const Vec(0.9, 0.5), i + 0.5);
      w.move(const Vec(0.1, 0.5), i + 1.0);
    }
    expect(r.actions, 3, reason: '4.8 widths');
  });

  test('archana: each tap or flick offers one flower', () {
    final r = _Rec();
    final a = ArchanaRecognizer(r.sink);
    a.tap(const Vec(0.5, 0.5));
    a.down(const Vec(0.5, 0.7), 0);
    a.up(const Vec(0.5, 0.55), 0.2);
    a.down(const Vec(0.5, 0.7), 1);
    a.up(const Vec(0.5, 0.68), 1.2); // too small
    expect(r.actions, 2);
    expect(r.effects, ['flowers:1', 'flowers:1']);
  });
}
