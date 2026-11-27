import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/app/notifications/notification_planner.dart';
import 'package:kalpam/app/notifications/notification_scheduler.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/core/profile/family_profile.dart';
import 'package:kalpam/core/rituals/daily_rituals.dart';
import 'package:kalpam/core/tracker/deeksha_tracker.dart';
import 'package:kalpam/pooja_engine/pooja_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PackRepository repo;
  setUpAll(() async => repo = await PackRepository.load((p) => File(p).readAsString()));

  late DateTime now;
  Future<AppState> state(String isoNow, [Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'lang': 'en',
      'city': 'hyderabad',
      'deity': 'ayyappa',
      'remindMorning': '06:30',
      'remindEvening': '18:30',
      ...prefs,
    });
    now = DateTime.parse(isoNow);
    return AppState(repo: repo, prefs: await SharedPreferences.getInstance(), clock: () => now);
  }

  DateTime civilOf(AppState s, DateTime utc) => DeekshaRecord.civil(s.city.local(utc));
  List<PlannedNotification> on(AppState s, List<PlannedNotification> plan, DateTime day) =>
      plan.where((n) => civilOf(s, n.at) == day).toList();
  String hhmm(AppState s, DateTime utc) => ReminderTime(s.city.local(utc).hour, s.city.local(utc).minute).hhmm;

  test('daily set: Subhodayam digest at sunrise, morning and evening rituals', () async {
    final s = await state('2026-11-27T04:00:00+05:30');
    final plan = NotificationPlanner(s).plan();
    final today = on(s, plan, s.today);
    final kinds = today.map((n) => n.kind).toList();
    expect(kinds, containsAll([NotifKind.subhodayam, NotifKind.morningRitual, NotifKind.eveningRitual]));

    final sub = today.firstWhere((n) => n.kind == NotifKind.subhodayam);
    final p = s.panchang;
    expect(sub.at, p.sunrise);
    expect(sub.title, 'Subhodayam · Swamy Ayyappa');
    expect(sub.body, contains('${p.tithi.name.en} · ${p.nakshatra.name.en}'));
    expect(sub.body, contains('Sunrise 6:27 AM · Sunset 5:39 PM'));
    expect(sub.payload, 'today');

    expect(hhmm(s, today.firstWhere((n) => n.kind == NotifKind.morningRitual).at), '06:30');
    final eve = today.firstWhere((n) => n.kind == NotifKind.eveningRitual);
    expect(hhmm(s, eve.at), '18:30');
    expect(eve.title, 'Sandhya time');
    expect(eve.body, contains('Sunset 5:39 PM'));

    // A week ahead, ids unique, nothing in the past, sorted.
    expect(civilOf(s, plan.last.at), s.today.add(const Duration(days: NotificationPlanner.windowDays - 1)));
    expect(plan.map((n) => n.id).toSet().length, plan.length);
    expect(plan.every((n) => n.at.isAfter(now.toUtc())), isTrue);
    for (var i = 1; i < plan.length; i++) {
      expect(plan[i].at.isBefore(plan[i - 1].at), isFalse);
    }
  });

  test('evening push follows the sunset anchor; Day God mode names that day\'s god', () async {
    final s = await state('2026-11-27T04:00:00+05:30', {'deity': 'day', 'eveningAnchor': 'sunset'});
    final plan = NotificationPlanner(s).plan();
    final eve = on(s, plan, s.today).firstWhere((n) => n.kind == NotifKind.eveningRitual);
    expect(eve.at, s.panchang.sunset);
    // Fri 27 Nov: Lakshmi; Sat 28 Nov: Venkateswara.
    expect(on(s, plan, s.today).first.title, contains(repo.deities['lakshmi']!.name.en));
    final sat = on(s, plan, s.today.add(const Duration(days: 1)));
    expect(sat.firstWhere((n) => n.kind == NotifKind.subhodayam).title, contains(repo.deities['venkateswara']!.name.en));
  });

  test('a done ritual is never nagged; past reminders are not scheduled', () async {
    final s = await state('2026-11-27T04:00:00+05:30');
    await s.setRitualDone(RitualSlot.morning, true);
    var plan = NotificationPlanner(s).plan();
    expect(on(s, plan, s.today).any((n) => n.kind == NotifKind.morningRitual), isFalse);
    expect(on(s, plan, s.today.add(const Duration(days: 1))).any((n) => n.kind == NotifKind.morningRitual), isTrue);
    await s.setRitualDone(RitualSlot.evening, true);
    plan = NotificationPlanner(s).plan();
    expect(on(s, plan, s.today).any((n) => n.kind == NotifKind.eveningRitual), isFalse);

    now = DateTime.parse('2026-11-27T12:00:00+05:30');
    final later = await state('2026-11-27T12:00:00+05:30');
    final today = on(later, NotificationPlanner(later).plan(), later.today);
    expect(today.map((n) => n.kind), isNot(contains(NotifKind.subhodayam)));
    expect(today.map((n) => n.kind), contains(NotifKind.eveningRitual));
  });

  test('per-type toggles, Subhodayam offset and quiet hours', () async {
    final s = await state('2026-11-27T04:00:00+05:30');
    await s.setNotificationPrefs(s.notificationPrefs.toggled(NotifType.morningRitual, false).copyWith(sunriseOffsetMin: 30));
    var plan = NotificationPlanner(s).plan();
    expect(plan.any((n) => n.kind == NotifKind.morningRitual), isFalse);
    expect(on(s, plan, s.today).firstWhere((n) => n.kind == NotifKind.subhodayam).at, s.panchang.sunrise.add(const Duration(minutes: 30)));

    // Quiet until 7:30 AM: the 6:57 Subhodayam waits for the window to end.
    await s.setNotificationPrefs(s.notificationPrefs.copyWith(quietTo: const ReminderTime(7, 30)));
    plan = NotificationPlanner(s).plan();
    expect(hhmm(s, on(s, plan, s.today).firstWhere((n) => n.kind == NotifKind.subhodayam).at), '07:30');

    // An evening reminder inside quiet hours is dropped, never moved to the next day.
    await s.setReminders(evening: const ReminderTime(22, 30));
    plan = NotificationPlanner(s).plan();
    expect(plan.any((n) => n.kind == NotifKind.eveningRitual), isFalse);

    for (final t in NotifType.values) {
      await s.setNotificationPrefs(s.notificationPrefs.toggled(t, false));
    }
    expect(NotificationPlanner(s).plan(), isEmpty);
  });

  test('festivals: at most one extra per day, T-1 evening, festival morning, flagship peak', () async {
    // Walk Dec 2026 - Jan 2027 a week at a time.
    for (var d = DateTime.utc(2026, 12, 1); d.isBefore(DateTime.utc(2027, 1, 31)); d = d.add(const Duration(days: 7))) {
      final s = await state('${DeekshaRecord.iso(d)}T00:30:00+05:30');
      final plan = NotificationPlanner(s).plan();
      for (var i = 0; i < NotificationPlanner.windowDays; i++) {
        final day = s.today.add(Duration(days: i));
        expect(on(s, plan, day).where((n) => n.kind.isExtra).length, lessThanOrEqualTo(NotificationPlanner.maxExtrasPerDay),
            reason: DeekshaRecord.iso(day));
      }
    }

    // Mandala Pooja, 27 Dec: tomorrow's notice on the 26th evening, and the day itself.
    final s = await state('2026-12-26T04:00:00+05:30');
    final plan = NotificationPlanner(s).plan();
    final eve = on(s, plan, s.today).where((n) => n.kind == NotifKind.festivalEve).single;
    expect(eve.title, 'Tomorrow: Mandala Pooja');
    expect(eve.payload, 'samagri:ayyappa_mandala');
    expect(s.city.local(eve.at).hour, greaterThanOrEqualTo(19));
    final day = on(s, plan, DateTime.utc(2026, 12, 27));
    expect(day.where((n) => n.kind == NotifKind.festivalMorning).single.title, 'Today: Mandala Pooja');
    expect(day.firstWhere((n) => n.kind == NotifKind.subhodayam).body, contains('Today: Mandala Pooja'));

    // Makara Jyothi, 14 Jan 2027: the peak invitation names the live aarti time.
    final m = await state('2027-01-13T04:00:00+05:30');
    final peak = NotificationPlanner(m).plan().where((n) => n.kind == NotifKind.flagshipPeak).single;
    expect(civilOf(m, peak.at), DateTime.utc(2027, 1, 14));
    expect(peak.title, 'Today: Makara Jyothi');
    expect(peak.body, contains('live aarti at 6:30 PM'));
  });

  test('flagship lifecycle: T-30 invitation and the closing Udyapanam', () async {
    final shivratri = repo.seasons.firstWhere((x) => x.id == 'shiva_shivratri_2027');
    final inviteDay = shivratri.start.subtract(const Duration(days: 30));
    final s = await state('${DeekshaRecord.iso(inviteDay)}T00:30:00+05:30');
    final invite = on(s, NotificationPlanner(s).plan(), inviteDay).where((n) => n.kind.isExtra).toList();
    expect(invite.map((n) => n.kind), contains(NotifKind.flagshipInvite));
    expect(invite.first.title, contains('begins in 30 days'));

    final mandala = repo.seasons.firstWhere((x) => x.id == 'ayyappa_mandala_2026');
    final c = await state('${DeekshaRecord.iso(mandala.end)}T00:30:00+05:30');
    final closing = on(c, NotificationPlanner(c).plan(), mandala.end).where((n) => n.kind.isExtra).single;
    expect(closing.kind, NotifKind.flagshipClosing);
    expect(closing.payload, 'vratam:ayyappa_mandala:udyapanam');
  });

  group('mala / vratam loop', () {
    Future<AppState> joined(String isoNow, DateTime start, int days, {String? reminder}) async {
      final s = await state(isoNow);
      await s.startDeeksha('ayyappa_mandala', start, days, reminder: ReminderTime.parse(reminder));
      return s;
    }

    void keep(AppState s, DateTime day) {
      final r = s.deekshas['ayyappa_mandala']!;
      for (final id in s.requiredChecks(s.repo.vratams['ayyappa_mandala']!)) {
        if (!r.checksOn(day).contains(id)) r.toggle(day, id);
      }
    }

    test('daily check-in "Day N of M" at the chosen time, nudge only while incomplete', () async {
      final s = await joined('2026-11-27T04:00:00+05:30', DateTime.utc(2026, 11, 26), 41, reminder: '05:15');
      keep(s, DateTime.utc(2026, 11, 26));
      final today = on(s, NotificationPlanner(s).plan(), s.today);
      final checkIn = today.firstWhere((n) => n.kind == NotifKind.vratamCheckIn);
      expect(checkIn.title, 'Ayyappa Mandala Deeksha · Day 2 of 41');
      expect(checkIn.body, startsWith('Today: '));
      expect(hhmm(s, checkIn.at), '05:15');
      expect(today.firstWhere((n) => n.kind == NotifKind.vratamNudge).body, contains('left on today'));

      keep(s, s.today);
      final after = on(s, NotificationPlanner(s).plan(), s.today);
      expect(after.any((n) => n.kind == NotifKind.vratamNudge), isFalse);
    });

    test('check-in at the morning reminder time carries it: one push, not two', () async {
      final s = await joined('2026-11-27T04:00:00+05:30', DateTime.utc(2026, 11, 27), 41, reminder: '06:30');
      final morning = on(s, NotificationPlanner(s).plan(), s.today).where((n) => hhmm(s, n.at) == '06:30').toList();
      expect(morning.length, 1);
      expect(morning.single.kind, NotifKind.vratamCheckIn);
      expect(morning.single.body, contains('morning archana'));
    });

    test('halfway, final day and a gentle missed-day resume', () async {
      final half = await joined('2026-12-16T04:00:00+05:30', DateTime.utc(2026, 11, 26), 41);
      for (var d = DateTime.utc(2026, 11, 26); d.isBefore(half.today); d = d.add(const Duration(days: 1))) {
        keep(half, d);
      }
      final h = on(half, NotificationPlanner(half).plan(), half.today).firstWhere((n) => n.kind == NotifKind.vratamCheckIn);
      expect(h.title, 'Halfway · Day 21 of 41');

      final fin = await joined('2027-01-05T04:00:00+05:30', DateTime.utc(2026, 11, 26), 41);
      final f = on(fin, NotificationPlanner(fin).plan(), fin.today).firstWhere((n) => n.kind == NotifKind.vratamCheckIn);
      expect(f.title, 'Final day · Day 41 of 41');
      expect(f.payload, 'vratam:ayyappa_mandala:udyapanam');
      // Nothing after the last day.
      expect(NotificationPlanner(fin).plan().where((n) => n.kind == NotifKind.vratamCheckIn).length, 1);

      final missed = await joined('2026-11-28T04:00:00+05:30', DateTime.utc(2026, 11, 26), 41);
      keep(missed, DateTime.utc(2026, 11, 26)); // 27th not kept
      final r = on(missed, NotificationPlanner(missed).plan(), missed.today).firstWhere((n) => n.kind == NotifKind.vratamCheckIn);
      expect(r.title, 'Welcome back · Day 3 of 41');
      for (final word in ['missed', 'broke', 'streak', 'failed']) {
        expect(r.body.toLowerCase(), isNot(contains(word)));
      }
    });

    test('a joined mala asks 1-90 days; a completed one stops', () async {
      final s = await joined('2026-11-27T04:00:00+05:30', DateTime.utc(2026, 11, 27), 200);
      expect(s.deekshas['ayyappa_mandala']!.totalDays, 90);
      await s.completeDeeksha('ayyappa_mandala');
      expect(NotificationPlanner(s).plan().any((n) => n.kind.type == NotifType.vratam), isFalse);
    });
  });

  test('Telugu notifications', () async {
    final s = await state('2026-11-27T04:00:00+05:30', {'lang': 'te'});
    final sub = NotificationPlanner(s).plan().first;
    expect(sub.title, startsWith('శుభోదయం'));
    expect(sub.body, contains('సూర్యోదయం'));
  });

  test('scheduler: re-plans on change, pauses during a pooja, skips unchanged plans', () async {
    final s = await state('2026-11-27T04:00:00+05:30', {'notifPrefs': '{"permissionAsked":true}'});
    final port = MemoryNotificationPort();
    final scheduler = NotificationScheduler(s, port, debounce: Duration.zero);
    await scheduler.start();
    expect(port.scheduled, isNotEmpty);
    expect(port.replaceCount, 1);
    await scheduler.refresh();
    expect(port.replaceCount, 1, reason: 'unchanged plan is not re-sent');

    await s.setRitualDone(RitualSlot.morning, true);
    await scheduler.refresh();
    expect(port.replaceCount, 2);
    expect(port.scheduled.where((n) => n.kind == NotifKind.morningRitual && civilOf(s, n.at) == s.today), isEmpty);

    NotificationGate.poojaActive.value = true;
    await scheduler.refresh();
    expect(port.scheduled, isEmpty);
    expect(scheduler.upcoming.value, isEmpty);
    NotificationGate.poojaActive.value = false;
    await scheduler.refresh();
    expect(port.scheduled, isNotEmpty);
    scheduler.dispose();
  });
}
