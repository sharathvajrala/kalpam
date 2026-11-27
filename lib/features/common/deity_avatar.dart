import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/content/models.dart';

/// Deity medallion. Uses pack art when bundled; until art lands
/// (ASSETS_TODO.md art.<deity>.icon) shows a gold medallion with the
/// deity's Telugu initial.
class DeityAvatar extends StatelessWidget {
  const DeityAvatar({super.key, required this.deity, this.size = 56});
  final DeityPack deity;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = Color(deity.primaryColor);
    final accent = Color(deity.accentColor);
    if (deity.icon.isAsset) {
      return ClipOval(child: Image.asset(deity.icon.assetPath, width: size, height: size, fit: BoxFit.cover));
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Color.lerp(primary, Colors.white, 0.15)!, primary]),
        border: Border.all(color: accent, width: size * 0.05),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: size * 0.2)],
      ),
      alignment: Alignment.center,
      child: Text(
        deity.idolGlyph,
        style: TextStyle(
          fontFamily: K.teluguSerif,
          color: K.goldSoft,
          fontSize: size * (deity.idolGlyph.length > 1 ? 0.34 : 0.44),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
