/// Gesture recognition for every upachara — pure Dart, no Flutter, so the
/// same logic drives the Flutter placeholder sanctum today and can be
/// unit-tested; the Unity sanctum reports raw input through the same API.
///
/// Coordinates are normalised to the sanctum viewport (0..1 on both axes,
/// y pointing down). Times are seconds.
library;

import 'dart:math' as math;

import '../core/content/models.dart';

class Vec {
  const Vec(this.x, this.y);
  final double x, y;
  Vec operator -(Vec o) => Vec(x - o.x, y - o.y);
  double get length => math.sqrt(x * x + y * y);
  double get angle => math.atan2(y, x);
}

/// Callbacks a recognizer fires.
class GestureSink {
  GestureSink({required this.onAction, this.onProgress, this.onEffect});

  /// One completed action (one aarti circle, one bell ring, one flower...).
  final void Function() onAction;

  /// 0..1 progress within the current action (pour level, circle arc...).
  final void Function(double)? onProgress;

  /// Visual effect hint for the renderer (e.g. 'flowers:12', 'plate:x,y').
  final void Function(String effect)? onEffect;
}

abstract class UpacharaRecognizer {
  UpacharaRecognizer(this.sink);
  final GestureSink sink;

  void tap(Vec p) {}
  void down(Vec p, double t) {}
  void move(Vec p, double t) {}
  void up(Vec p, double t, {Vec velocity = const Vec(0, 0)}) {}
  void holdStart(double t) {}
  void holdEnd(double t) {}

  /// Accelerometer sample in m/s² (including gravity).
  void accel(double x, double y, double z, double t) {}

  /// Normalised microphone level 0..1.
  void mic(double level, double t) {}

  /// Builds the recognizer for a step's action.
  static UpacharaRecognizer forAction(PoojaAction a, GestureSink sink) => switch (a) {
        PoojaAction.tap => TapRecognizer(sink),
        PoojaAction.dragCircle => CircleRecognizer(sink),
        PoojaAction.shower => ShowerRecognizer(sink),
        PoojaAction.pour => PourRecognizer(sink),
        PoojaAction.swipeDown => SwipeDownRecognizer(sink),
        PoojaAction.shake => ShakeRecognizer(sink),
        PoojaAction.blow => BlowRecognizer(sink),
        PoojaAction.walkAround => WalkAroundRecognizer(sink),
        PoojaAction.archana => ArchanaRecognizer(sink),
        PoojaAction.none => NoopRecognizer(sink),
      };
}

class NoopRecognizer extends UpacharaRecognizer {
  NoopRecognizer(super.sink);
}

/// Light the deepam, offer naivedyam, namaskaram…: a tap anywhere.
class TapRecognizer extends UpacharaRecognizer {
  TapRecognizer(super.sink);
  @override
  void tap(Vec p) => sink.onAction();
}

/// Aarti / dhoopam: clockwise circles around the idol. Movement too close to
/// the centre is ignored (jitter), counter-clockwise movement does not count.
class CircleRecognizer extends UpacharaRecognizer {
  CircleRecognizer(super.sink, {this.center = const Vec(0.5, 0.5), this.minRadius = 0.08});
  final Vec center;
  final double minRadius;
  double _accum = 0;
  double? _last;

  @override
  void down(Vec p, double t) => _last = null;

  @override
  void move(Vec p, double t) {
    sink.onEffect?.call('plate:${p.x.toStringAsFixed(3)},${p.y.toStringAsFixed(3)}');
    final r = p - center;
    if (r.length < minRadius) {
      _last = null;
      return;
    }
    final a = r.angle;
    if (_last != null) {
      var d = a - _last!;
      if (d > math.pi) d -= 2 * math.pi;
      if (d < -math.pi) d += 2 * math.pi;
      if (d > 0) _accum += d; // y-down screen space: positive = clockwise
      sink.onProgress?.call((_accum / (2 * math.pi)).clamp(0, 1));
      while (_accum >= 2 * math.pi) {
        _accum -= 2 * math.pi;
        sink.onAction();
      }
    }
    _last = a;
  }
}

/// Flower shower: an upward swipe of at least [minRise] of the screen.
class ShowerRecognizer extends UpacharaRecognizer {
  ShowerRecognizer(super.sink, {this.minRise = 0.15});
  final double minRise;
  Vec? _start;
  @override
  void down(Vec p, double t) => _start = p;
  @override
  void move(Vec p, double t) {
    if (_start != null && p.y < _start!.y) sink.onEffect?.call('flowers:2');
  }

  @override
  void up(Vec p, double t, {Vec velocity = const Vec(0, 0)}) {
    final s = _start;
    _start = null;
    if (s != null && s.y - p.y >= minRise) {
      sink.onEffect?.call('flowers:25');
      sink.onAction();
    }
  }
}

/// Abhishekam: drag the vessel down (or tilt the phone forward) until the
/// pour completes.
class PourRecognizer extends UpacharaRecognizer {
  PourRecognizer(super.sink, {this.dragToFill = 0.6, this.tiltSeconds = 3});
  final double dragToFill;
  final double tiltSeconds;
  double _level = 0;
  Vec? _last;
  double? _lastT;

  void _add(double d) {
    _level = (_level + d).clamp(0, 1);
    sink.onProgress?.call(_level);
    sink.onEffect?.call('pour:${_level.toStringAsFixed(2)}');
    if (_level >= 1) {
      _level = 0;
      sink.onAction();
    }
  }

  @override
  void down(Vec p, double t) => _last = p;
  @override
  void move(Vec p, double t) {
    if (_last != null && p.y > _last!.y) _add((p.y - _last!.y) / dragToFill);
    _last = p;
  }

  @override
  void up(Vec p, double t, {Vec velocity = const Vec(0, 0)}) => _last = null;

  /// Phone tilted forward past ~35° pours steadily.
  @override
  void accel(double x, double y, double z, double t) {
    final dt = _lastT == null ? 0.0 : (t - _lastT!).clamp(0.0, 0.2);
    _lastT = t;
    final g = math.sqrt(x * x + y * y + z * z);
    if (g < 1) return;
    final tilt = math.acos((y / g).clamp(-1.0, 1.0)) * 180 / math.pi; // 0 = upright
    if (tilt > 35 && tilt < 120) _add(dt / tiltSeconds);
  }
}

/// Coconut: a firm downward swipe (distance or speed).
class SwipeDownRecognizer extends UpacharaRecognizer {
  SwipeDownRecognizer(super.sink, {this.minDrop = 0.2, this.minSpeed = 1.2});
  final double minDrop, minSpeed;
  Vec? _start;
  @override
  void down(Vec p, double t) => _start = p;
  @override
  void up(Vec p, double t, {Vec velocity = const Vec(0, 0)}) {
    final s = _start;
    _start = null;
    if (s == null) return;
    if (p.y - s.y >= minDrop || velocity.y >= minSpeed) {
      sink.onEffect?.call('coconut');
      sink.onAction();
    }
  }
}

/// Bell: shake the phone (acceleration peak above gravity), with a tap
/// fallback. Peaks closer than [debounce] count once.
class ShakeRecognizer extends UpacharaRecognizer {
  ShakeRecognizer(super.sink, {this.threshold = 12, this.debounce = 0.35});
  final double threshold, debounce;
  double _lastRing = -99;

  void _ring(double t) {
    if (t - _lastRing < debounce) return;
    _lastRing = t;
    sink.onEffect?.call('bell');
    sink.onAction();
  }

  @override
  void accel(double x, double y, double z, double t) {
    final g = math.sqrt(x * x + y * y + z * z);
    if ((g - 9.81).abs() > threshold) _ring(t);
  }

  /// Tap fallback (no accelerometer, or user prefers tapping).
  @override
  void tap(Vec p) {
    sink.onEffect?.call('bell');
    sink.onAction();
  }
}

/// Shankh: blow into the mic (level above [threshold] for [sustain] seconds),
/// or press-and-hold for [holdSeconds].
class BlowRecognizer extends UpacharaRecognizer {
  BlowRecognizer(super.sink, {this.threshold = 0.55, this.sustain = 0.6, this.holdSeconds = 0.8});
  final double threshold, sustain, holdSeconds;
  double? _blowStart;
  double? _holdStart;
  bool _fired = false;

  void _fire() {
    if (_fired) return;
    _fired = true;
    sink.onEffect?.call('shankh');
    sink.onAction();
  }

  @override
  void mic(double level, double t) {
    if (level >= threshold) {
      _blowStart ??= t;
      sink.onProgress?.call(((t - _blowStart!) / sustain).clamp(0, 1));
      if (t - _blowStart! >= sustain) _fire();
    } else {
      _blowStart = null;
      _fired = false;
    }
  }

  @override
  void holdStart(double t) => _holdStart = t;
  @override
  void holdEnd(double t) {
    final s = _holdStart;
    _holdStart = null;
    if (s != null && t - s >= holdSeconds) {
      sink.onEffect?.call('shankh');
      sink.onAction();
    }
  }
}

/// Pradakshina: horizontal sweeps totalling [widths] screen widths = one round.
class WalkAroundRecognizer extends UpacharaRecognizer {
  WalkAroundRecognizer(super.sink, {this.widths = 1.5});
  final double widths;
  double _accum = 0;
  Vec? _last;
  @override
  void down(Vec p, double t) => _last = p;
  @override
  void move(Vec p, double t) {
    if (_last != null) {
      _accum += (p.x - _last!.x).abs() / widths;
      sink.onProgress?.call(_accum.clamp(0, 1));
      sink.onEffect?.call('walk:${_accum.clamp(0, 1).toStringAsFixed(2)}');
      if (_accum >= 1) {
        _accum = 0;
        sink.onAction();
      }
    }
    _last = p;
  }

  @override
  void up(Vec p, double t, {Vec velocity = const Vec(0, 0)}) => _last = null;
}

/// Archana: each tap (or short upward flick) offers one flower for the
/// current name; the session advances to the next name.
class ArchanaRecognizer extends UpacharaRecognizer {
  ArchanaRecognizer(super.sink);
  Vec? _start;
  void _offer() {
    sink.onEffect?.call('flowers:1');
    sink.onAction();
  }

  @override
  void tap(Vec p) => _offer();
  @override
  void down(Vec p, double t) => _start = p;
  @override
  void up(Vec p, double t, {Vec velocity = const Vec(0, 0)}) {
    final s = _start;
    _start = null;
    if (s != null && s.y - p.y > 0.08) _offer();
  }
}
