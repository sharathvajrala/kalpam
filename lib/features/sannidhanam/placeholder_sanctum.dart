import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/content/models.dart';
import '../../core/pooja/sanctum_bridge.dart';

/// Flutter-drawn stand-in for the Unity sanctum (ASSETS_TODO.md
/// 3d.ayyappa.sanctum). Implements the full [SanctumBridge] protocol:
/// every upachara is interactive in Hands-on mode and animates itself in
/// Watch Mode, so the pooja flow is complete end-to-end today.
class PlaceholderSanctum extends StatefulWidget {
  const PlaceholderSanctum({super.key, required this.bridge, required this.deity});
  final SanctumBridge bridge;
  final DeityPack deity;

  @override
  State<PlaceholderSanctum> createState() => _PlaceholderSanctumState();
}

class _Flower {
  _Flower(this.x, this.y, this.vy, this.spin, this.color);
  double x, y, vy, spin;
  final Color color;
}

class _PlaceholderSanctumState extends State<PlaceholderSanctum> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final StreamSubscription<SanctumCommand> _sub;
  final _rand = math.Random(7);
  Duration _last = Duration.zero;
  double _time = 0;

  // scene state
  String? _upachara;
  PoojaAction _action = PoojaAction.none;
  bool _auto = false;
  String? _option;
  bool _lampLit = false;
  final List<_Flower> _flowers = [];
  Offset? _plate; // aarti / dhoopam position (0..1 space)
  double _circleAngle = 0;
  double? _lastAngle;
  double _pour = 0; // 0..1 abhishekam stream
  double _coconut = 0; // 0 whole -> 1 broken
  double _bellSwing = 0;
  double _shankh = 0;
  double _curtain = 0; // 0 open -> 1 closed
  double _glow = 0;
  double _walk = 0; // pradakshina progress within current round
  double _holdStart = -1;
  double _autoT = 0;
  double _dragAccum = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _sub = widget.bridge.commands.listen(_onCommand);
    // the renderer is ready immediately
    scheduleMicrotask(() => widget.bridge.emit(const SanctumEvent(SanctumEventType.ready)));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sub.cancel();
    super.dispose();
  }

  void _onCommand(SanctumCommand c) {
    switch (c.type) {
      case 'beginStep':
        _upachara = c.payload['upachara'] as String?;
        _action = PoojaAction.values.byName(c.payload['action'] as String);
        _option = c.payload['option'] as String?;
        _auto = false;
        _resetStepVisuals();
      case 'autoPerform':
        _upachara = c.payload['upachara'] as String?;
        _option = c.payload['option'] as String?;
        _auto = true;
        _autoT = 0;
        _resetStepVisuals();
      case 'closeSanctum':
        _upachara = 'closing';
        _auto = true;
    }
  }

  void _resetStepVisuals() {
    _circleAngle = 0;
    _lastAngle = null;
    _pour = 0;
    _walk = 0;
    _dragAccum = 0;
    if (_upachara == 'aarti' || _upachara == 'dhoopam') _plate = const Offset(0.5, 0.62);
    if (_upachara == 'coconut') _coconut = 0;
  }

  void _done() {
    HapticFeedback.lightImpact();
    widget.bridge.emit(SanctumEvent(SanctumEventType.actionDone, upachara: _upachara));
  }

  void _progress(double v) =>
      widget.bridge.emit(SanctumEvent(SanctumEventType.progress, upachara: _upachara, value: v));

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    _time += dt;
    // physics: flowers fall with drag
    for (final f in _flowers) {
      f.vy += 0.35 * dt;
      f.y += f.vy * dt;
      f.x += math.sin(_time * 2 + f.spin) * 0.02 * dt;
    }
    _flowers.removeWhere((f) => f.y > 0.78);
    _bellSwing *= math.pow(0.04, dt).toDouble();
    _shankh = math.max(0, _shankh - dt * 0.6);
    _glow = 0.5 + 0.5 * math.sin(_time * 1.3);

    if (_auto) _autoAnimate(dt);
    if (_upachara == 'closing') _curtain = math.min(1, _curtain + dt * 0.12);
    if (_upachara == 'deepam' && _auto && _autoT > 1.2) _lampLit = true;
    setState(() {});
  }

  void _autoAnimate(double dt) {
    _autoT += dt;
    switch (_upachara) {
      case 'pushpam' || 'mantrapushpam':
        if (_rand.nextDouble() < 0.5) _spawnFlowers(1);
      case 'aarti' || 'dhoopam':
        final a = _autoT * 1.6;
        _plate = Offset(0.5 + 0.18 * math.cos(a), 0.55 + 0.12 * math.sin(a));
      case 'abhishekam':
        _pour = (math.sin(_autoT * 0.8) * 0.5 + 0.5);
      case 'coconut':
        if (_autoT > 1) _coconut = math.min(1, _coconut + dt * 3);
      case 'bell':
        if ((_autoT * 2).floor() != ((_autoT - dt) * 2).floor()) _bellSwing = 1;
      case 'shankh':
        _shankh = 1;
      case 'pradakshina':
        _walk = (_autoT * 0.25) % 1;
    }
  }

  void _spawnFlowers(int n) {
    const colors = [Color(0xFFF2A33A), Color(0xFFE85D2A), Color(0xFFF7E07A), Color(0xFFD94B6A)];
    for (var i = 0; i < n; i++) {
      if (_flowers.length > 300) break; // perf budget (ARCHITECTURE.md)
      _flowers.add(_Flower(0.3 + _rand.nextDouble() * 0.4, -0.05 - _rand.nextDouble() * 0.2,
          0.05 + _rand.nextDouble() * 0.1, _rand.nextDouble() * 6, colors[_rand.nextInt(colors.length)]));
    }
  }

  // ---------------------------------------------------------------- gestures
  void _onTap() {
    if (_auto) return;
    switch (_action) {
      case PoojaAction.tap:
        if (_upachara == 'deepam') _lampLit = true;
        _done();
      case PoojaAction.shake:
        _bellSwing = 1; // tap fallback for shake
        _done();
      default:
        break;
    }
  }

  void _onPanStart(DragStartDetails d, Size size) {
    _lastAngle = null;
    _dragAccum = 0;
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    if (_auto) return;
    final p = Offset(d.localPosition.dx / size.width, d.localPosition.dy / size.height);
    switch (_action) {
      case PoojaAction.dragCircle:
        _plate = p;
        final c = const Offset(0.5, 0.5);
        final a = math.atan2(p.dy - c.dy, p.dx - c.dx);
        if (_lastAngle != null) {
          var da = a - _lastAngle!;
          if (da > math.pi) da -= 2 * math.pi;
          if (da < -math.pi) da += 2 * math.pi;
          if (da > 0) _circleAngle += da; // clockwise on screen (y down)
          _progress((_circleAngle / (2 * math.pi)) % 1);
          if (_circleAngle >= 2 * math.pi) {
            _circleAngle -= 2 * math.pi;
            _done();
          }
        }
        _lastAngle = a;
      case PoojaAction.shower:
        if (d.delta.dy < 0) {
          _dragAccum += -d.delta.dy;
          if (_rand.nextDouble() < 0.6) _spawnFlowers(2);
        }
      case PoojaAction.pour:
        if (d.delta.dy > 0) {
          _pour = (_pour + d.delta.dy / (size.height * 0.6)).clamp(0, 1);
          _progress(_pour);
          if (_pour >= 1) {
            _pour = 0;
            _done();
          }
        }
      case PoojaAction.swipeDown:
        _dragAccum += d.delta.dy;
      case PoojaAction.walkAround:
        _walk = (_walk + d.delta.dx.abs() / (size.width * 1.5)).clamp(0, 1);
        _progress(_walk);
        if (_walk >= 1) {
          _walk = 0;
          _done();
        }
      default:
        break;
    }
  }

  void _onPanEnd(DragEndDetails d, Size size) {
    if (_auto) return;
    if (_action == PoojaAction.shower && _dragAccum > size.height * 0.15) {
      _spawnFlowers(25);
      _done();
    }
    if (_action == PoojaAction.swipeDown && (_dragAccum > size.height * 0.2 || d.velocity.pixelsPerSecond.dy > 900)) {
      _coconut = 1;
      HapticFeedback.heavyImpact();
      _done();
    }
    _dragAccum = 0;
  }

  void _onLongPressStart() {
    if (_auto || _action != PoojaAction.blow) return;
    _holdStart = _time;
  }

  void _onLongPressEnd() {
    if (_action != PoojaAction.blow || _holdStart < 0) return;
    if (_time - _holdStart > 0.8) {
      _shankh = 1;
      _done();
    }
    _holdStart = -1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight);
      if (_holdStart >= 0) _shankh = math.min(1, (_time - _holdStart) / 0.8);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        onPanStart: (d) => _onPanStart(d, size),
        onPanUpdate: (d) => _onPanUpdate(d, size),
        onPanEnd: (d) => _onPanEnd(d, size),
        onLongPressStart: (_) => _onLongPressStart(),
        onLongPressEnd: (_) => _onLongPressEnd(),
        child: Semantics(
          label: 'Sanctum of ${widget.deity.name.en}',
          child: CustomPaint(
            size: size,
            painter: _SanctumPainter(this),
          ),
        ),
      );
    });
  }
}

class _SanctumPainter extends CustomPainter {
  _SanctumPainter(this.s);
  final _PlaceholderSanctumState s;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final deity = s.widget.deity;
    final primary = Color(deity.primaryColor);
    final accent = Color(deity.accentColor);

    // backdrop: inner sanctum walls
    canvas.drawRect(Offset.zero & size, Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [const Color(0xFF1A0A06), Color.lerp(primary, Colors.black, 0.5)!, const Color(0xFF2A140A)])
          .createShader(Offset.zero & size));

    // golden arch (prabhavali)
    final archRect = Rect.fromCenter(center: Offset(w / 2, h * 0.42), width: w * 0.62, height: h * 0.62);
    final arch = Path()
      ..moveTo(archRect.left, archRect.bottom)
      ..lineTo(archRect.left, archRect.top + archRect.width / 2)
      ..arcToPoint(Offset(archRect.right, archRect.top + archRect.width / 2), radius: Radius.circular(archRect.width / 2))
      ..lineTo(archRect.right, archRect.bottom);
    canvas.drawPath(arch, Paint()
      ..color = accent.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025);
    canvas.drawPath(arch, Paint()..color = accent.withValues(alpha: 0.08));

    // divine glow behind the idol (stronger when the lamp is lit)
    final glowC = Offset(w / 2, h * 0.4);
    canvas.drawCircle(glowC, w * 0.26, Paint()
      ..shader = RadialGradient(colors: [
        accent.withValues(alpha: (s._lampLit ? 0.55 : 0.25) + 0.1 * s._glow),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(center: glowC, radius: w * 0.26)));

    // stylised idol: peetham + seated silhouette + medallion face
    final base = Offset(w / 2, h * 0.62);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: base, width: w * 0.32, height: h * 0.05), const Radius.circular(6)),
        Paint()..color = accent);
    final body = Path()
      ..moveTo(w * 0.38, h * 0.6)
      ..quadraticBezierTo(w * 0.5, h * 0.44, w * 0.62, h * 0.6)
      ..close();
    canvas.drawPath(body, Paint()..color = Color.lerp(primary, Colors.black, 0.2)!);
    canvas.drawCircle(Offset(w / 2, h * 0.38), w * 0.075, Paint()..color = Color.lerp(primary, Colors.black, 0.1)!);
    canvas.drawCircle(Offset(w / 2, h * 0.38), w * 0.075, Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);
    final tp = TextPainter(
      text: TextSpan(text: deity.idolGlyph, style: TextStyle(fontFamily: K.teluguSerif, color: K.goldSoft, fontSize: w * 0.06, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h * 0.38 - tp.height / 2));
    // crown
    final crown = Path()
      ..moveTo(w * 0.44, h * 0.31)
      ..lineTo(w * 0.47, h * 0.26)
      ..lineTo(w * 0.5, h * 0.3)
      ..lineTo(w * 0.53, h * 0.26)
      ..lineTo(w * 0.56, h * 0.31)
      ..close();
    canvas.drawPath(crown, Paint()..color = accent);

    // abhishekam stream
    if (s._upachara == 'abhishekam' && s._pour > 0.02) {
      final liquid = switch (s._option) {
        'milk' => const Color(0xFFF8F4EA),
        'ghee' => const Color(0xFFF3C969),
        'panchamrutam' => const Color(0xFFE9C9A0),
        _ => const Color(0xFFB9E0F2),
      };
      final top = Offset(w / 2, h * 0.16);
      canvas.drawLine(top, Offset(w / 2, h * (0.16 + 0.44 * s._pour)), Paint()
        ..color = liquid.withValues(alpha: 0.85)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);
      canvas.drawOval(Rect.fromCenter(center: Offset(w / 2, h * 0.14), width: w * 0.12, height: h * 0.03), Paint()..color = accent);
    }

    // lamps (left and right)
    for (final x in [w * 0.2, w * 0.8]) {
      final lampBase = Offset(x, h * 0.74);
      canvas.drawOval(Rect.fromCenter(center: lampBase, width: w * 0.12, height: h * 0.025), Paint()..color = accent);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, h * 0.79), width: w * 0.015, height: h * 0.08), Paint()..color = accent.withValues(alpha: 0.8));
      if (s._lampLit) _flame(canvas, Offset(x, h * 0.72), w * 0.03, s._time);
    }

    // flowers
    for (final f in s._flowers) {
      final p = Offset(f.x * w, f.y * h);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(f.spin + s._time);
      for (var i = 0; i < 5; i++) {
        canvas.rotate(2 * math.pi / 5);
        canvas.drawOval(Rect.fromCenter(center: const Offset(0, -4), width: 5, height: 8), Paint()..color = f.color);
      }
      canvas.restore();
    }

    // coconut
    if (s._upachara == 'coconut') {
      final c = Offset(w / 2, h * 0.7);
      final split = s._coconut * w * 0.04;
      final shell = Paint()..color = const Color(0xFF7A4B26);
      canvas.drawArc(Rect.fromCircle(center: c.translate(-split, 0), radius: w * 0.05), math.pi / 2, math.pi, true, shell);
      canvas.drawArc(Rect.fromCircle(center: c.translate(split, 0), radius: w * 0.05), -math.pi / 2, math.pi, true, shell);
      if (s._coconut > 0.5) {
        canvas.drawCircle(c, w * 0.035, Paint()..color = const Color(0xFFF7F3E8));
      }
    }

    // aarti plate / dhoopam following the finger
    if ((s._upachara == 'aarti' || s._upachara == 'dhoopam') && s._plate != null) {
      final p = Offset(s._plate!.dx * w, s._plate!.dy * h);
      canvas.drawOval(Rect.fromCenter(center: p, width: w * 0.16, height: h * 0.03), Paint()..color = accent);
      if (s._upachara == 'aarti') {
        _flame(canvas, p.translate(0, -h * 0.02), w * 0.035, s._time);
      } else {
        for (var i = 0; i < 3; i++) {
          final y = p.dy - h * 0.03 - i * h * 0.03;
          canvas.drawCircle(Offset(p.dx + math.sin(s._time * 2 + i) * 6, y), 6 + i * 3.0,
              Paint()..color = Colors.white.withValues(alpha: 0.12 - i * 0.03));
        }
      }
    }

    // bell (top-right) swings
    canvas.save();
    canvas.translate(w * 0.86, h * 0.08);
    canvas.rotate(math.sin(s._time * 18) * 0.5 * s._bellSwing);
    canvas.drawLine(Offset.zero, Offset(0, h * 0.05), Paint()
      ..color = accent
      ..strokeWidth = 2);
    final bell = Path()
      ..moveTo(-w * 0.035, h * 0.1)
      ..quadraticBezierTo(-w * 0.03, h * 0.05, 0, h * 0.05)
      ..quadraticBezierTo(w * 0.03, h * 0.05, w * 0.035, h * 0.1)
      ..close();
    canvas.drawPath(bell, Paint()..color = accent);
    canvas.restore();

    // shankh ripple
    if (s._shankh > 0) {
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(Offset(w * 0.14, h * 0.1), (i + 1) * 14 * s._shankh, Paint()
          ..color = K.goldSoft.withValues(alpha: 0.4 * (1 - s._shankh * i / 3))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
    }

    // pradakshina: devotee marker orbiting the sanctum
    if (s._upachara == 'pradakshina') {
      final a = -math.pi / 2 + s._walk * 2 * math.pi;
      final p = Offset(w / 2 + math.cos(a) * w * 0.4, h * 0.45 + math.sin(a) * h * 0.36);
      canvas.drawCircle(p, 8, Paint()..color = K.saffron);
      canvas.drawCircle(Offset(w / 2, h * 0.45), w * 0.4, Paint()
        ..color = K.saffron.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    }

    // curtains (closing: nada closes)
    if (s._curtain > 0) {
      final cw = w / 2 * s._curtain;
      final cur = Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF7A0F1F), Color(0xFFA31B2F), Color(0xFF7A0F1F)])
            .createShader(Offset.zero & size);
      canvas.drawRect(Rect.fromLTWH(0, 0, cw, h), cur);
      canvas.drawRect(Rect.fromLTWH(w - cw, 0, cw, h), cur);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.04), Paint()..color = accent);
    }
  }

  void _flame(Canvas canvas, Offset base, double r, double t) {
    final flicker = 1 + 0.12 * math.sin(t * 17) + 0.08 * math.sin(t * 29);
    canvas.drawCircle(base.translate(0, -r * 0.6), r * 2.2, Paint()
      ..shader = RadialGradient(colors: [const Color(0x88FFB347), Colors.transparent])
          .createShader(Rect.fromCircle(center: base.translate(0, -r * 0.6), radius: r * 2.2)));
    final f = Path()
      ..moveTo(base.dx - r * 0.5, base.dy)
      ..quadraticBezierTo(base.dx - r * 0.6, base.dy - r * 1.2 * flicker, base.dx, base.dy - r * 2 * flicker)
      ..quadraticBezierTo(base.dx + r * 0.6, base.dy - r * 1.2 * flicker, base.dx + r * 0.5, base.dy)
      ..close();
    canvas.drawPath(f, Paint()..color = const Color(0xFFFFC94A));
    canvas.drawCircle(base.translate(0, -r * 0.4), r * 0.3, Paint()..color = const Color(0xFFFFF3C4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
