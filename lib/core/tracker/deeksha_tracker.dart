/// Multi-day vratam / mala tracker. Streaks live here and only here — never
/// inside the sanctum (reverence rule).
library;

import 'dart:convert';

class DeekshaRecord {
  DeekshaRecord({
    required this.vratamId,
    required this.startDate,
    required this.totalDays,
    Map<String, Set<String>>? checks,
    this.completedAt,
  }) : checks = checks ?? {};

  final String vratamId;
  final DateTime startDate; // civil date (UTC midnight)
  final int totalDays;

  /// ISO date -> checked item ids (prefixed "m:" morning, "e:" evening,
  /// "s:" samagri, "i:" irumudi).
  final Map<String, Set<String>> checks;
  DateTime? completedAt;

  static DateTime civil(DateTime d) => DateTime.utc(d.year, d.month, d.day);
  static String iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 1-based day number for [today]; 0 before start; > totalDays after end.
  int dayNumber(DateTime today) {
    final t = civil(today);
    if (t.isBefore(startDate)) return 0;
    return t.difference(startDate).inDays + 1;
  }

  DateTime get endDate => startDate.add(Duration(days: totalDays - 1));
  bool isFinished(DateTime today) => dayNumber(today) > totalDays || completedAt != null;
  int daysLeft(DateTime today) => (totalDays - dayNumber(today)).clamp(0, totalDays);

  Set<String> checksOn(DateTime day) => checks[iso(civil(day))] ?? <String>{};

  void toggle(DateTime day, String id) {
    final k = iso(civil(day));
    final s = checks.putIfAbsent(k, () => <String>{});
    if (!s.remove(id)) s.add(id);
  }

  /// A day counts as kept when every required morning+evening item was ticked.
  bool dayKept(DateTime day, Iterable<String> requiredIds) =>
      requiredIds.every(checksOn(day).contains);

  /// Consecutive kept days ending yesterday-or-today.
  int streak(DateTime today, Iterable<String> requiredIds) {
    var d = civil(today);
    if (!dayKept(d, requiredIds)) d = d.subtract(const Duration(days: 1));
    var n = 0;
    while (!d.isBefore(startDate) && dayKept(d, requiredIds)) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  Map<String, Object?> toJson() => {
        'vratamId': vratamId,
        'start': iso(startDate),
        'days': totalDays,
        'checks': checks.map((k, v) => MapEntry(k, v.toList())),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory DeekshaRecord.fromJson(Map<String, dynamic> j) => DeekshaRecord(
        vratamId: j['vratamId'] as String,
        startDate: civil(DateTime.parse(j['start'] as String)),
        totalDays: (j['days'] as num).toInt(),
        checks: (j['checks'] as Map? ?? {}).map((k, v) =>
            MapEntry(k as String, (v as List).map((e) => e.toString()).toSet())),
        completedAt: j['completedAt'] == null ? null : DateTime.parse(j['completedAt'] as String),
      );

  String encode() => jsonEncode(toJson());
  static DeekshaRecord decode(String s) => DeekshaRecord.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
