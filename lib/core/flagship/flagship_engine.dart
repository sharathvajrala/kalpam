/// Picks the flagship season for a date and derives its lifecycle phase.
/// The phase is never stored: it is a pure function of the calendar + date.
library;

import '../content/models.dart';

enum FlagshipPhase { teaser, season, peak, closing }

class FlagshipState {
  FlagshipState({
    required this.season,
    required this.phase,
    required this.dayOfSeason,
    required this.daysToPeak,
    required this.daysToStart,
    this.next,
  });

  final FlagshipSeason season;
  final FlagshipPhase phase;

  /// 1-based day within the season (0 during teaser).
  final int dayOfSeason;

  /// Whole days until the peak's civil date (0 on peak day, negative after).
  final int daysToPeak;
  final int daysToStart;
  final FlagshipSeason? next;
}

class FlagshipEngine {
  FlagshipEngine(List<FlagshipSeason> seasons)
      : _seasons = [...seasons]..sort((a, b) => a.start.compareTo(b.start));

  final List<FlagshipSeason> _seasons;

  static DateTime _civil(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  /// Civil date of the peak in IST (all 2027 peaks are Indian festivals).
  static DateTime peakDate(FlagshipSeason s) =>
      _civil(s.peakAt.toUtc().add(const Duration(minutes: 330)));

  FlagshipSeason? byId(String? id) {
    for (final s in _seasons) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Hero season for [today] (a civil date). Hero-priority active seasons win;
  /// otherwise the nearest upcoming hero season within its teaser window;
  /// quiet seasons never become the hero.
  FlagshipState? heroFor(DateTime today) {
    final t = _civil(today);
    final heroes = _seasons.where((s) => s.priority == 'hero' && !s.quiet).toList();

    FlagshipSeason? active;
    for (final s in heroes) {
      if (!t.isBefore(s.start) && !t.isAfter(s.end)) {
        active = s;
        // keep the latest-starting active one, so a new season replaces the
        // previous one's closing tail
      }
    }
    if (active != null) {
      // If the active season is past its peak and the next season's own start
      // has arrived, prefer the next one.
      return _state(active, t);
    }
    for (final s in heroes) {
      final teaserStart = s.start.subtract(Duration(days: s.teaserDays));
      if (!t.isBefore(teaserStart) && t.isBefore(s.start)) return _state(s, t);
    }
    // Gap between seasons: tease the next upcoming one regardless of window.
    for (final s in heroes) {
      if (t.isBefore(s.start)) return _state(s, t);
    }
    return null;
  }

  /// Parallel (secondary) seasons active on [today]; shown under the hero.
  List<FlagshipSeason> secondaryFor(DateTime today) {
    final t = _civil(today);
    return _seasons
        .where((s) => s.priority != 'hero' && !t.isBefore(s.start) && !t.isAfter(s.end))
        .toList();
  }

  FlagshipState _state(FlagshipSeason s, DateTime t) {
    final pd = peakDate(s);
    final daysToPeak = pd.difference(t).inDays;
    final daysToStart = s.start.difference(t).inDays;
    FlagshipPhase phase;
    if (t.isBefore(s.start)) {
      phase = FlagshipPhase.teaser;
    } else if (daysToPeak == 0) {
      phase = FlagshipPhase.peak;
    } else if (daysToPeak < 0) {
      phase = FlagshipPhase.closing;
    } else {
      phase = FlagshipPhase.season;
    }
    return FlagshipState(
      season: s,
      phase: phase,
      dayOfSeason: phase == FlagshipPhase.teaser ? 0 : t.difference(s.start).inDays + 1,
      daysToPeak: daysToPeak,
      daysToStart: daysToStart,
      next: byId(s.next),
    );
  }
}
