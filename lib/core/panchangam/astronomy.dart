/// Low-level solar & lunar ephemeris (Jean Meeus, *Astronomical Algorithms*,
/// 2nd ed., ch. 25 & 47) and sunrise/sunset (NOAA method).
///
/// Pure Dart, no Flutter imports, deterministic: safe for isolates and tests.
/// Accuracy: Sun ≈ 0.01°, Moon ≈ 0.003° (main 60 terms), which keeps tithi /
/// nakshatra end-times within a few minutes.
library;

import 'dart:math' as math;

const double _deg = math.pi / 180.0;

double _norm360(double x) {
  final r = x % 360.0;
  return r < 0 ? r + 360.0 : r;
}

double _sin(double d) => math.sin(d * _deg);
double _cos(double d) => math.cos(d * _deg);

/// Julian Day (UT) for a UTC instant.
double julianDay(DateTime t) {
  final u = t.toUtc();
  return u.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
}

DateTime fromJulianDay(double jd) => DateTime.fromMillisecondsSinceEpoch(
    ((jd - 2440587.5) * 86400000.0).round(),
    isUtc: true);

/// ΔT (TT − UT) in seconds; good to ~1 s for 2020–2035.
double deltaTSeconds(double jdUt) {
  final y = 2000 + (jdUt - 2451545.0) / 365.25;
  final t = y - 2000;
  return 62.92 + 0.32217 * t + 0.005589 * t * t;
}

double _centuriesTT(double jdUt) =>
    (jdUt + deltaTSeconds(jdUt) / 86400.0 - 2451545.0) / 36525.0;

/// Nutation in longitude (degrees), low-precision (≈0.5").
double _nutationLon(double t) {
  final omega = 125.04452 - 1934.136261 * t;
  final l = 280.4665 + 36000.7698 * t;
  final lp = 218.3165 + 481267.8813 * t;
  return (-17.20 * _sin(omega) -
          1.32 * _sin(2 * l) -
          0.23 * _sin(2 * lp) +
          0.21 * _sin(2 * omega)) /
      3600.0;
}

/// Apparent geocentric ecliptic longitude of the Sun (tropical, degrees).
double sunLongitude(double jdUt) {
  final t = _centuriesTT(jdUt);
  final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
  final m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
  final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * _sin(m) +
      (0.019993 - 0.000101 * t) * _sin(2 * m) +
      0.000289 * _sin(3 * m);
  final trueLon = l0 + c;
  // aberration −20.4898"/R, R≈1
  return _norm360(trueLon - 0.005691611 + _nutationLon(t));
}

// Meeus table 47.A: D, M, M', F, Σl coefficient (1e-6 deg).
const List<List<int>> _moonTerms = [
  [0, 0, 1, 0, 6288774], [2, 0, -1, 0, 1274027], [2, 0, 0, 0, 658314],
  [0, 0, 2, 0, 213618], [0, 1, 0, 0, -185116], [0, 0, 0, 2, -114332],
  [2, 0, -2, 0, 58793], [2, -1, -1, 0, 57066], [2, 0, 1, 0, 53322],
  [2, -1, 0, 0, 45758], [0, 1, -1, 0, -40923], [1, 0, 0, 0, -34720],
  [0, 1, 1, 0, -30383], [2, 0, 0, -2, 15327], [0, 0, 1, 2, -12528],
  [0, 0, 1, -2, 10980], [4, 0, -1, 0, 10675], [0, 0, 3, 0, 10034],
  [4, 0, -2, 0, 8548], [2, 1, -1, 0, -7888], [2, 1, 0, 0, -6766],
  [1, 0, -1, 0, -5163], [1, 1, 0, 0, 4987], [2, -1, 1, 0, 4036],
  [2, 0, 2, 0, 3994], [4, 0, 0, 0, 3861], [2, 0, -3, 0, 3665],
  [0, 1, -2, 0, -2689], [2, 0, -1, 2, -2602], [2, -1, -2, 0, 2390],
  [1, 0, 1, 0, -2348], [2, -2, 0, 0, 2236], [0, 1, 2, 0, -2120],
  [0, 2, 0, 0, -2069], [2, -2, -1, 0, 2048], [2, 0, 1, -2, -1773],
  [2, 0, 0, 2, -1595], [4, -1, -1, 0, 1215], [0, 0, 2, 2, -1110],
  [3, 0, -1, 0, -892], [2, 1, 1, 0, -810], [4, -1, -2, 0, 759],
  [0, 2, -1, 0, -713], [2, 2, -1, 0, -700], [2, 1, -2, 0, 691],
  [2, -1, 0, -2, 596], [4, 0, 1, 0, 549], [0, 0, 4, 0, 537],
  [4, -1, 0, 0, 520], [1, 0, -2, 0, -487], [2, 1, 0, -2, -399],
  [0, 0, 2, -2, -381], [1, 1, 1, 0, 351], [3, 0, -2, 0, -340],
  [4, 0, -3, 0, 330], [2, -1, 2, 0, 327], [0, 2, 1, 0, -323],
  [1, 1, -1, 0, 299], [2, 0, 3, 0, 294],
];

/// Apparent geocentric ecliptic longitude of the Moon (tropical, degrees).
double moonLongitude(double jdUt) {
  final t = _centuriesTT(jdUt);
  final t2 = t * t, t3 = t2 * t, t4 = t3 * t;
  final lp = 218.3164477 + 481267.88123421 * t - 0.0015786 * t2 +
      t3 / 538841 - t4 / 65194000;
  final d = 297.8501921 + 445267.1114034 * t - 0.0018819 * t2 +
      t3 / 545868 - t4 / 113065000;
  final m = 357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000;
  final mp = 134.9633964 + 477198.8675055 * t + 0.0087414 * t2 +
      t3 / 69699 - t4 / 14712000;
  final f = 93.2720950 + 483202.0175233 * t - 0.0036539 * t2 -
      t3 / 3526000 + t4 / 863310000;
  final e = 1 - 0.002516 * t - 0.0000074 * t2;
  final a1 = 119.75 + 131.849 * t;
  final a2 = 53.09 + 479264.290 * t;

  double sum = 0;
  for (final term in _moonTerms) {
    final arg = term[0] * d + term[1] * m + term[2] * mp + term[3] * f;
    double coeff = term[4].toDouble();
    final mAbs = term[1].abs();
    if (mAbs == 1) coeff *= e;
    if (mAbs == 2) coeff *= e * e;
    sum += coeff * _sin(arg);
  }
  sum += 3958 * _sin(a1) + 1962 * _sin(lp - f) + 318 * _sin(a2);
  return _norm360(lp + sum / 1e6 + _nutationLon(t));
}

/// Lahiri (Chitrapaksha) ayanamsa in degrees. Linear model anchored at
/// J2000 = 23°51'11" with 50.29"/yr precession; error < 10" for 1950–2050.
double lahiriAyanamsa(double jdUt) {
  final years = (jdUt - 2451545.0) / 365.25;
  return 23.853056 + years * 50.29 / 3600.0 +
      // slow quadratic term of general precession
      years * years * 0.000111 / 3600.0;
}

double siderealSun(double jdUt) =>
    _norm360(sunLongitude(jdUt) - lahiriAyanamsa(jdUt));
double siderealMoon(double jdUt) =>
    _norm360(moonLongitude(jdUt) - lahiriAyanamsa(jdUt));

/// Moon − Sun elongation, 0..360 (drives tithi & karana).
double elongation(double jdUt) =>
    _norm360(moonLongitude(jdUt) - sunLongitude(jdUt));

/// Sunrise/sunset for a civil date at a location. Returns UTC instants, or
/// null for polar day/night.
({DateTime sunrise, DateTime sunset, DateTime noon})? sunTimes(
    int year, int month, int day, double lat, double lon) {
  // Start from 0h UTC of the civil date and iterate to the actual events.
  final base = julianDay(DateTime.utc(year, month, day));
  double? event(bool rising) {
    double guessMin = rising ? 360 : 1080; // minutes UTC, refined below
    guessMin -= lon * 4;
    for (var i = 0; i < 3; i++) {
      final jd = base + guessMin / 1440.0;
      final t = _centuriesTT(jd);
      final lambda = sunLongitude(jd);
      final eps = 23.439291 - 0.0130042 * t +
          0.00256 * _cos(125.04 - 1934.136 * t);
      final dec = math.asin(_sin(eps) * _sin(lambda)) / _deg;
      final ra = _norm360(math.atan2(_cos(eps) * _sin(lambda), _cos(lambda)) / _deg);
      final l0 = _norm360(280.46646 + 36000.76983 * t);
      var eot = l0 - 0.0057183 - ra + _nutationLon(t) * _cos(eps);
      eot = ((eot + 180) % 360) - 180; // degrees
      final cosH = (_sin(-0.833) - _sin(lat) * _sin(dec)) / (_cos(lat) * _cos(dec));
      if (cosH < -1 || cosH > 1) return null;
      final h = math.acos(cosH) / _deg;
      final transit = 720 - 4 * lon - 4 * eot;
      guessMin = rising ? transit - 4 * h : transit + 4 * h;
    }
    return guessMin;
  }

  final r = event(true), s = event(false);
  if (r == null || s == null) return null;
  DateTime at(double min) => DateTime.utc(year, month, day)
      .add(Duration(milliseconds: (min * 60000).round()));
  return (sunrise: at(r), sunset: at(s), noon: at((r + s) / 2));
}
