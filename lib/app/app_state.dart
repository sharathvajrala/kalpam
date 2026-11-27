import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/content/localized.dart';
import '../core/content/models.dart';
import '../core/content/pack_repository.dart';
import '../core/flagship/flagship_engine.dart';
import '../core/panchangam/panchangam.dart';
import '../core/sankalpam/sankalpam.dart';
import '../core/tracker/deeksha_tracker.dart';
import '../data/cities.dart';

/// App-wide state: user profile, settings, trackers. Everything persists
/// locally — no account needed.
class AppState extends ChangeNotifier {
  AppState({required this.repo, required SharedPreferences prefs, DateTime Function()? clock})
      : _prefs = prefs, // ignore: prefer_initializing_formals
        _clock = clock ?? DateTime.now {
    flagship = FlagshipEngine(repo.seasons);
    _load();
  }

  final PackRepository repo;
  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  late final FlagshipEngine flagship;
  final _calc = const PanchangamCalculator();
  final Map<String, PanchangDay> _panchangCache = {};

  bool onboarded = false;
  String lang = 'te';
  bool elderMode = false;
  String devoteeName = '';
  String gotra = '';
  /// null until the user picks a city; Hyderabad is only the fallback.
  String? cityId;
  String deityId = 'ayyappa';
  bool groupsNotify = false;
  final Map<String, DeekshaRecord> deekshas = {};

  /// ISO date -> recurring vratam ids joined that day.
  final Map<String, Set<String>> joinedRecurring = {};

  void _load() {
    onboarded = _prefs.getBool('onboarded') ?? false;
    lang = _prefs.getString('lang') ?? 'te';
    elderMode = _prefs.getBool('elder') ?? false;
    devoteeName = _prefs.getString('name') ?? '';
    gotra = _prefs.getString('gotra') ?? '';
    cityId = _prefs.getString('city');
    deityId = _prefs.getString('deity') ?? 'ayyappa';
    if (!repo.deities.containsKey(deityId)) deityId = repo.deities.keys.first;
    groupsNotify = _prefs.getBool('groupsNotify') ?? false;
    for (final key in _prefs.getKeys().where((k) => k.startsWith('deeksha:'))) {
      try {
        final r = DeekshaRecord.decode(_prefs.getString(key)!);
        deekshas[r.vratamId] = r;
      } catch (_) {/* corrupted record: ignore */}
    }
    for (final s in _prefs.getStringList('joinedRecurring') ?? const <String>[]) {
      final parts = s.split('|');
      if (parts.length == 2) joinedRecurring.putIfAbsent(parts[0], () => {}).add(parts[1]);
    }
  }

  // ------------------------------------------------------------ getters
  DateTime get now => _clock();
  bool get hasCity => cityId != null;
  City get city {
    if (cityId == 'gps') {
      final near = cityById(_prefs.getString('gpsNear'));
      return City(
        id: 'gps',
        name: near.name,
        lat: _prefs.getDouble('gpsLat') ?? near.lat,
        lon: _prefs.getDouble('gpsLon') ?? near.lon,
        utcOffsetMin: _prefs.getInt('gpsOffset') ?? near.utcOffsetMin,
      );
    }
    return cityById(cityId);
  }
  DeityPack get deity => repo.deities[deityId]!;

  /// Today's civil date in the user's city.
  DateTime get today {
    final l = city.local(now.toUtc());
    return DateTime.utc(l.year, l.month, l.day);
  }

  PanchangDay panchangFor(DateTime civil) {
    final key = '$cityId:${DeekshaRecord.iso(civil)}';
    return _panchangCache.putIfAbsent(key, () => _calc.compute(city, civil.year, civil.month, civil.day));
  }

  PanchangDay get panchang => panchangFor(today);
  FlagshipState? get hero => flagship.heroFor(today);
  List<FlagshipSeason> get secondary => flagship.secondaryFor(today);

  /// Weekday god for today (the first listed that has a pack).
  DeityPack? get weekdayGod {
    for (final id in repo.weeklyGods[today.weekday] ?? const <String>[]) {
      final d = repo.deities[id];
      if (d != null) return d;
    }
    return null;
  }

  List<RecurringVratam> get recurringToday => repo.recurringOn(panchang.tithisInDay);
  bool isRecurringJoined(String id) => joinedRecurring[DeekshaRecord.iso(today)]?.contains(id) ?? false;

  SankalpamText sankalpam({required DeityPack deity, required VratamPack? vratam}) =>
      const SankalpamGenerator().generate(
        SankalpamInput(
          day: panchang,
          devoteeName: devoteeName,
          gotra: gotra,
          deityName: deity.name,
          purpose: vratam?.sankalpaPurpose ?? dailyPurpose,
        ),
        lang,
      );

  // ------------------------------------------------------------ mutations
  Future<void> completeOnboarding() async {
    onboarded = true;
    await _prefs.setBool('onboarded', true);
    notifyListeners();
  }

  Future<void> setLang(String v) async {
    lang = v;
    await _prefs.setString('lang', v);
    notifyListeners();
  }

  Future<void> setElderMode(bool v) async {
    elderMode = v;
    await _prefs.setBool('elder', v);
    notifyListeners();
  }

  Future<void> setProfile({String? name, String? gotraV, String? city, String? deity}) async {
    if (name != null) devoteeName = name;
    if (gotraV != null) gotra = gotraV;
    if (city != null) {
      cityId = city;
      _panchangCache.clear();
    }
    if (deity != null) deityId = deity;
    await Future.wait([
      _prefs.setString('name', devoteeName),
      _prefs.setString('gotra', gotra),
      if (cityId != null) _prefs.setString('city', cityId!),
      _prefs.setString('deity', deityId),
    ]);
    notifyListeners();
  }

  /// Exact GPS position, labelled with the nearest listed city.
  Future<void> setGpsCity({required double lat, required double lon, required int utcOffsetMin, required String nearCityId}) async {
    await Future.wait([
      _prefs.setDouble('gpsLat', lat),
      _prefs.setDouble('gpsLon', lon),
      _prefs.setInt('gpsOffset', utcOffsetMin),
      _prefs.setString('gpsNear', nearCityId),
    ]);
    await setProfile(city: 'gps');
  }

  Future<void> setGroupsNotify(bool v) async {
    groupsNotify = v;
    await _prefs.setBool('groupsNotify', v);
    notifyListeners();
  }

  Future<void> startDeeksha(String vratamId, DateTime start, int days) async {
    final r = DeekshaRecord(vratamId: vratamId, startDate: DeekshaRecord.civil(start), totalDays: days);
    deekshas[vratamId] = r;
    await _saveDeeksha(r);
  }

  Future<void> toggleCheck(String vratamId, String itemId, {DateTime? day}) async {
    final r = deekshas[vratamId];
    if (r == null) return;
    r.toggle(day ?? today, itemId);
    await _saveDeeksha(r);
  }

  Future<void> completeDeeksha(String vratamId) async {
    final r = deekshas[vratamId];
    if (r == null) return;
    r.completedAt = now;
    await _saveDeeksha(r);
  }

  Future<void> cancelDeeksha(String vratamId) async {
    deekshas.remove(vratamId);
    await _prefs.remove('deeksha:$vratamId');
    notifyListeners();
  }

  Future<void> _saveDeeksha(DeekshaRecord r) async {
    await _prefs.setString('deeksha:${r.vratamId}', r.encode());
    notifyListeners();
  }

  /// Free-standing checklists that work without starting a vratam
  /// (samagri, irumudi…), keyed e.g. "ayyappa_mandala:samagri".
  Set<String> checklist(String key) => (_prefs.getStringList('cl:$key') ?? const <String>[]).toSet();

  Future<void> toggleChecklist(String key, String id) async {
    final s = checklist(key);
    if (!s.remove(id)) s.add(id);
    await _prefs.setStringList('cl:$key', s.toList());
    notifyListeners();
  }

  Future<void> toggleRecurring(String id) async {
    final k = DeekshaRecord.iso(today);
    final s = joinedRecurring.putIfAbsent(k, () => {});
    if (!s.remove(id)) s.add(id);
    await _prefs.setStringList('joinedRecurring',
        [for (final e in joinedRecurring.entries) for (final v in e.value) '${e.key}|$v']);
    notifyListeners();
  }
}

/// Default Sankalpam purpose for daily poojas.
const dailyPurpose = LocalizedText.bi(
  'for the grace of the Lord upon me and my family',
  'మమ సకుటుంబస్య శ్రీ స్వామి అనుగ్రహ సిద్ధ్యర్థం',
);
