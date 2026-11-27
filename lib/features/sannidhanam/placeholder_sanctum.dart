import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/content/models.dart';
import '../../pooja_engine/gestures.dart';
import '../../pooja_engine/sanctum_bridge.dart';

/// Flutter-drawn stand-in for the Unity sanctum (ASSETS_TODO.md
/// 3d.ayyappa.sanctum). Implements the full [SanctumBridge] protocol:
/// every upachara is interactive in Hands-on mode and animates itself in
/// Watch Mode, so the pooja flow is complete end-to-end today.
class PlaceholderSanctum extends StatefulWidget {
  const PlaceholderSanctum({super.key, required this.bridge, required this.deity, this.recognizer});
  final SanctumBridge bridge;
  final DeityPack deity;

  /// The active step's recognizer (from the pooja engine). Raw touches go
  /// here; when null the sanctum is a passive darshan view.
  final UpacharaRecognizer? Function()? recognizer;

  @override
  State<PlaceholderSanctum> createState() => _PlaceholderSanctumState();
}

class _Flower {
  _Flower(this.x, this.y, this.vy, this.spin, this.color, {this.settle = 0.78});
  double x, y, vy, spin;
  final Color color;

  /// Height where the flower comes to rest (archana flowers pile at the feet).
  final double settle;
  bool resting = false;
}

class _PlaceholderSanctumState extends State<PlaceholderSanctum> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final StreamSubscription<SanctumCommand> _sub;
  final _rand = math.Random(7);
  Duration _last = Duration.zero;
  double _time = 0;

  // scene state
  String? _upachara;
  bool _auto = false;
  String? _option;
  bool _lampLit = false;
  final List<_Flower> _flowers = [];
  Offset? _plate; // aarti / dhoopam position (0..1 space)
  double _plateOrbit = -1; // >=0 while a Watch Mode circle is running
  double _pour = 0; // 0..1 abhishekam stream
  double _pourTarget = 0;
  double _coconut = 0; // 0 whole -> 1 broken
  double _bellSwing = 0;
  double _shankh = 0;
  double _curtain = 0; // 0 open -> 1 closed
  bool _closingCurtains = false;
  double _glow = 0;
  double _walk = 0; // pradakshina progress within current round
  double _walkTarget = 0;
  double _tray = 0; // naivedyam / tambulam tray rising to the idol
  double _drape = 0; // vastram drape
  double? _holdStart;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _sub = widget.bridge.commands.listen(_onCommand);
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
        _option = c.payload['option'] as String?;
        _auto = false;
        _resetStepVisuals();
      case 'autoPerform':
        _upachara = c.payload['upachara'] as String?;
        _option = c.payload['option'] as String?;
        _auto = true;
        _resetStepVisuals();
      case 'cue':
        _cue(c.payload['cue'] as String, c.payload['arg']);
      case 'effect':
        _effect(c.payload['effect'] as String);
      case 'closeSanctum':
        _upachara = 'closing';
        _closingCurtains = widget.deity.closingType == 'curtains';
    }
  }

  void _resetStepVisuals() {
    _pour = 0;
    _pourTarget = 0;
    _walk = 0;
    _walkTarget = 0;
    _plateOrbit = -1;
    _tray = 0;
    if (_upachara == 'aarti' || _upachara == 'dhoopam') _plate = const Offset(0.5, 0.62);
    if (_upachara == 'coconut') _coconut = 0;
  }

  /// Watch Mode choreography cues (and hands-on action effects).
  void _cue(String cue, Object? arg) {
    switch (cue) {
      case 'lightLamp':
        _lampLit = true;
      case 'flowers':
        final n = (arg as int?) ?? 20;
        _spawnFlowers(n, archana: _upachara == 'archana');
      case 'aartiCircle' || 'dhoopCircle':
        _plateOrbit = 0;
      case 'pour':
        _option = arg as String? ?? _option;
        _pourTarget = 1;
      case 'coconut':
        _coconut = 0.01;
        HapticFeedback.heavyImpact();
      case 'bell':
        _bellSwing = 1;
      case 'shankh':
        _shankh = 1;
      case 'walkAround':
        _walkTarget = _walk.floorToDouble() + 1;
      case 'offerTray':
        _tray = 0.01;
      case 'drape':
        _drape = 0.01;
      case 'curtainsClose':
        _closingCurtains = true;
    }
  }

  /// Live feedback from the recognizers while the devotee acts.
  void _effect(String e) {
    final parts = e.split(':');
    final arg = parts.length > 1 ? parts[1] : '';
    switch (parts.first) {
      case 'plate':
        final xy = arg.split(',').map(double.parse).toList();
        _plate = Offset(xy[0], xy[1]);
      case 'flowers':
        _spawnFlowers(int.tryParse(arg) ?? 1, archana: _upachara == 'archana');
      case 'pour':
        _pour = double.tryParse(arg) ?? 0;
      case 'walk':
        _walk = double.tryParse(arg) ?? 0;
      case 'coconut':
        _cue('coconut', null);
      case 'bell':
        _bellSwing = 1;
      case 'shankh':
        _shankh = 1;
    }
  }

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    _time += dt;
    for (final f in _flowers) {
      if (f.resting) continue;
      f.vy += 0.35 * dt;
      f.y += f.vy * dt;
      f.x += math.sin(_time * 2 + f.spin) * 0.02 * dt;
      if (f.y >= f.settle && f.settle < 0.78) {
        f.y = f.settle;
        f.resting = true;
      }
    }
    _flowers.removeWhere((f) => !f.resting && f.y > 0.78);
    if (_flowers.length > 300) _flowers.removeRange(0, _flowers.length - 300); // perf budget
    _bellSwing *= math.pow(0.04, dt).toDouble();
    _shankh = math.max(0, _shankh - dt * 0.6);
    _glow = 0.5 + 0.5 * math.sin(_time * 1.3);
    if (_coconut > 0) _coconut = math.min(1, _coconut + dt * 3);
    if (_tray > 0) _tray = math.min(1, _tray + dt * 0.8);
    if (_drape > 0) _drape = math.min(1, _drape + dt * 0.7);
    if (_auto && _pourTarget > _pour) _pour = math.min(_pourTarget, _pour + dt * 0.35);
    if (_walkTarget > _walk) _walk = math.min(_walkTarget, _walk + dt * 0.25);
    if (_plateOrbit >= 0) {
      _plateOrbit += dt * 1.6;
      final a = _plateOrbit;
      _plate = Offset(0.5 + 0.18 * math.cos(a), 0.55 + 0.12 * math.sin(a));
      if (_plateOrbit >= 2 * math.pi) _plateOrbit = -1;
    }
    if (_auto && (_upachara == 'pushpam' || _upachara == 'mantrapushpam') && _rand.nextDouble() < 0.3) _spawnFlowers(1);
    if (_closingCurtains) _curtain = math.min(1, _curtain + dt * 0.12);
    if (_holdStart != null) _shankh = math.min(1, (_time - _holdStart!) / 0.8);
    setState(() {});
  }

  void _spawnFlowers(int n, {bool archana = false}) {
    const colors = [Color(0xFFF2A33A), Color(0xFFE85D2A), Color(0xFFF7E07A), Color(0xFFD94B6A)];
    for (var i = 0; i < n; i++) {
      _flowers.add(archana
          ? _Flower(0.42 + _rand.nextDouble() * 0.16, 0.2, 0.15, _rand.nextDouble() * 6, colors[_rand.nextInt(colors.length)],
              settle: 0.585 + _rand.nextDouble() * 0.02)
          : _Flower(0.3 + _rand.nextDouble() * 0.4, -0.05 - _rand.nextDouble() * 0.2, 0.05 + _rand.nextDouble() * 0.1,
              _rand.nextDouble() * 6, colors[_rand.nextInt(colors.length)]));
    }
  }

  // ------------------------------------------------- raw input -> recognizer
  UpacharaRecognizer? get _rec => _auto ? null : widget.recognizer?.call();
  Vec _n(Offset p, Size s) => Vec(p.dx / s.width, p.dy / s.height);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) {
          _rec?.tap(_n(d.localPosition, size));
          HapticFeedback.selectionClick();
        },
        onPanStart: (d) => _rec?.down(_n(d.localPosition, size), _time),
        onPanUpdate: (d) => _rec?.move(_n(d.localPosition, size), _time),
        onPanEnd: (d) => _rec?.up(_n(d.localPosition, size), _time,
            velocity: Vec(d.velocity.pixelsPerSecond.dx / size.width, d.velocity.pixelsPerSecond.dy / size.height)),
        onLongPressStart: (_) {
          _rec?.holdStart(_time);
          if (_upachara == 'shankh' && !_auto) _holdStart = _time;
        },
        onLongPressEnd: (_) {
          _rec?.holdEnd(_time);
          _holdStart = null;
        },
        child: Semantics(
          label: 'Sanctum of ${widget.deity.name.en}',
          child: CustomPaint(size: size, painter: _SanctumPainter(this)),
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

    // naivedyam / tambulam tray rising to the idol
    if (s._tray > 0 && (s._upachara == 'naivedyam' || s._upachara == 'tambulam')) {
      final y = h * (0.78 - 0.1 * Curves.easeOut.transform(s._tray));
      final c = Offset(w / 2, y);
      canvas.drawOval(Rect.fromCenter(center: c, width: w * 0.22, height: h * 0.035), Paint()..color = accent);
      final food = s._upachara == 'naivedyam' ? const Color(0xFFF5E6C8) : const Color(0xFF3E8E41);
      canvas.drawCircle(c.translate(-w * 0.04, -h * 0.012), w * 0.025, Paint()..color = food);
      canvas.drawCircle(c.translate(w * 0.04, -h * 0.012), w * 0.025, Paint()..color = food);
    }

    // vastram drape over the shoulders
    if (s._drape > 0) {
      final a = Curves.easeOut.transform(s._drape);
      final drape = Path()
        ..moveTo(w * 0.4, h * 0.47)
        ..quadraticBezierTo(w * 0.5, h * (0.47 + 0.08 * a), w * 0.6, h * 0.47)
        ..lineTo(w * 0.6, h * (0.47 + 0.03 * a))
        ..quadraticBezierTo(w * 0.5, h * (0.5 + 0.08 * a), w * 0.4, h * (0.47 + 0.03 * a))
        ..close();
      canvas.drawPath(drape, Paint()..color = const Color(0xFFE0A526).withValues(alpha: 0.9 * a));
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
