import 'package:kalpam/core/panchangam/panchangam.dart';
import 'package:kalpam/core/content/localized.dart';
void main() {
  const hyd = City(id: 'hyd', name: LocalizedText({'en':'Hyderabad'}), lat: 17.385, lon: 78.4867, utcOffsetMin: 330);
  const c = PanchangamCalculator();
  var d = DateTime.utc(2027,5,25);
  int? lastMasa;
  for (var i=0;i<200;i++) { final x = d.add(Duration(days:i)); final p = c.compute(hyd,x.year,x.month,x.day);
    if (p.masaIndex!=lastMasa) { print('masa ${p.masa.en}${p.adhikaMasa?" adhika":""} starts ${p.isoDate}'); lastMasa=p.masaIndex; }
    if (p.tithi.number==11 && (p.masaIndex==2||p.masaIndex==3)) print('  shukla ekadashi ${p.masa.en} ${p.isoDate}');
    if (p.tithi.number==15) print('  pournami ${p.masa.en} ${p.isoDate}');
  }
  for (final y in [2027]) { for (var i=0;i<6;i++){ final x=DateTime.utc(2027,11,14).add(Duration(days:i)); final p=c.compute(hyd,x.year,x.month,x.day); print('${p.isoDate} sunRashi ${p.sunRashi}'); } }
  for (var i=0;i<4;i++){ final x=DateTime.utc(2028,1,13).add(Duration(days:i)); final p=c.compute(hyd,x.year,x.month,x.day); print('${p.isoDate} sunRashi ${p.sunRashi}'); }
}
