import 'dart:convert';

import 'localized.dart';
import 'models.dart';

/// Reads a pack file's text. Bundled packs use the Flutter AssetBundle;
/// downloaded packs use the app documents dir. Injected for testability.
typedef PackReader = Future<String> Function(String path);

class RecurringVratam {
  RecurringVratam(this.id, this.name, this.tithis, this.deityId);
  final String id;
  final LocalizedText name;
  final Set<int> tithis;
  final String deityId;
}

/// In-memory index of all installed content packs. Screens render whatever
/// is here; adding a pack adds content without code changes.
class PackRepository {
  PackRepository._();

  final Map<String, DeityPack> deities = {};
  final Map<String, VratamPack> vratams = {};
  final Map<String, StotraItem> stotras = {};
  final Map<String, BhajanItem> bhajans = {};
  final List<FlagshipSeason> seasons = [];
  final Map<int, List<String>> weeklyGods = {};
  final List<RecurringVratam> recurring = [];
  final List<String> loadErrors = [];

  /// Loads every pack listed in `index.json`. A broken pack is skipped and
  /// reported in [loadErrors]; the app keeps working with the rest.
  static Future<PackRepository> load(PackReader read, {String root = 'assets/packs'}) async {
    final repo = PackRepository._();
    final index = jsonDecode(await read('$root/index.json')) as Map<String, dynamic>;
    for (final entry in (index['packs'] as List).cast<Map<String, dynamic>>()) {
      final path = entry['path'] as String;
      try {
        final j = jsonDecode(await read('$root/$path')) as Map<String, dynamic>;
        repo._add(j);
      } catch (e) {
        repo.loadErrors.add('$path: $e');
      }
    }
    repo.seasons.sort((a, b) => a.start.compareTo(b.start));
    return repo;
  }

  void _add(Json j) {
    final schema = (j['schema'] as String).split('/').first;
    switch (schema) {
      case 'kalpam.deity':
        final d = DeityPack.fromJson(j);
        deities[d.id] = d;
      case 'kalpam.vratam':
        final v = VratamPack.fromJson(j);
        vratams[v.id] = v;
      case 'kalpam.stotra':
        final s = StotraItem.fromJson(j);
        stotras[s.id] = s;
      case 'kalpam.bhajan':
        final b = BhajanItem.fromJson(j);
        bhajans[b.id] = b;
      case 'kalpam.flagship':
        for (final s in (j['seasons'] as List).cast<Map<String, dynamic>>()) {
          seasons.add(FlagshipSeason.fromJson(s));
        }
        final wg = (j['weeklyGods'] as Map?) ?? {};
        wg.forEach((k, v) => weeklyGods[int.parse(k as String)] =
            (v as List).map((e) => e.toString()).toList());
        for (final r in (j['recurring'] as List? ?? []).cast<Map<String, dynamic>>()) {
          recurring.add(RecurringVratam(
            r['id'] as String,
            LocalizedText.fromJson(r['name']),
            (r['tithis'] as List).map((e) => (e as num).toInt()).toSet(),
            r['deityId'] as String,
          ));
        }
      default:
        throw FormatException('Unknown pack schema $schema');
    }
  }

  List<StotraItem> stotrasFor(String deityId) =>
      stotras.values.where((s) => s.deityIds.contains(deityId)).toList();
  List<BhajanItem> bhajansFor(String deityId) =>
      bhajans.values.where((b) => b.deityIds.contains(deityId)).toList();
  List<StotraItem> parayanamFor(int weekday) =>
      stotras.values.where((s) => s.parayanamDays.contains(weekday)).toList();

  /// Recurring vratams that fall on a day touching these tithis.
  List<RecurringVratam> recurringOn(List<int> tithis) =>
      recurring.where((r) => r.tithis.any(tithis.contains)).toList();
}
