import 'package:material_ui/material_ui.dart';

import '../core/content/localized.dart';
import '../l10n/gen/app_localizations.dart';
import 'app_state.dart';
import 'theme.dart';

/// Exposes [AppState] to the widget tree and rebuilds dependents on change.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

extension KalpamContext on BuildContext {
  AppState get app => AppScope.of(this);
  AppLocalizations get l => AppLocalizations.of(this);

  /// The secondary script shown under every label (bilingual UI rule).
  String get lang2 => app.lang == 'en' ? 'te' : 'en';
  AppLocalizations get l2 => lookupAppLocalizations(Locale(lang2));
  String t(LocalizedText x) => x.of(app.lang);
  String t2(LocalizedText x) => x.of(lang2);
}

/// Bilingual label: primary language large, secondary script small below.
class Bi extends StatelessWidget {
  const Bi(this.pick, {super.key, this.style, this.align = CrossAxisAlignment.start, this.secondaryColor, this.maxLines});

  final String Function(AppLocalizations l) pick;
  final TextStyle? style;
  final CrossAxisAlignment align;
  final Color? secondaryColor;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => BiPair(pick(context.l), pick(context.l2),
      style: style, align: align, secondaryColor: secondaryColor, maxLines: maxLines);
}

/// Bilingual content text from a pack.
class BiL extends StatelessWidget {
  const BiL(this.text, {super.key, this.style, this.align = CrossAxisAlignment.start, this.secondaryColor, this.maxLines});
  final LocalizedText text;
  final TextStyle? style;
  final CrossAxisAlignment align;
  final Color? secondaryColor;
  final int? maxLines;
  @override
  Widget build(BuildContext context) =>
      BiPair(context.t(text), context.t2(text), style: style, align: align, secondaryColor: secondaryColor, maxLines: maxLines);
}

class BiPair extends StatelessWidget {
  const BiPair(this.primary, this.secondary,
      {super.key, this.style, this.align = CrossAxisAlignment.start, this.secondaryColor, this.maxLines});
  final String primary, secondary;
  final TextStyle? style;
  final CrossAxisAlignment align;
  final Color? secondaryColor;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final s = style ?? Theme.of(context).textTheme.titleMedium!;
    final ta = switch (align) {
      CrossAxisAlignment.center => TextAlign.center,
      CrossAxisAlignment.end => TextAlign.end,
      _ => TextAlign.start,
    };
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(primary, style: s, textAlign: ta, maxLines: maxLines, overflow: maxLines == null ? null : TextOverflow.ellipsis),
        if (secondary.isNotEmpty && secondary != primary)
          Text(secondary,
              textAlign: ta,
              maxLines: maxLines,
              overflow: maxLines == null ? null : TextOverflow.ellipsis,
              style: s.copyWith(
                fontSize: (s.fontSize ?? 16) * 0.62,
                fontWeight: FontWeight.w500,
                color: secondaryColor ?? (s.color ?? K.ink).withValues(alpha: 0.7),
                fontFamily: K.sans,
                height: 1.25,
              )),
      ],
    );
  }
}

/// Time in the user's city, e.g. "6:40 AM".
String fmtTime(BuildContext context, DateTime utc) {
  final l = context.app.city.local(utc);
  final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final m = l.minute.toString().padLeft(2, '0');
  final ampm = l.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $ampm';
}

String fmtDate(BuildContext context, DateTime civil) {
  const en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const te = ['జనవరి', 'ఫిబ్రవరి', 'మార్చి', 'ఏప్రిల్', 'మే', 'జూన్', 'జూలై', 'ఆగస్టు', 'సెప్టెంబర్', 'అక్టోబర్', 'నవంబర్', 'డిసెంబర్'];
  final m = (context.app.lang == 'te' ? te : en)[civil.month - 1];
  return '${civil.day} $m ${civil.year}';
}
