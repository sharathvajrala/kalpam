import 'package:kalpam/core/panchangam/panchangam.dart';
import 'package:kalpam/core/content/localized.dart';
void main(List<String> a) {
  const hyd = City(id: 'hyd', name: LocalizedText({'en':'Hyderabad'}), lat: 17.385, lon: 78.4867, utcOffsetMin: 330);
  const calc = PanchangamCalculator();
  for (final d in [[2026,11,27],[2026,12,9],[2026,12,20],[2026,12,24],[2027,1,14],[2027,3,6],[2027,4,7],[2027,8,13],[2027,9,4],[2027,11,13]]) {
    final p = calc.compute(hyd, d[0], d[1], d[2]);
    String t(DateTime x) { final l = hyd.local(x); return '${l.month}/${l.day} ${l.hour.toString().padLeft(2,'0')}:${l.minute.toString().padLeft(2,'0')}'; }
    print('${p.isoDate} wd${p.weekday} rise ${t(p.sunrise)} set ${t(p.sunset)} tithi ${p.tithi.number} ${p.tithi.name.en} till ${t(p.tithi.endsAt)} | nak ${p.nakshatra.name.en} till ${t(p.nakshatra.endsAt)} | yoga ${p.yoga.name.en} | kar ${p.karana.name.en} | ${p.masa.en}${p.adhikaMasa?" (adhika)":""} ${p.samvatsara.en} ${p.ayana.en} | rahu ${t(p.rahuKalam.start)}-${t(p.rahuKalam.end)} | day tithis ${p.tithisInDay}');
  }
}
