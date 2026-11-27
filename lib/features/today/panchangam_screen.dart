import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/panchangam/panchangam.dart';

class PanchangamScreen extends StatefulWidget {
  const PanchangamScreen({super.key});
  @override
  State<PanchangamScreen> createState() => _PanchangamScreenState();
}

class _PanchangamScreenState extends State<PanchangamScreen> {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final date = app.today.add(Duration(days: _offset));
    final p = app.panchangFor(date);
    final l = context.l;
    final tt = Theme.of(context).textTheme;

    Widget row(String label, String label2, String value, {String? sub}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 4, child: BiPair(label, label2, style: tt.bodyMedium?.copyWith(color: K.inkSoft))),
            Expanded(
              flex: 6,
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(value, textAlign: TextAlign.end, style: tt.titleMedium?.copyWith(color: K.maroon)),
                if (sub != null) Text(sub, style: tt.bodySmall),
              ]),
            ),
          ]),
        );
    String span(Span s) => '${fmtTime(context, s.start)} – ${fmtTime(context, s.end)}';
    final l2 = context.l2;

    return Scaffold(
      appBar: AppBar(title: Bi((l) => l.panchangam, style: tt.titleLarge)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          IconButton(onPressed: () => setState(() => _offset--), icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Column(children: [
              Text(fmtDate(context, date), style: tt.titleLarge),
              Text('${context.t(p.weekdayName)} · ${context.t(app.city.name)}', style: tt.bodySmall),
            ]),
          ),
          IconButton(onPressed: () => setState(() => _offset++), icon: const Icon(Icons.chevron_right)),
        ]),
        const SizedBox(height: 12),
        GoldCard(
          child: Column(children: [
            row(l.samvatsaram, l2.samvatsaram, '${context.t(p.samvatsara)} · ${context.t(p.ayana)}'),
            row(l.masam, l2.masam, '${context.t(p.masa)}${p.adhikaMasa ? ' (Adhika)' : ''} · ${context.t(p.ritu)}'),
            const Divider(),
            row(l.tithi, l2.tithi, '${context.t(p.tithi.paksha)} ${context.t(p.tithi.name)}', sub: l.until(fmtTime(context, p.tithi.endsAt))),
            row(l.nakshatram, l2.nakshatram, context.t(p.nakshatra.name), sub: l.until(fmtTime(context, p.nakshatra.endsAt))),
            row(l.yogam, l2.yogam, context.t(p.yoga.name), sub: l.until(fmtTime(context, p.yoga.endsAt))),
            row(l.karanam, l2.karanam, context.t(p.karana.name), sub: l.until(fmtTime(context, p.karana.endsAt))),
            const Divider(),
            row(l.sunrise, l2.sunrise, fmtTime(context, p.sunrise)),
            row(l.sunset, l2.sunset, fmtTime(context, p.sunset)),
            const Divider(),
            row(l.rahuKalam, l2.rahuKalam, span(p.rahuKalam)),
            row(l.yamagandam, l2.yamagandam, span(p.yamagandam)),
            row(l.gulikaKalam, l2.gulikaKalam, span(p.gulikaKalam)),
          ]),
        ),
        const SizedBox(height: 10),
        Text('Lahiri ayanamsa · udaya tithi · amanta masa', style: tt.bodySmall, textAlign: TextAlign.center),
      ]),
    );
  }
}
