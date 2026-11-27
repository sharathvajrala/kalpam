import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/core/profile/family_profile.dart';
import 'package:kalpam/core/rituals/daily_rituals.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PackRepository repo;
  setUpAll(() async => repo = await PackRepository.load((p) => File(p).readAsString()));

  Future<AppState> state(String isoNow, [Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues({'onboarded': true, 'lang': 'en', 'city': 'hyderabad', ...prefs});
    var now = DateTime.parse(isoNow);
    final s = AppState(repo: repo, prefs: await SharedPreferences.getInstance(), clock: () => now);
    return s;
  }

  test('founder weekday map drives Day God mode', () async {
    const expected = {23: 'shiva', 24: 'hanuman', 25: 'ayyappa', 26: 'sai_baba', 27: 'lakshmi', 28: 'venkateswara', 29: 'surya'};
    for (final e in expected.entries) {
      final s = await state('2026-11-${e.key}T07:00:00+05:30', {'deity': 'day'});
      expect(s.dayGodMode, isTrue);
      expect(s.deity.id, e.value, reason: 'Nov ${e.key}');
    }
  });

  test('the Sankalpam names the day\'s god and that god\'s purpose', () async {
    final s = await state('2026-11-26T07:00:00+05:30', {'deity': 'day'}); // Thursday
    final text = s.sankalpam(deity: s.deity, vratam: null).full;
    expect(text, contains('Shirdi Sai Baba'));
    expect(text, contains('shraddha and saburi'));
    final chosen = await state('2026-11-26T07:00:00+05:30', {'deity': 'hanuman'});
    expect(chosen.sankalpam(deity: chosen.deity, vratam: null).full, contains('freedom from fear'));
  });

  test('archana length always comes from the pack', () {
    final planner = DailyRitualPlanner(repo);
    for (final d in repo.deities.values) {
      final names = repo.stotras[d.rituals.archana];
      expect(names, isNotNull, reason: '${d.id} has archana names');
      expect(planner.archanaNames(d, ArchanaForm.full).length, names!.lines.length);
      expect(planner.archanaNames(d, ArchanaForm.short).length,
          d.rituals.shortCount < names.lines.length ? d.rituals.shortCount : names.lines.length);
    }
    expect(planner.archanaNames(repo.deities['surya']!, ArchanaForm.short).length, 12);
  });

  test('morning and evening plans, Sunday Surya arghyam', () {
    final planner = DailyRitualPlanner(repo);
    final m = planner.plan(repo.deities['venkateswara']!, RitualSlot.morning);
    expect(m.steps.map((s) => s.kind), [RitualStepKind.sankalpam, RitualStepKind.suprabhatam, RitualStepKind.deepam, RitualStepKind.archana, RitualStepKind.aarti]);
    final sun = planner.plan(repo.deities['surya']!, RitualSlot.morning);
    expect(sun.steps.any((s) => s.kind == RitualStepKind.chant && s.stotra!.id == 'aditya_hridayam'), isTrue);
    expect(sun.steps.any((s) => s.kind == RitualStepKind.offering && s.offering == 'arghyam'), isTrue);
    final e = planner.plan(repo.deities['shiva']!, RitualSlot.evening);
    expect(e.steps.map((s) => s.kind), [RitualStepKind.deepam, RitualStepKind.aarti, RitualStepKind.chant, RitualStepKind.closing]);
    expect(e.steps[2].stotra!.id, 'lingashtakam');
  });

  test('Ayyappa ritual as a sanctum pooja: archana, and Harivarasanam only once at the closing', () {
    final planner = DailyRitualPlanner(repo);
    final d = repo.deities['ayyappa']!;
    final morning = planner.toVidhanam(planner.plan(d, RitualSlot.morning, form: ArchanaForm.short));
    expect(morning.steps.first.upachara, 'sankalpam');
    expect(morning.steps.singleWhere((s) => s.upachara == 'archana').target, planner.archanaNames(d, ArchanaForm.short).length);
    expect(morning.steps.last.upachara, 'closing');
    final evening = planner.toVidhanam(planner.plan(d, RitualSlot.evening));
    expect(evening.steps.where((s) => s.upachara == 'chant'), isEmpty);
    expect(evening.steps.map((s) => s.upachara), containsAllInOrder(['deepam', 'aarti', 'namaskaram', 'closing']));
  });

  test('full or short is chosen per day and remembered', () async {
    final s = await state('2026-11-27T07:00:00+05:30');
    expect(s.archanaFormFor(s.today), ArchanaForm.full);
    await s.setArchanaForm(ArchanaForm.short);
    expect(s.ritualPlan(RitualSlot.morning).form, ArchanaForm.short);
    expect(s.archanaFormFor(s.today.add(const Duration(days: 1))), ArchanaForm.short, reason: 'next day defaults to the last choice');
  });

  test('done-state and streak', () async {
    final s = await state('2026-11-27T07:00:00+05:30', {
      'ritual:2026-11-25': ['morning'], 'ritual:2026-11-26': ['morning', 'evening'],
    });
    expect(s.ritualDone(RitualSlot.morning), isFalse);
    expect(s.ritualStreak(RitualSlot.morning), 2, reason: 'today still ahead');
    await s.setRitualDone(RitualSlot.morning, true);
    expect(s.ritualStreak(RitualSlot.morning), 3);
    expect(s.ritualStreak(RitualSlot.evening), 1);
  });

  test('evening reminder anchors to my time or to local sunset', () async {
    final s = await state('2026-11-27T07:00:00+05:30');
    await s.setReminders(evening: const ReminderTime(18, 30));
    expect(s.ritualReminderAt(RitualSlot.evening), DateTime.utc(2026, 11, 27, 13, 0));
    await s.setEveningAnchor(EveningAnchor.sunset);
    expect(s.ritualReminderAt(RitualSlot.evening), s.panchang.sunset);
  });
}
