/// A user-facing string in several languages. `en` is mandatory; every other
/// language falls back to English when missing.
class LocalizedText {
  const LocalizedText(this.values)
      : _en = null,
        _te = null;

  /// Compact const form for English + Telugu built-in strings.
  const LocalizedText.bi(String en, String te)
      : values = const {},
        _en = en,
        _te = te;

  final Map<String, String> values;
  final String? _en;
  final String? _te;

  factory LocalizedText.fromJson(Object? json) {
    if (json == null) return const LocalizedText({'en': ''});
    if (json is String) return LocalizedText({'en': json});
    if (json is Map) {
      final m = json.map((k, v) => MapEntry(k.toString(), v.toString()));
      if (!m.containsKey('en')) {
        throw FormatException('LocalizedText missing "en": $json');
      }
      return LocalizedText(m);
    }
    throw FormatException('Bad LocalizedText: $json');
  }

  Map<String, String> get _all => {
        ...values,
        if (_en != null) 'en': _en,
        if (_te != null) 'te': _te,
      };

  String get en => _all['en'] ?? '';

  /// Text in [lang], falling back to English.
  String of(String lang) {
    final all = _all;
    final v = all[lang];
    return (v == null || v.isEmpty) ? (all['en'] ?? '') : v;
  }

  bool has(String lang) => (_all[lang] ?? '').isNotEmpty;

  Map<String, String> toJson() => _all;

  @override
  String toString() => en;
}
