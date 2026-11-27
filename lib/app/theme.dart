import 'package:material_ui/material_ui.dart';

/// Kalpam design tokens — warm ivory, temple maroon, temple gold, saffron.
abstract final class K {
  static const ivory = Color(0xFFFAF5EC);
  static const ivoryDeep = Color(0xFFF3EAD8);
  static const card = Color(0xFFFFFCF6);
  static const maroon = Color(0xFF5E1224);
  static const maroonDeep = Color(0xFF3E0A17);
  static const gold = Color(0xFFC9A227);
  static const goldBright = Color(0xFFD4AF37);
  static const goldSoft = Color(0xFFE9D9A6);
  static const saffron = Color(0xFFE8731C);
  static const ink = Color(0xFF2B1A12);
  static const inkSoft = Color(0xFF6E5A4B);
  static const success = Color(0xFF3F7D3A);

  static const serif = 'KalpamSerif';
  static const teluguSerif = 'KalpamTeluguSerif';
  static const sans = 'KalpamSans';

  static const radius = 18.0;
  static const fallback = [teluguSerif, sans];
}

ThemeData kalpamTheme({required bool elder}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: K.maroon,
      primary: K.maroon,
      secondary: K.gold,
      tertiary: K.saffron,
      surface: K.ivory,
      onSurface: K.ink,
    ),
    scaffoldBackgroundColor: K.ivory,
    fontFamily: K.sans,
    fontFamilyFallback: K.fallback,
  );
  final t = base.textTheme;
  TextStyle serif(TextStyle? s, {double? size, FontWeight w = FontWeight.w600}) => (s ?? const TextStyle()).copyWith(
        fontFamily: K.serif,
        fontFamilyFallback: const [K.teluguSerif, K.sans],
        fontWeight: w,
        fontSize: size,
        color: K.maroon,
        height: 1.15,
      );
  return base.copyWith(
    textTheme: t.copyWith(
      displaySmall: serif(t.displaySmall, size: 34),
      headlineMedium: serif(t.headlineMedium, size: 28),
      headlineSmall: serif(t.headlineSmall, size: 24),
      titleLarge: serif(t.titleLarge, size: 21),
      titleMedium: (t.titleMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600, color: K.ink),
      bodyLarge: (t.bodyLarge ?? const TextStyle()).copyWith(color: K.ink, height: 1.45),
      bodyMedium: (t.bodyMedium ?? const TextStyle()).copyWith(color: K.ink, height: 1.45),
      bodySmall: (t.bodySmall ?? const TextStyle()).copyWith(color: K.inkSoft),
      labelLarge: (t.labelLarge ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: K.ivory,
      foregroundColor: K.maroon,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: K.card,
      indicatorColor: K.goldSoft,
      height: elder ? 84 : 70,
      labelTextStyle: WidgetStatePropertyAll(TextStyle(
          fontSize: elder ? 13 : 11.5, fontWeight: FontWeight.w600, color: K.maroon)),
      iconTheme: const WidgetStatePropertyAll(IconThemeData(color: K.maroon)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: K.maroon,
        foregroundColor: K.ivory,
        minimumSize: Size(0, elder ? 60 : 48),
        textStyle: TextStyle(fontSize: elder ? 19 : 15.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: K.maroon,
        side: const BorderSide(color: K.gold, width: 1.2),
        minimumSize: Size(0, elder ? 60 : 48),
        textStyle: TextStyle(fontSize: elder ? 19 : 15.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: K.card,
      selectedColor: K.goldSoft,
      side: const BorderSide(color: K.goldSoft),
      labelStyle: const TextStyle(color: K.maroon, fontWeight: FontWeight.w600),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? K.maroon : null),
      side: const BorderSide(color: K.gold, width: 1.5),
    ),
    dividerTheme: const DividerThemeData(color: K.goldSoft, thickness: 1),
  );
}

/// Card with a thin gold border and soft corners, as in the samples.
class GoldCard extends StatelessWidget {
  const GoldCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color, this.gradient});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(K.radius);
    final shape = RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: K.gold.withValues(alpha: 0.65)));
    Widget inner = Padding(padding: padding, child: child);
    if (gradient != null) {
      inner = DecoratedBox(decoration: BoxDecoration(gradient: gradient, borderRadius: radius), child: inner);
    }
    // A Material (not a coloured box) so ListTiles and ink splashes inside render correctly.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [BoxShadow(color: K.maroon.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: gradient == null ? (color ?? K.card) : Colors.transparent,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? inner : InkWell(onTap: onTap, child: inner),
      ),
    );
  }
}

/// Small ornamental divider (gold line with a centre dot).
class GoldRule extends StatelessWidget {
  const GoldRule({super.key, this.color = K.gold});
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.5))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.brightness_1, size: 5, color: color)),
          Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.5))),
        ]),
      );
}

/// A small flag chip for placeholder media (ASSETS_TODO.md).
class PlaceholderChip extends StatelessWidget {
  const PlaceholderChip(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: K.saffron.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: K.saffron.withValues(alpha: 0.5)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, color: K.saffron, fontWeight: FontWeight.w600)),
      );
}
