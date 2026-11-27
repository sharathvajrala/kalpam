/// Local notification planner (NOTIFICATIONS spec, 27 Nov 2026).
///
/// A pure function of the app's state and the clock: it lists every local
/// notification for the next [NotificationPlanner.windowDays] days, from the
/// Panchangam engine, the flagship calendar, the recurring vratam data and
/// the user's mala/vratam records. The scheduler cancels and re-schedules
/// this list whenever anything changes (app open, city or timezone change,
/// a ritual or checklist marked done, Settings), so a completed ritual is
/// never nagged: it simply drops out of the next plan.
///
/// Rules:
/// * Daily set: Subhodayam digest at sunrise (+ the user's offset), morning
///   ritual reminder, evening Sandhya push. Morning / evening are skipped
///   once that day's ritual is done.
/// * Mala / vratam loop (the user's own commitment, so part of the daily
///   set): morning "Day N of M" check-in at the chosen time (milestone,
///   final-day or gentle resume wording on those days) and an evening nudge
///   only while the day's checklist is incomplete.
/// * Festival / flagship extras: at most [maxExtrasPerDay] per day, highest
///   priority first (peak day, closing Udyapanam, T-30 join invitation,
///   festival morning, T-1 evening).
/// * Quiet hours: a notification inside them moves to the end of the quiet
///   window on the same night; if that would be the next day it is dropped.
/// * Nothing in the past is scheduled. The NotificationGate pause during an
///   active pooja is handled by the scheduler.
library;

import 'dart:ui' show Locale;

import '../../core/content/localized.dart';
import '../../core/content/models.dart';
import '../../core/flagship/flagship_engine.dart';
import '../../core/profile/family_profile.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/tracker/deeksha_tracker.dart';
import '../../l10n/gen/app_localizations.dart';
import '../app_state.dart';

enum NotifKind {
  subhodayam,
  morningRitual,
  eveningRitual,
  vratamCheckIn,
  vratamNudge,
  festivalMorning,
  festivalEve,
  flagshipPeak,
  flagshipInvite,
  flagshipClosing,
}

extension NotifKindType on NotifKind {
  /// The Settings toggle that controls this kind.
  NotifType get type => switch (this) {
        NotifKind.subhodayam => NotifType.subhodayam,
        NotifKind.morningRitual => NotifType.morningRitual,
        NotifKind.eveningRitual => NotifType.eveningRitual,
        NotifKind.vratamCheckIn || NotifKind.vratamNudge => NotifType.vratam,
        _ => NotifType.festivals,
      };

  bool get isExtra => type == NotifType.festivals;
}

class PlannedNotification {
  PlannedNotification({required this.id, required this.kind, required this.at, required this.title, required this.body, required this.payload});

  /// Stable per (day, kind): the same reminder keeps its id across re-plans.
  final int id;
  final NotifKind kind;
  final DateTime at; // UTC
  final String title, body;

  /// Where a tap leads: "today", "ritual:morning", "ritual:evening",
  /// `vratam:ID`, `samagri:VRATAM`, `season:ID`.
  final String payload;

  PlannedNotification _at(DateTime t) => PlannedNotification(id: id, kind: kind, at: t, title: title, body: body, payload: payload);

  /// Identity for "did the schedule change?" checks.
  String get signature => '$id|${at.toIso8601String()}|$title|$body|$payload';

  @override
  String toString() => '${at.toIso8601String()} ${kind.name}: $title — $body';
}

class NotificationPlanner {
  NotificationPlanner(this.app);
  final AppState app;

  /// A week ahead (well under iOS's 64 pending limit), so reminders keep
  /// coming even if the app is not opened for a few days.
  static const windowDays = 7;
  static const maxExtrasPerDay = 1;

  /// Festival morning invitation: this long after the Subhodayam digest.
  static const festivalMorningDelay = Duration(minutes: 60);

  /// Evening mala nudge: this long after the evening ritual time.
  static const nudgeDelay = Duration(minutes: 90);

  /// Flagship join invitation, days before the season starts.
  static const inviteDaysBefore = 30;

  AppLocalizations get _l => lookupAppLocalizations(Locale(app.lang));

  List<PlannedNotification> plan() {
    if (!app.onboarded) return const [];
    final now = app.now.toUtc();
    final out = <PlannedNotification>[];
    for (var i = 0; i < windowDays; i++) {
      final day = app.today.add(Duration(days: i));
      for (final n in _day(day, dayIndex: i)) {
        final t = _quiet(n.at, day);
        if (t != null && t.isAfter(now)) out.add(n._at(t));
      }
    }
    out.sort((a, b) => a.at.compareTo(b.at));
    return out;
  }

  // ------------------------------------------------------------ one day
  List<PlannedNotification> _day(DateTime day, {required int dayIndex}) {
    final prefs = app.notificationPrefs;
    final l = _l;
    final lang = app.lang;
    final p = app.panchangFor(day);
    final god = app.deityOn(day);
    final godName = god.name.of(lang);
    final out = <PlannedNotification>[];
    int id(NotifKind k) => _id(day, k);

    // 1. Subhodayam digest.
    final subhodayamAt = p.sunrise.add(Duration(minutes: prefs.sunriseOffsetMin));
    if (prefs.enabled(NotifType.subhodayam)) {
      final festival = _festivalsOn(day).firstOrNull;
      out.add(PlannedNotification(
        id: id(NotifKind.subhodayam),
        kind: NotifKind.subhodayam,
        at: subhodayamAt,
        title: l.nSubhodayamTitle(godName),
        body: [
          '${p.tithi.name.of(lang)} · ${p.nakshatra.name.of(lang)}',
          l.nSunLine(_time(p.sunset), _time(p.sunrise)),
          if (festival != null) l.nTodayIs(festival.name.of(lang)),
        ].join('\n'),
        payload: 'today',
      ));
    }

    // 2. Morning ritual reminder (skipped once done).
    final morningAt = app.ritualReminderAt(RitualSlot.morning, day);
    if (prefs.enabled(NotifType.morningRitual) && morningAt != null && !app.ritualDone(RitualSlot.morning, day)) {
      out.add(PlannedNotification(
        id: id(NotifKind.morningRitual),
        kind: NotifKind.morningRitual,
        at: morningAt,
        title: l.morningRitual,
        body: l.nMorningBody(godName),
        payload: 'ritual:morning',
      ));
    }

    // 3. Evening Sandhya push (skipped once done).
    final eveningAt = app.ritualReminderAt(RitualSlot.evening, day) ?? p.sunset;
    if (prefs.enabled(NotifType.eveningRitual) && !app.ritualDone(RitualSlot.evening, day)) {
      out.add(PlannedNotification(
        id: id(NotifKind.eveningRitual),
        kind: NotifKind.eveningRitual,
        at: eveningAt,
        title: l.nEveningTitle,
        body: l.nEveningBody(godName, _time(p.sunset)),
        payload: 'ritual:evening',
      ));
    }

    // 4. Mala / vratam loop.
    if (prefs.enabled(NotifType.vratam)) {
      for (final r in app.activeDeekshasOn(day)) {
        out.addAll(_vratam(r, day, dayIndex: dayIndex, eveningAt: eveningAt));
      }
    }

    // A check-in at the same minute as the morning reminder carries it,
    // so the devotee gets one gentle push instead of two.
    final morning = out.where((n) => n.kind == NotifKind.morningRitual).firstOrNull;
    if (morning != null) {
      final i = out.indexWhere((n) => n.kind == NotifKind.vratamCheckIn && n.at == morning.at);
      if (i >= 0) {
        final c = out[i];
        out[i] = PlannedNotification(id: c.id, kind: c.kind, at: c.at, title: c.title, body: '${c.body}\n${morning.body}', payload: c.payload);
        out.remove(morning);
      }
    }

    // 5. One festival / flagship extra.
    if (prefs.enabled(NotifType.festivals)) {
      final extras = _extras(day, subhodayamAt: subhodayamAt, sunset: p.sunset)..sort((a, b) => a.$1.compareTo(b.$1));
      out.addAll(extras.take(maxExtrasPerDay).map((e) => e.$2));
    }
    return out;
  }

  List<PlannedNotification> _vratam(DeekshaRecord r, DateTime day, {required int dayIndex, required DateTime eveningAt}) {
    final l = _l;
    final lang = app.lang;
    final v = app.repo.vratams[r.vratamId]!;
    final n = r.dayNumber(day);
    final total = r.totalDays;
    final name = v.name.of(lang);
    final required = app.requiredChecks(v);
    final reminder = ReminderTime.parse(r.reminder) ?? app.morningReminder ?? const ReminderTime(6, 0);
    final checkInAt = app.city.utcFromLocal(day.year, day.month, day.day, reminder.hour, reminder.minute);
    final slot = _slotOf(r.vratamId);

    // A missed yesterday is only known for today; later days are planned
    // as ordinary check-ins and corrected on the next re-plan.
    final yesterday = day.subtract(const Duration(days: 1));
    final missedYesterday = dayIndex == 0 && n > 1 && !r.dayKept(yesterday, required);

    final String title, body;
    if (n == total) {
      title = l.nFinalTitle(n, total);
      body = l.nFinalBody(name);
    } else if (total >= 3 && n == (total + 1) ~/ 2) {
      title = l.nHalfwayTitle(n, total);
      body = _summary(v);
    } else if (missedYesterday) {
      title = l.nResumeTitle(n, total);
      body = l.nResumeBody;
    } else {
      title = '$name · ${l.dayOf(n, total)}';
      body = _summary(v);
    }
    final out = [
      PlannedNotification(
        id: _id(day, NotifKind.vratamCheckIn, slot),
        kind: NotifKind.vratamCheckIn,
        at: checkInAt,
        title: title,
        body: body,
        payload: n == total ? 'vratam:${r.vratamId}:udyapanam' : 'vratam:${r.vratamId}',
      ),
    ];
    final left = required.where((id) => !r.checksOn(day).contains(id)).length;
    if (left > 0) {
      out.add(PlannedNotification(
        id: _id(day, NotifKind.vratamNudge, slot),
        kind: NotifKind.vratamNudge,
        at: eveningAt.add(nudgeDelay),
        title: '${l.nNudgeTitle} · $name',
        body: l.nNudgeBody(left),
        payload: 'vratam:${r.vratamId}',
      ));
    }
    return out;
  }

  /// "Today: Wake before sunrise, Cold-water bath, Deepam +4".
  String _summary(VratamPack v) {
    final items = [...v.morningChecklist, ...v.eveningChecklist].where((c) => !c.optional).toList();
    final shown = items.take(3).map((c) => c.text.of(app.lang)).join(', ');
    return _l.nChecklistSummary(items.length > 3 ? '$shown +${items.length - 3}' : shown);
  }

  /// Festival / flagship candidates as (priority, notification); lower wins.
  List<(int, PlannedNotification)> _extras(DateTime day, {required DateTime subhodayamAt, required DateTime sunset}) {
    final l = _l;
    final lang = app.lang;
    final out = <(int, PlannedNotification)>[];
    final eveAt = _laterOf(sunset.add(const Duration(minutes: 45)), app.city.utcFromLocal(day.year, day.month, day.day, 19, 0));

    for (final s in app.repo.seasons.where((s) => !s.quiet)) {
      final god = (app.repo.deities[s.deityId]?.name ?? s.title).of(lang);
      // Peak day: special pooja + the live aarti moment (the synchronized
      // moment itself comes by remote push; this is the local invitation).
      if (FlagshipEngine.peakDate(s) == day) {
        out.add((
          0,
          PlannedNotification(
            id: _id(day, NotifKind.flagshipPeak),
            kind: NotifKind.flagshipPeak,
            at: subhodayamAt.add(festivalMorningDelay),
            title: l.nTodayIs(s.peakTitle.of(lang)),
            body: s.liveAarti ? l.nPeakBody(_time(s.peakAt)) : l.nFestivalBody(god),
            payload: 'season:${s.id}',
          ),
        ));
      }
      if (s.end == day && s.priority == 'hero') {
        out.add((
          1,
          PlannedNotification(
            id: _id(day, NotifKind.flagshipClosing),
            kind: NotifKind.flagshipClosing,
            at: subhodayamAt.add(festivalMorningDelay),
            title: l.nClosingTitle(s.title.of(lang)),
            body: l.nClosingBody,
            payload: s.vratamId == null ? 'season:${s.id}' : 'vratam:${s.vratamId}:udyapanam',
          ),
        ));
      }
      if (s.start.subtract(const Duration(days: inviteDaysBefore)) == day && s.priority == 'hero') {
        out.add((
          2,
          PlannedNotification(
            id: _id(day, NotifKind.flagshipInvite),
            kind: NotifKind.flagshipInvite,
            at: subhodayamAt.add(festivalMorningDelay),
            title: l.nInviteTitle(inviteDaysBefore, s.title.of(lang)),
            body: l.nInviteBody,
            payload: 'season:${s.id}',
          ),
        ));
      }
    }

    final today = _festivalsOn(day, includePeaks: false).firstOrNull;
    if (today != null) {
      out.add((
        3,
        PlannedNotification(
          id: _id(day, NotifKind.festivalMorning),
          kind: NotifKind.festivalMorning,
          at: subhodayamAt.add(festivalMorningDelay),
          title: l.nTodayIs(today.name.of(lang)),
          body: l.nFestivalBody(today.god.of(lang)),
          payload: today.payload,
        ),
      ));
    }
    final tomorrow = _festivalsOn(day.add(const Duration(days: 1))).firstOrNull;
    if (tomorrow != null) {
      out.add((
        4,
        PlannedNotification(
          id: _id(day, NotifKind.festivalEve),
          kind: NotifKind.festivalEve,
          at: eveAt,
          title: l.nTomorrowTitle(tomorrow.name.of(lang)),
          body: l.nTomorrowBody,
          payload: tomorrow.samagriPayload,
        ),
      ));
    }
    return out;
  }

  /// Festivals and special days on [day]: flagship peaks and milestones,
  /// then recurring vratams on the tithi prevailing at sunrise (udaya
  /// tithi), so a tithi spanning two civil days is announced once.
  List<_Festival> _festivalsOn(DateTime day, {bool includePeaks = true}) {
    final out = <_Festival>[];
    for (final s in app.repo.seasons.where((s) => !s.quiet)) {
      final god = app.repo.deities[s.deityId]?.name ?? s.title;
      if (includePeaks && FlagshipEngine.peakDate(s) == day) {
        out.add(_Festival(s.peakTitle, god, 'season:${s.id}', s.vratamId == null ? 'season:${s.id}' : 'samagri:${s.vratamId}'));
      }
      for (final m in s.milestones.where((m) => m.date == day)) {
        out.add(_Festival(m.name, god, 'season:${s.id}', s.vratamId == null ? 'season:${s.id}' : 'samagri:${s.vratamId}'));
      }
    }
    for (final r in app.repo.recurringOn([app.panchangFor(day).tithi.number])) {
      final god = app.repo.deities[r.deityId]?.name ?? r.name;
      out.add(_Festival(r.name, god, 'vratam:${r.id}', 'samagri:${r.id}'));
    }
    return out;
  }

  // ------------------------------------------------------------ helpers
  /// Moves [t] out of quiet hours (to their end, same night) or drops it.
  DateTime? _quiet(DateTime t, DateTime day) {
    final q = app.notificationPrefs;
    final from = q.quietFrom.hour * 60 + q.quietFrom.minute;
    final to = q.quietTo.hour * 60 + q.quietTo.minute;
    if (from == to) return t;
    final local = app.city.local(t);
    final m = local.hour * 60 + local.minute;
    final inQuiet = from < to ? (m >= from && m < to) : (m >= from || m < to);
    if (!inQuiet) return t;
    // After midnight inside an overnight window (or a same-day window):
    // defer to the window's end on the same civil date.
    final sameDayEnd = from < to || m < to;
    if (!sameDayEnd) return null;
    final end = app.city.utcFromLocal(local.year, local.month, local.day, q.quietTo.hour, q.quietTo.minute);
    return DeekshaRecord.civil(app.city.local(end)) == day ? end : null;
  }

  String _time(DateTime utc) {
    final l = app.city.local(utc);
    final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
    return '$h:${l.minute.toString().padLeft(2, '0')} ${l.hour < 12 ? 'AM' : 'PM'}';
  }

  static DateTime _laterOf(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

  int _slotOf(String vratamId) => (app.deekshas.keys.toList()..sort()).indexOf(vratamId).clamp(0, 9);

  /// Stable id: days since 2026-01-01, kind, and a slot for several vratams.
  static int _id(DateTime day, NotifKind k, [int slot = 0]) {
    final d = day.difference(DateTime.utc(2026)).inDays % 100000;
    return d * 1000 + k.index * 10 + slot;
  }
}

class _Festival {
  _Festival(this.name, this.god, this.payload, this.samagriPayload);
  final LocalizedText name, god;
  final String payload, samagriPayload;
}
