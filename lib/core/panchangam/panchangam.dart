/// Panchangam for a city and civil date, computed fully on-device.
///
/// Conventions (see ASSUMPTIONS.md #6): udaya (at-sunrise) values, amanta
/// months, Lahiri ayanamsa, Telugu 60-year samvatsara.
library;

import '../content/localized.dart';
import 'astronomy.dart';
import 'names.dart';

class City {
  const City({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.utcOffsetMin,
    this.tzName = 'Asia/Kolkata',
  });

  final String id;
  final LocalizedText name;
  final double lat;
  final double lon;

  /// Fixed offset. Indian cities have no DST; diaspora cities with DST are
  /// Phase B (timezone database) — see ASSUMPTIONS.md.
  final int utcOffsetMin;
  final String tzName;

  /// Wall-clock time in this city for a UTC instant (returned as a UTC-flagged
  /// DateTime whose fields are the local wall-clock fields).
  DateTime local(DateTime utc) =>
      utc.toUtc().add(Duration(minutes: utcOffsetMin));

  DateTime utcFromLocal(int y, int m, int d, [int h = 0, int min = 0]) =>
      DateTime.utc(y, m, d, h, min).subtract(Duration(minutes: utcOffsetMin));
}

class Span {
  const Span(this.start, this.end);
  final DateTime start; // UTC
  final DateTime end; // UTC
  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);
}

class TithiInfo {
  const TithiInfo(this.number, this.endsAt);

  /// 1..30 (1..15 shukla, 16..30 krishna; 15 = Pournami, 30 = Amavasya).
  final int number;
  final DateTime endsAt;
  bool get isShukla => number <= 15;
  int get inPaksha => isShukla ? number : number - 15;
  LocalizedText get paksha => isShukla ? shuklaPaksha : krishnaPaksha;
  LocalizedText get name {
    if (number == 15) return pournami;
    if (number == 30) return amavasya;
    return tithiNames[inPaksha - 1];
  }
}

class IndexedInfo {
  const IndexedInfo(this.number, this.name, this.endsAt);
  final int number; // 1-based
  final LocalizedText name;
  final DateTime endsAt;
}

class PanchangDay {
  PanchangDay({
    required this.city,
    required this.year,
    required this.month,
    required this.day,
    required this.weekday,
    required this.sunrise,
    required this.sunset,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.masaIndex,
    required this.adhikaMasa,
    required this.samvatsaraIndex,
    required this.sunRashi,
    required this.rahuKalam,
    required this.yamagandam,
    required this.gulikaKalam,
    required this.tithisInDay,
  });

  final City city;
  final int year, month, day;

  /// ISO weekday of the civil date.
  final int weekday;
  final DateTime sunrise, sunset; // UTC
  final TithiInfo tithi; // prevailing at sunrise
  final IndexedInfo nakshatra, yoga, karana;
  final int masaIndex; // 0 = Chaitra
  final bool adhikaMasa;
  final int samvatsaraIndex; // 0 = Prabhava
  final int sunRashi; // 0 = Mesha (sidereal)
  final Span rahuKalam, yamagandam, gulikaKalam;

  /// Every tithi number touching this sunrise-to-next-sunrise day (for
  /// vratam surfacing, e.g. Ekadashi starting mid-day).
  final List<int> tithisInDay;

  LocalizedText get masa => masaNames[masaIndex];
  LocalizedText get samvatsara => samvatsaraName(samvatsaraIndex);
  LocalizedText get weekdayName => weekdayNames[weekday - 1];
  LocalizedText get vasara => vasaraSanskrit[weekday - 1];
  LocalizedText get ritu => rituNames[masaIndex ~/ 2];

  /// Uttarayana while the sidereal Sun is in Makara..Mithuna.
  bool get uttarayana => sunRashi >= 9 || sunRashi <= 2;
  LocalizedText get ayana => uttarayana
      ? const LocalizedText.bi('Uttarayana', 'ఉత్తరాయణం')
      : const LocalizedText.bi('Dakshinayana', 'దక్షిణాయనం');

  String get isoDate =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

class PanchangamCalculator {
  const PanchangamCalculator();

  // Segment (1..8 of daytime) by ISO weekday Mon..Sun.
  static const _rahu = [2, 7, 5, 6, 4, 3, 8];
  static const _yama = [4, 3, 2, 1, 7, 6, 5];
  static const _gulika = [6, 5, 4, 3, 2, 1, 7];

  PanchangDay compute(City city, int year, int month, int day) {
    final st = sunTimes(year, month, day, city.lat, city.lon);
    if (st == null) {
      throw StateError('No sunrise at ${city.id} on $year-$month-$day');
    }
    final dt = DateTime.utc(year, month, day);
    final next = dt.add(const Duration(days: 1));
    final st2 = sunTimes(next.year, next.month, next.day, city.lat, city.lon)!;

    final jdRise = julianDay(st.sunrise);

    int tithiAt(double jd) => (elongation(jd) / 12).floor() + 1;
    int nakAt(double jd) => (siderealMoon(jd) / (360 / 27)).floor() + 1;
    int yogaAt(double jd) =>
        (((siderealSun(jd) + siderealMoon(jd)) % 360) / (360 / 27)).floor() + 1;
    int karAt(double jd) => (elongation(jd) / 6).floor() + 1;

    final tNum = tithiAt(jdRise);
    final tithi = TithiInfo(tNum, _nextChange(jdRise, tithiAt));
    final nNum = nakAt(jdRise);
    final yNum = yogaAt(jdRise);
    final kNum = karAt(jdRise);

    // tithis touching this day
    final tithis = <int>[tNum];
    var cursor = julianDay(tithi.endsAt);
    final jdNextRise = julianDay(st2.sunrise);
    while (cursor < jdNextRise) {
      final n = tithiAt(cursor + 1e-4);
      tithis.add(n);
      cursor = julianDay(_nextChange(cursor + 1e-4, tithiAt));
    }

    // Amanta masa: rashi of Sun at the preceding new moon.
    final prevNewMoon = _previousNewMoon(jdRise);
    final nextNewMoon = _nextNewMoon(jdRise);
    final rPrev = (siderealSun(prevNewMoon) / 30).floor();
    final rNext = (siderealSun(nextNewMoon) / 30).floor();
    final masaIndex = (rPrev + 1) % 12;
    final adhika = rPrev == rNext;

    // Saka year changes at Chaitra shukla pratipada (Ugadi).
    final saka = year - 78 - ((month <= 4 && masaIndex >= 9) ? 1 : 0);
    final samIndex = (saka + 11) % 60;

    final wd = dt.weekday;
    Span seg(int n) {
      final len = st.sunset.difference(st.sunrise).inMilliseconds / 8;
      final s = st.sunrise.add(Duration(milliseconds: (len * (n - 1)).round()));
      return Span(s, s.add(Duration(milliseconds: len.round())));
    }

    return PanchangDay(
      city: city,
      year: year,
      month: month,
      day: day,
      weekday: wd,
      sunrise: st.sunrise,
      sunset: st.sunset,
      tithi: tithi,
      nakshatra: IndexedInfo(nNum, nakshatraNames[nNum - 1], _nextChange(jdRise, nakAt)),
      yoga: IndexedInfo(yNum, yogaNames[yNum - 1], _nextChange(jdRise, yogaAt)),
      karana: IndexedInfo(kNum, karanaName(kNum), _nextChange(jdRise, karAt)),
      masaIndex: masaIndex,
      adhikaMasa: adhika,
      samvatsaraIndex: samIndex,
      sunRashi: (siderealSun(jdRise) / 30).floor(),
      rahuKalam: seg(_rahu[wd - 1]),
      yamagandam: seg(_yama[wd - 1]),
      gulikaKalam: seg(_gulika[wd - 1]),
      tithisInDay: tithis,
    );
  }

  /// First instant after [jd] where [f] changes value (±30 s).
  DateTime _nextChange(double jd, int Function(double) f) {
    final v0 = f(jd);
    const step = 1 / 24; // 1 h
    var a = jd, b = jd + step;
    var guard = 0;
    while (f(b) == v0 && guard++ < 24 * 3) {
      a = b;
      b += step;
    }
    for (var i = 0; i < 12; i++) {
      final mid = (a + b) / 2;
      if (f(mid) == v0) {
        a = mid;
      } else {
        b = mid;
      }
    }
    return fromJulianDay(b);
  }

  double _previousNewMoon(double jd) {
    // elongation decreases going backwards; step back until wrap.
    var b = jd, a = jd - 1;
    while (elongation(a) < elongation(b)) {
      b = a;
      a -= 1;
    }
    for (var i = 0; i < 20; i++) {
      final mid = (a + b) / 2;
      if (elongation(mid) > 180) {
        a = mid;
      } else {
        b = mid;
      }
    }
    return b;
  }

  double _nextNewMoon(double jd) {
    var a = jd, b = jd + 1;
    while (elongation(b) > elongation(a)) {
      a = b;
      b += 1;
    }
    for (var i = 0; i < 20; i++) {
      final mid = (a + b) / 2;
      if (elongation(mid) > 180) {
        a = mid;
      } else {
        b = mid;
      }
    }
    return b;
  }

  /// Next occurrence (on or after the given date) of a day whose sunrise tithi
  /// is [tithiNumber]; used for "next Ekadashi" surfacing.
  PanchangDay? nextTithi(City city, DateTime fromLocalDate, Set<int> tithiNumbers,
      {int maxDays = 40}) {
    for (var i = 0; i < maxDays; i++) {
      final d = fromLocalDate.add(Duration(days: i));
      final p = compute(city, d.year, d.month, d.day);
      if (tithiNumbers.contains(p.tithi.number)) return p;
    }
    return null;
  }
}
