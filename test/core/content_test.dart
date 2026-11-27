import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/core/content/localized.dart';
import 'package:kalpam/core/content/models.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/core/flagship/flagship_engine.dart';
import 'package:kalpam/core/panchangam/panchangam.dart';
import 'package:kalpam/pooja_engine/pooja_session.dart';
import 'package:kalpam/pooja_engine/sanctum_bridge.dart';
import 'package:kalpam/core/sankalpam/sankalpam.dart';
import 'package:kalpam/core/tracker/deeksha_tracker.dart';

Future<PackRepository> loadRepo() =>
    PackRepository.load((p) => File(p).readAsString());

void main() {
  late PackRepository repo;
  setUpAll(() async => repo = await loadRepo());

  group('content packs', () {
    test('all bundled packs load without errors', () {
      expect(repo.loadErrors, isEmpty);
      expect(repo.deities.keys, containsAll(['ayyappa', 'ganapathy', 'shiva', 'venkateswara', 'lakshmi', 'durga', 'hanuman', 'subrahmanya']));
      expect(repo.vratams['ayyappa_mandala']!.defaultDays, 41);
      expect(repo.seasons.length, greaterThanOrEqualTo(13));
    });

    test('every deity has the three guided lengths ending in closing', () {
      for (final d in repo.deities.values) {
        for (final id in ['nitya5', 'nitya15', 'shodasha']) {
          final p = d.pooja(id)!;
          expect(p.steps.first.upachara, 'sankalpam', reason: '${d.id}/$id');
          expect(p.steps.last.upachara, 'closing', reason: '${d.id}/$id');
        }
      }
    });

    test('every pack reference resolves', () {
      for (final d in repo.deities.values) {
        for (final s in [...d.stotras, ...d.chantings]) {
          expect(repo.stotras, contains(s), reason: '${d.id} -> $s');
        }
        for (final b in d.bhajans) {
          expect(repo.bhajans, contains(b));
        }
      }
      for (final s in repo.seasons) {
        expect(repo.deities, contains(s.deityId), reason: s.id);
        if (s.vratamId != null) expect(repo.vratams, contains(s.vratamId));
        if (s.chanting != null) expect(repo.stotras, contains(s.chanting));
      }
    });

    test('a bhajan with real audio but no license is rejected', () {
      expect(
          () => BhajanItem.fromJson({'schema': 'kalpam.bhajan/1', 'id': 'x', 'version': 1, 'title': 'x', 'audio': 'pack://x.opus'}),
          throwsFormatException);
    });

    test('LocalizedText falls back to English', () {
      const t = LocalizedText({'en': 'Pooja'});
      expect(t.of('te'), 'Pooja');
    });
  });

  group('flagship engine', () {
    late FlagshipEngine e;
    setUp(() => e = FlagshipEngine(repo.seasons));

    test('27 Nov 2026: Ayyappa Mandala, day 12, 48 days to Makara Jyothi', () {
      final s = e.heroFor(DateTime.utc(2026, 11, 27))!;
      expect(s.season.id, 'ayyappa_mandala_2026');
      expect(s.phase, FlagshipPhase.season);
      expect(s.dayOfSeason, 12);
      expect(s.daysToPeak, 48);
    });

    test('Dhanurmasam runs in parallel without displacing Ayyappa', () {
      final d = DateTime.utc(2026, 12, 20);
      expect(e.heroFor(d)!.season.id, 'ayyappa_mandala_2026');
      expect(e.secondaryFor(d).map((s) => s.id), contains('dhanurmasam_2026'));
    });

    test('14 Jan 2027 is peak, 16 Jan closing with Shiva teased next', () {
      expect(e.heroFor(DateTime.utc(2027, 1, 14))!.phase, FlagshipPhase.peak);
      final c = e.heroFor(DateTime.utc(2027, 1, 16))!;
      expect(c.phase, FlagshipPhase.closing);
      expect(c.next!.id, 'shiva_shivratri_2027');
    });

    test('25 Jan 2027 teases Shiva mala (T-20)', () {
      final s = e.heroFor(DateTime.utc(2027, 1, 25))!;
      expect(s.season.id, 'shiva_shivratri_2027');
      expect(s.phase, FlagshipPhase.teaser);
      expect(s.daysToStart, 20);
    });

    test('Pitru Paksham is never the hero', () {
      final s = e.heroFor(DateTime.utc(2027, 9, 20))!;
      expect(s.season.id, isNot('pitru_paksham_2027'));
      expect(s.season.quiet, isFalse);
    });
  });

  group('sankalpam', () {
    test('includes name, gotra, city, tithi, nakshatra and purpose in Telugu', () {
      const hyd = City(id: 'hyd', name: LocalizedText.bi('Hyderabad', 'హైదరాబాదు'), lat: 17.385, lon: 78.4867, utcOffsetMin: 330);
      final day = const PanchangamCalculator().compute(hyd, 2026, 12, 20);
      final v = repo.vratams['ayyappa_mandala']!;
      final t = const SankalpamGenerator().generate(
          SankalpamInput(day: day, devoteeName: 'శరత్', gotra: 'భారద్వాజ', deityName: repo.deities['ayyappa']!.name, purpose: v.sankalpaPurpose),
          'te').full;
      for (final s in ['శరత్', 'భారద్వాజ గోత్రస్య', 'హైదరాబాదు', 'ఏకాదశి', 'అశ్విని', 'మార్గశిరం', 'పరాభవ', 'భాను వాసరే', 'మండల దీక్ష']) {
        expect(t, contains(s));
      }
      final en = const SankalpamGenerator().generate(
          SankalpamInput(day: day, devoteeName: '', deityName: repo.deities['ayyappa']!.name, purpose: v.sankalpaPurpose), 'en').full;
      expect(en, contains('Ekadashi'));
      expect(en, contains('I, your devotee'));
    });
  });

  group('pooja session', () {
    test('hands-on waits for every action, then closes', () async {
      final bridge = SanctumBridge();
      final d = repo.deities['ayyappa']!;
      final s = PoojaSession(deity: d, vidhanam: d.pooja('nitya5')!, mode: PoojaMode.handsOn, bridge: bridge, lang: 'te', timeScale: 0.001);
      await s.start();
      expect(NotificationGate.allowNotifications, isFalse);
      expect(s.step.upachara, 'sankalpam');
      bridge.emit(const SanctumEvent(SanctumEventType.actionDone, upachara: 'sankalpam'));
      expect(s.step.upachara, 'bell');
      bridge.emit(const SanctumEvent(SanctumEventType.actionDone, upachara: 'bell'));
      expect(s.step.upachara, 'bell', reason: 'bell needs 3 rings');
      bridge.emit(const SanctumEvent(SanctumEventType.actionDone, upachara: 'deepam'));
      expect(s.actionsDone, 1, reason: 'events for other steps are ignored');
      bridge.emit(const SanctumEvent(SanctumEventType.actionDone, upachara: 'bell'));
      bridge.emit(const SanctumEvent(SanctumEventType.actionDone, upachara: 'bell'));
      expect(s.step.upachara, 'deepam');
      for (final u in ['deepam']) {
        bridge.emit(SanctumEvent(SanctumEventType.actionDone, upachara: u));
      }
      for (var i = 0; i < 3; i++) {
        bridge.emit(const SanctumEvent(SanctumEventType.actionDone, upachara: 'pushpam'));
      }
      bridge.emit(const SanctumEvent(SanctumEventType.actionDone, upachara: 'naivedyam'));
      for (var i = 0; i < 3; i++) {
        bridge.emit(const SanctumEvent(SanctumEventType.actionDone, upachara: 'aarti'));
      }
      bridge.emit(const SanctumEvent(SanctumEventType.actionDone, upachara: 'namaskaram'));
      expect(s.status, PoojaStatus.closing);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(s.status, PoojaStatus.completed);
      expect(NotificationGate.allowNotifications, isTrue);
      s.dispose();
    });

    test('watch mode auto-performs the full Shodashopachara', () async {
      final bridge = SanctumBridge();
      final d = repo.deities['ayyappa']!;
      final s = PoojaSession(deity: d, vidhanam: d.pooja('shodasha')!, mode: PoojaMode.watch, bridge: bridge, lang: 'te', timeScale: 0.0005);
      await s.start();
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (s.status != PoojaStatus.completed && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      expect(s.status, PoojaStatus.completed);
      final autos = bridge.sentLog.where((m) => m.contains('"autoPerform"')).length;
      expect(autos, d.pooja('shodasha')!.steps.length);
      s.dispose();
    });
  });

  group('deeksha tracker', () {
    test('day count, streak and persistence', () {
      final r = DeekshaRecord(vratamId: 'ayyappa_mandala', startDate: DateTime.utc(2026, 11, 16), totalDays: 41);
      expect(r.dayNumber(DateTime.utc(2026, 11, 27)), 12);
      expect(r.endDate, DateTime.utc(2026, 12, 26));
      const req = ['m:wake', 'e:deepam'];
      for (final d in [25, 26, 27]) {
        for (final id in req) {
          r.toggle(DateTime.utc(2026, 11, d), id);
        }
      }
      expect(r.streak(DateTime.utc(2026, 11, 27), req), 3);
      r.toggle(DateTime.utc(2026, 11, 27), 'e:deepam');
      expect(r.streak(DateTime.utc(2026, 11, 27), req), 2);
      final back = DeekshaRecord.decode(r.encode());
      expect(back.streak(DateTime.utc(2026, 11, 27), req), 2);
      expect(back.totalDays, 41);
    });
  });
}
