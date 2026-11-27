import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/core/content/localized.dart';
import 'package:kalpam/core/panchangam/astronomy.dart';
import 'package:kalpam/core/panchangam/panchangam.dart';

const hyd = City(
    id: 'hyderabad',
    name: LocalizedText({'en': 'Hyderabad'}),
    lat: 17.385,
    lon: 78.4867,
    utcOffsetMin: 330);
const calc = PanchangamCalculator();

DateTime ist(int y, int m, int d, int h, int min) =>
    DateTime.utc(y, m, d, h, min).subtract(const Duration(minutes: 330));

void main() {
  test('Dec 2026 full moon instant (24 Dec 01:28 UTC) within 5 min', () {
    final p = calc.compute(hyd, 2026, 12, 24);
    expect(p.tithi.number, 15);
    final diff = p.tithi.endsAt.difference(DateTime.utc(2026, 12, 24, 1, 28)).inMinutes.abs();
    expect(diff, lessThanOrEqualTo(5));
  });

  test('Vaikuntha Ekadashi 20 Dec 2026 is Margashira Shukla Ekadashi', () {
    final p = calc.compute(hyd, 2026, 12, 20);
    expect(p.tithi.number, 11);
    expect(p.masa.en, 'Margashira');
    expect(p.weekday, DateTime.sunday);
  });

  test('Ugadi 7 Apr 2027 starts Chaitra and samvatsara Plavanga', () {
    final p = calc.compute(hyd, 2027, 4, 7);
    expect(p.tithi.number, 1);
    expect(p.masa.en, 'Chaitra');
    expect(p.samvatsara.en, 'Plavanga');
    final before = calc.compute(hyd, 2027, 3, 1);
    expect(before.samvatsara.en, 'Parabhava');
  });

  test('Ganesh Chaturthi 4 Sep 2027 is Bhadrapada Shukla Chaturthi', () {
    final p = calc.compute(hyd, 2027, 9, 4);
    expect(p.tithi.number, 4);
    expect(p.masa.en, 'Bhadrapada');
  });

  test('Maha Shivratri 6 Mar 2027: Magha Krishna Chaturdashi prevails at night', () {
    final p = calc.compute(hyd, 2027, 3, 6);
    expect(p.masa.en, 'Magha');
    expect(p.tithisInDay, contains(29));
  });

  test('Hyderabad sunrise/sunset 20 Dec 2026 within 3 min of 06:39/17:45 IST', () {
    final p = calc.compute(hyd, 2026, 12, 20);
    expect(p.sunrise.difference(ist(2026, 12, 20, 6, 39)).inMinutes.abs(), lessThanOrEqualTo(3));
    expect(p.sunset.difference(ist(2026, 12, 20, 17, 45)).inMinutes.abs(), lessThanOrEqualTo(3));
  });

  test('Rahu Kalam is the 8th daytime segment on Sunday and 2nd on Monday', () {
    final sun = calc.compute(hyd, 2026, 12, 20);
    expect(sun.rahuKalam.end, sun.sunset);
    final mon = calc.compute(hyd, 2026, 12, 21);
    final eighth = mon.sunset.difference(mon.sunrise) ~/ 8;
    expect(mon.rahuKalam.start.difference(mon.sunrise).inMinutes, eighth.inMinutes);
  });

  test('Sun enters sidereal Vrischika around 16 Nov 2026 (Mandala start)', () {
    final jd15 = julianDay(ist(2026, 11, 15, 12, 0));
    final jd17 = julianDay(ist(2026, 11, 17, 12, 0));
    expect(siderealSun(jd15), lessThan(210));
    expect(siderealSun(jd17), greaterThan(210));
  });

  test('next Ekadashi after 27 Nov 2026 is 4 Dec (Utpanna, Krishna)', () {
    final p = calc.nextTithi(hyd, DateTime.utc(2026, 11, 27), {11, 26})!;
    expect(p.isoDate, '2026-12-04');
  });
}
