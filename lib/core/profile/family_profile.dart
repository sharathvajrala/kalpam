import 'dart:convert';

/// One person whose Sankalpam can be spoken. Several live on one device
/// (family profiles); the active one is switched with one tap.
///
/// Approved data model (project-docs/DATA_MODEL.md): name + gotram required,
/// janma nakshatram optional. Nothing else is stored about a person.
class FamilyProfile {
  const FamilyProfile({required this.id, required this.name, required this.gotra, this.janmaNakshatra});

  final String id;
  final String name;
  final String gotra;

  /// 1..27, optional.
  final int? janmaNakshatra;

  bool get isComplete => name.trim().isNotEmpty && gotra.trim().isNotEmpty;

  FamilyProfile copyWith({String? name, String? gotra, int? janmaNakshatra, bool clearNakshatra = false}) =>
      FamilyProfile(
        id: id,
        name: name ?? this.name,
        gotra: gotra ?? this.gotra,
        janmaNakshatra: clearNakshatra ? null : (janmaNakshatra ?? this.janmaNakshatra),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'gotra': gotra,
        if (janmaNakshatra != null) 'janmaNakshatra': janmaNakshatra,
      };

  factory FamilyProfile.fromJson(Map<String, dynamic> j) => FamilyProfile(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        gotra: j['gotra'] as String? ?? '',
        janmaNakshatra: (j['janmaNakshatra'] as num?)?.toInt(),
      );

  static String encodeAll(List<FamilyProfile> list) => jsonEncode([for (final p in list) p.toJson()]);
  static List<FamilyProfile> decodeAll(String s) =>
      (jsonDecode(s) as List).map((e) => FamilyProfile.fromJson((e as Map).cast<String, dynamic>())).toList();
}

/// Daily reminder time (local wall clock), stored as "HH:MM".
class ReminderTime {
  const ReminderTime(this.hour, this.minute);
  final int hour, minute;

  static ReminderTime? parse(String? s) {
    if (s == null) return null;
    final p = s.split(':');
    if (p.length != 2) return null;
    final h = int.tryParse(p[0]), m = int.tryParse(p[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) return null;
    return ReminderTime(h, m);
  }

  String get hhmm => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  String get display {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:${minute.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM'}';
  }
}
