import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/content/localized.dart';
import '../core/content/models.dart';
import '../core/content/pack_repository.dart';
import '../core/flagship/flagship_engine.dart';
import '../core/panchangam/panchangam.dart';
import '../core/profile/family_profile.dart';
import '../core/rituals/daily_rituals.dart';
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
  /// Family profiles; the active one's name/gotram are spoken in Sankalpam.
  final List<FamilyProfile> profiles = [];
  String? activeProfileId;

  /// Required at onboarding (approved data model).
  ReminderTime? morningReminder;
  ReminderTime? eveningReminder;
  /// null until the user picks a city; Hyderabad is only the fallback.
  String? cityId;
  /// A god id, or [dayGodId] for Day God mode (the weekday god leads).
  String deityId = 'ayyappa';
  static const dayGodId = 'day';
  EveningAnchor eveningAnchor = EveningAnchor.time;
  bool groupsNotify = false;
  final Map<String, DeekshaRecord> deekshas = {};

  /// ISO date -> recurring vratam ids joined that day.
  final Map<String, Set<String>> joinedRecurring = {};

  void _load() {
    onboarded = _prefs.getBool('onboarded') ?? false;
    lang = _prefs.getString('lang') ?? 'te';
    elderMode = _prefs.getBool('elder') ?? false;
    final rawProfiles = _prefs.getString('profiles');
    if (rawProfiles != null) {
      try {
        profiles.addAll(FamilyProfile.decodeAll(rawProfiles));
      } catch (_) {/* corrupted: start empty */}
    }
    activeProfileId = _prefs.getString('activeProfile');
    if (profiles.isNotEmpty && !profiles.any((p) => p.id == activeProfileId)) activeProfileId = profiles.first.id;
    morningReminder = ReminderTime.parse(_prefs.getString('remindMorning'));
    eveningReminder = ReminderTime.parse(_prefs.getString('remindEvening'));
    cityId = _prefs.getString('city');
    for (final k in const ['gpsLat', 'gpsLon', 'gpsOffset', 'gpsNear', 'name', 'gotra']) {
      _prefs.remove(k); // pre-approval keys: coordinates are never kept
    }
    if (cityId != null && !cities.any((c) => c.id == cityId)) cityId = null;
    deityId = _prefs.getString('deity') ?? 'ayyappa';
    if (deityId != dayGodId && !repo.deities.containsKey(deityId)) deityId = repo.deities.keys.first;
    eveningAnchor = _prefs.getString('eveningAnchor') == 'sunset' ? EveningAnchor.sunset : EveningAnchor.time;
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
  City get city => cityById(cityId);

  FamilyProfile? get activeProfile {
    for (final p in profiles) {
      if (p.id == activeProfileId) return p;
    }
    return profiles.isEmpty ? null : profiles.first;
  }

  String get devoteeName => activeProfile?.name ?? '';
  String get gotra => activeProfile?.gotra ?? '';
  bool get dayGodMode => deityId == dayGodId;

  /// The god who leads today: the chosen god, or in Day God mode the
  /// weekday god (founder map), falling back to Ayyappa.
  DeityPack get deity => dayGodMode ? (weekdayGod ?? repo.deities['ayyappa']!) : repo.deities[deityId]!;

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
          purpose: vratam?.sankalpaPurpose ?? deity.rituals.purpose ?? dailyPurpose,
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

  Future<void> setProfile({String? city, String? deity}) async {
    if (city != null) {
      cityId = city;
      _panchangCache.clear();
    }
    if (deity != null) deityId = deity;
    await Future.wait([
      if (cityId != null) _prefs.setString('city', cityId!),
      _prefs.setString('deity', deityId),
    ]);
    notifyListeners();
  }

  // ------------------------------------------------------------ family profiles
  Future<void> _saveProfiles() async {
    await _prefs.setString('profiles', FamilyProfile.encodeAll(profiles));
    if (activeProfileId != null) await _prefs.setString('activeProfile', activeProfileId!);
    notifyListeners();
  }

  /// Adds (or, with an existing id, updates) a profile. Returns its id.
  Future<String> saveFamilyProfile({String? id, required String name, required String gotra, int? janmaNakshatra}) async {
    final i = id == null ? -1 : profiles.indexWhere((p) => p.id == id);
    var pid = id ?? '';
    if (i < 0) {
      var n = profiles.length + 1;
      while (profiles.any((p) => p.id == 'p$n')) {
        n++;
      }
      pid = 'p$n';
    }
    final p = FamilyProfile(id: pid, name: name.trim(), gotra: gotra.trim(), janmaNakshatra: janmaNakshatra);
    if (i >= 0) {
      profiles[i] = p;
    } else {
      profiles.add(p);
    }
    activeProfileId ??= pid;
    await _saveProfiles();
    return pid;
  }

  Future<void> switchProfile(String id) async {
    if (!profiles.any((p) => p.id == id)) return;
    activeProfileId = id;
    await _saveProfiles();
  }

  Future<void> removeFamilyProfile(String id) async {
    if (profiles.length <= 1) return; // the device always keeps one profile
    profiles.removeWhere((p) => p.id == id);
    if (activeProfileId == id) activeProfileId = profiles.first.id;
    await _saveProfiles();
  }

  // ------------------------------------------------------------ reminders
  Future<void> setReminders({ReminderTime? morning, ReminderTime? evening}) async {
    if (morning != null) {
      morningReminder = morning;
      await _prefs.setString('remindMorning', morning.hhmm);
    }
    if (evening != null) {
      eveningReminder = evening;
      await _prefs.setString('remindEvening', evening.hhmm);
    }
    notifyListeners();
  }

  // ------------------------------------------------------------ export / delete
  /// Everything Kalpam stores on this device, as JSON (one-tap export).
  String exportAll() {
    final data = <String, Object?>{
      'app': 'Kalpam',
      'exportedAt': now.toUtc().toIso8601String(),
      'language': lang,
      'city': cityId == null ? null : city.name.en,
      'god': deityId,
      'eveningAnchor': eveningAnchor.name,
      'rituals': {
        for (final k in _prefs.getKeys().where((k) => k.startsWith('ritual:'))) k.substring(7): _prefs.getStringList(k),
      },
      'elderMode': elderMode,
      'reminders': {'morning': morningReminder?.hhmm, 'evening': eveningReminder?.hhmm},
      'profiles': [for (final p in profiles) p.toJson()],
      'activeProfile': activeProfileId,
      'deekshas': [for (final d in deekshas.values) d.toJson()],
      'joinedRecurring': {for (final e in joinedRecurring.entries) e.key: e.value.toList()},
      'checklists': {
        for (final k in _prefs.getKeys().where((k) => k.startsWith('cl:'))) k.substring(3): _prefs.getStringList(k),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Deletes every piece of data on this device and returns to onboarding.
  Future<void> deleteAll() async {
    await _prefs.clear();
    onboarded = false;
    lang = 'te';
    elderMode = false;
    profiles.clear();
    activeProfileId = null;
    morningReminder = null;
    eveningReminder = null;
    cityId = null;
    deityId = repo.deities.containsKey('ayyappa') ? 'ayyappa' : repo.deities.keys.first;
    eveningAnchor = EveningAnchor.time;
    groupsNotify = false;
    deekshas.clear();
    joinedRecurring.clear();
    _panchangCache.clear();
    notifyListeners();
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

  // ------------------------------------------------------------ daily rituals
  DailyRitualPlanner get ritualPlanner => DailyRitualPlanner(repo);

  RitualPlan ritualPlan(RitualSlot slot, {DateTime? day}) =>
      ritualPlanner.plan(deity, slot, form: archanaFormFor(day ?? today));

  bool ritualDone(RitualSlot slot, [DateTime? day]) =>
      (_prefs.getStringList('ritual:${DeekshaRecord.iso(day ?? today)}') ?? const []).contains(slot.name);

  Future<void> setRitualDone(RitualSlot slot, bool done) async {
    final k = 'ritual:${DeekshaRecord.iso(today)}';
    final s = (_prefs.getStringList(k) ?? const <String>[]).toSet();
    done ? s.add(slot.name) : s.remove(slot.name);
    await _prefs.setStringList(k, s.toList());
    notifyListeners();
  }

  /// Consecutive days the ritual was kept, ending today (or yesterday when
  /// today's is still ahead). Lives on Today only, never in the sanctum.
  int ritualStreak(RitualSlot slot) {
    var d = today;
    if (!ritualDone(slot, d)) d = d.subtract(const Duration(days: 1));
    var n = 0;
    while (ritualDone(slot, d)) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// Full (108) or short (16) archana: chosen per day, the last choice is
  /// remembered as the next day's default.
  ArchanaForm archanaFormFor(DateTime day) {
    final v = _prefs.getString('archanaForm:${DeekshaRecord.iso(day)}') ?? _prefs.getString('archanaFormLast');
    return v == 'short' ? ArchanaForm.short : ArchanaForm.full;
  }

  Future<void> setArchanaForm(ArchanaForm f) async {
    await _prefs.setString('archanaForm:${DeekshaRecord.iso(today)}', f.name);
    await _prefs.setString('archanaFormLast', f.name);
    notifyListeners();
  }

  Future<void> setEveningAnchor(EveningAnchor a) async {
    eveningAnchor = a;
    await _prefs.setString('eveningAnchor', a.name);
    notifyListeners();
  }

  /// When the ritual's reminder fires today (UTC): the morning time, and the
  /// evening time or local sunset (Settings choice).
  DateTime? ritualReminderAt(RitualSlot slot, [DateTime? day]) {
    final d = day ?? today;
    if (slot == RitualSlot.evening && eveningAnchor == EveningAnchor.sunset) return panchangFor(d).sunset;
    final t = slot == RitualSlot.morning ? morningReminder : eveningReminder;
    if (t == null) return null;
    return DateTime.utc(d.year, d.month, d.day, t.hour, t.minute).subtract(Duration(minutes: city.utcOffsetMin));
  }
}

enum EveningAnchor { time, sunset }

/// Default Sankalpam purpose for daily poojas.
const dailyPurpose = LocalizedText.bi(
  'for the grace of the Lord upon me and my family',
  'మమ సకుటుంబస్య శ్రీ స్వామి అనుగ్రహ సిద్ధ్యర్థం',
);
