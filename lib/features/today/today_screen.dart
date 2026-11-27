import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/app.dart';
import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/content/models.dart';
import '../../core/flagship/flagship_engine.dart';
import '../bhajans/bhajan_player_screen.dart';
import '../../app/app_state.dart';
import '../../core/rituals/daily_rituals.dart';
import '../common/deity_avatar.dart';
import '../rituals/ritual_screen.dart';
import '../rituals/rituals_card.dart';
import '../grantham/chant_player_screen.dart';
import '../sannidhanam/pooja_setup_screen.dart';
import '../settings/settings_screen.dart';
import '../vratam/vratam_screen.dart';
import 'city_picker_screen.dart';
import 'panchangam_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final hero = app.hero;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _GreetingHeader(),
          const SizedBox(height: 14),
          if (hero != null) FlagshipHero(state: hero),
          const SizedBox(height: 14),
          const MyGodCard(),
          const SizedBox(height: 14),
          const RitualsCard(),
          const SizedBox(height: 14),
          const _TodayStrip(),
          for (final s in app.secondary) ...[
            const SizedBox(height: 12),
            _SecondarySeasonCard(season: s),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ header

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final p = app.panchang;
    final evening = app.city.local(app.now.toUtc()).hour >= 16;
    final tt = Theme.of(context).textTheme;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Bi((l) => evening ? l.subhaSayantram : l.subhodayam, style: tt.headlineMedium),
          const SizedBox(height: 6),
          Text(
            '${context.t(p.weekdayName)} · ${fmtDate(context, app.today)}',
            style: tt.bodyMedium?.copyWith(color: K.inkSoft),
          ),
          const SizedBox(height: 2),
          Text(
            '${context.t(p.masa)} ${context.t(p.tithi.paksha)} ${context.t(p.tithi.name)} · ${context.t(p.nakshatra.name)}',
            style: tt.bodyMedium?.copyWith(color: K.maroon, fontWeight: FontWeight.w600),
          ),
          Text(
            '${context.t2(p.tithi.name)} · ${context.t2(p.nakshatra.name)}',
            style: tt.bodySmall,
          ),
          const SizedBox(height: 6),
          InkWell(
            key: const ValueKey('city-chip'),
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CityPickerScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: app.hasCity ? K.goldSoft : K.saffron),
                color: K.card,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(app.hasCity ? Icons.place_outlined : Icons.add_location_alt_outlined,
                    size: 16, color: app.hasCity ? K.maroon : K.saffron),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    app.hasCity ? '${context.t(app.city.name)} · ${context.t2(app.city.name)}' : context.l.cityNotSet,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: app.hasCity ? K.maroon : K.saffron),
                  ),
                ),
              ]),
            ),
          ),
          if (app.profiles.length > 1) ...[
            const SizedBox(height: 8),
            // One-tap switch of whose Sankalpam is spoken.
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final p in app.profiles)
                ChoiceChip(
                  key: ValueKey('sankalpam-for-${p.id}'),
                  avatar: p.id == app.activeProfile?.id ? null : const Icon(Icons.person_outline, size: 16, color: K.maroon),
                  label: Text(p.name, style: const TextStyle(fontSize: 12)),
                  selected: p.id == app.activeProfile?.id,
                  onSelected: (_) => app.switchProfile(p.id),
                  tooltip: context.l.sankalpamFor(p.name),
                ),
            ]),
          ],
        ]),
      ),
      IconButton(
        tooltip: context.l.settings,
        icon: const Icon(Icons.settings_outlined, color: K.maroon),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
      ),
    ]);
  }
}

// ------------------------------------------------------------------ hero

class FlagshipHero extends StatelessWidget {
  const FlagshipHero({super.key, required this.state});
  final FlagshipState state;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = state.season;
    final deity = app.repo.deities[s.deityId]!;
    final vratam = s.vratamId == null ? null : app.repo.vratams[s.vratamId];
    final record = vratam == null ? null : app.deekshas[vratam.id];
    final joined = record != null && !record.isFinished(app.today);
    final l = context.l;
    final tt = Theme.of(context).textTheme;
    const onDark = K.ivory;

    int ringDay;
    int ringTotal;
    if (joined) {
      ringDay = record.dayNumber(app.today).clamp(0, record.totalDays);
      ringTotal = record.totalDays;
    } else if (s.malaDays > 0 && state.phase != FlagshipPhase.teaser) {
      ringDay = state.dayOfSeason.clamp(1, s.malaDays);
      ringTotal = s.malaDays;
    } else {
      ringDay = 0;
      ringTotal = 0;
    }

    final status = switch (state.phase) {
      FlagshipPhase.teaser => l.startsIn(state.daysToStart),
      FlagshipPhase.season => l.daysToPeak(state.daysToPeak, context.t(s.peakTitle)),
      FlagshipPhase.peak => l.peakToday(context.t(s.peakTitle)),
      FlagshipPhase.closing => l.seasonClosing,
    };

    void openJoin() {
      if (vratam != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => VratamScreen(vratamId: vratam.id, initialTab: VratamTab.tracker)));
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PoojaSetupScreen(deityId: deity.id)));
      }
    }

    final kathaDay = joined ? record.dayNumber(app.today) : math.max(1, state.dayOfSeason);
    final katha = vratam?.kathaForDay(kathaDay);
    final bhajanId = s.bhajanSet.isEmpty ? null : s.bhajanSet[(kathaDay - 1) % s.bhajanSet.length];
    final bhajan = bhajanId == null ? null : app.repo.bhajans[bhajanId];

    return Container(
      key: const ValueKey('flagship-hero'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [K.maroonDeep, Color(deity.primaryColor), K.maroon],
        ),
        border: Border.all(color: K.goldBright, width: 1.2),
        boxShadow: [BoxShadow(color: K.maroon.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          DeityAvatar(deity: deity, size: 40),
          const SizedBox(width: 10),
          Expanded(child: BiL(deity.greeting, style: tt.titleMedium?.copyWith(color: K.goldBright, fontFamily: K.serif), secondaryColor: K.goldSoft)),
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BiL(s.title, style: tt.headlineSmall?.copyWith(color: onDark), secondaryColor: K.goldSoft),
              const SizedBox(height: 6),
              Text(context.t(s.subtitle), style: tt.bodyMedium?.copyWith(color: K.goldSoft)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: K.goldBright.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: const TextStyle(color: K.goldBright, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ]),
          ),
          if (ringTotal > 0) ...[
            const SizedBox(width: 12),
            DayRing(day: ringDay, total: ringTotal, size: 104),
          ],
        ]),
        if (state.phase != FlagshipPhase.teaser && state.phase != FlagshipPhase.closing) ...[
          const SizedBox(height: 16),
          IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (katha != null)
              Expanded(
                child: _HeroTile(
                  icon: Icons.auto_stories_outlined,
                  label: l.todayKatha,
                  label2: context.l2.todayKatha,
                  value: context.t(katha.title),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VratamScreen(vratamId: vratam!.id, initialTab: VratamTab.katha))),
                ),
              ),
            if (bhajan != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _HeroTile(
                  icon: Icons.music_note_outlined,
                  label: l.todayBhajan,
                  label2: context.l2.todayBhajan,
                  value: context.t(bhajan.title),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BhajanPlayerScreen(bhajanId: bhajan.id, playlistIds: s.bhajanSet))),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Expanded(
              child: _HeroTile(
                icon: Icons.temple_hindu_outlined,
                label: l.seasonPooja,
                  label2: context.l2.seasonPooja,
                value: context.t(deity.name),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PoojaSetupScreen(deityId: deity.id))),
              ),
            ),
          ])),
        ],
        if (state.phase == FlagshipPhase.teaser && vratam != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: K.goldSoft),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VratamScreen(vratamId: vratam.id, initialTab: VratamTab.samagri))),
            icon: const Icon(Icons.checklist),
            label: Text(l.samagriChecklist),
          ),
        ],
        const SizedBox(height: 16),
        if (state.phase == FlagshipPhase.closing && vratam != null && record != null)
          _heroButton(context, l.beginUdyapanam, context.l2.beginUdyapanam, () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => VratamScreen(vratamId: vratam.id, initialTab: VratamTab.udyapanam))))
        else
          _heroButton(context, joined ? l.continueLabel : l.joinSankalpam,
              joined ? context.l2.continueLabel : context.l2.joinSankalpam, openJoin, key: const ValueKey('hero-join')),
        if (state.phase == FlagshipPhase.closing && state.next != null) ...[
          const SizedBox(height: 10),
          Text(l.nextFlagship(context.t(state.next!.title)), style: const TextStyle(color: K.goldSoft, fontWeight: FontWeight.w600)),
        ],
      ]),
    );
  }

  Widget _heroButton(BuildContext context, String label, String label2, VoidCallback onTap, {Key? key}) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          key: key,
          style: FilledButton.styleFrom(backgroundColor: K.goldBright, foregroundColor: K.maroonDeep),
          onPressed: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: BiPair(label, label2,
                align: CrossAxisAlignment.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: K.maroonDeep),
                secondaryColor: K.maroon),
          ),
        ),
      );
}

class _HeroTile extends StatelessWidget {
  const _HeroTile({required this.icon, required this.label, required this.label2, required this.value, required this.onTap});
  final IconData icon;
  final String label, label2, value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14), border: Border.all(color: K.goldBright.withValues(alpha: 0.4))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: K.goldBright, size: 20),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: K.goldSoft, fontSize: 11)),
              Text(label2, style: TextStyle(color: K.goldSoft.withValues(alpha: 0.7), fontSize: 9)),
              Text(value, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: K.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}

/// "Day 23 of 41" ring.
class DayRing extends StatelessWidget {
  const DayRing({super.key, required this.day, required this.total, this.size = 100, this.dark = true});
  final int day, total;
  final double size;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final fg = dark ? K.ivory : K.maroon;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(total == 0 ? 0 : day / total, dark),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$day', style: TextStyle(fontFamily: K.serif, fontSize: size * 0.32, fontWeight: FontWeight.w700, color: fg, height: 1)),
            Text('/ $total', style: TextStyle(fontSize: size * 0.12, color: fg.withValues(alpha: 0.75))),
          ]),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.dark);
  final double progress;
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 6;
    final bg = Paint()
      ..color = (dark ? K.ivory : K.goldSoft).withValues(alpha: dark ? 0.15 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    canvas.drawCircle(c, r, bg);
    final fg = Paint()
      ..shader = const SweepGradient(colors: [K.saffron, K.goldBright, K.saffron]).createShader(Rect.fromCircle(center: c, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * progress.clamp(0, 1), false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ------------------------------------------------------------------ my god

class MyGodCard extends StatelessWidget {
  const MyGodCard({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final d = app.deity;
    final tt = Theme.of(context).textTheme;
    final chant = d.chantings.isEmpty ? null : app.repo.stotras[d.chantings.first];
    return GoldCard(
      key: const ValueKey('my-god'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          DeityAvatar(deity: d, size: 58),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Bi((l) => app.dayGodMode ? l.godByDay : l.myGod, style: tt.labelLarge?.copyWith(color: K.gold)),
              const SizedBox(height: 2),
              BiL(d.name, style: tt.titleLarge),
            ]),
          ),
          IconButton(
            tooltip: context.l.chooseGod,
            onPressed: () => _pickGod(context),
            icon: const Icon(Icons.swap_horiz, color: K.maroon),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: FilledButton.icon(
              key: const ValueKey('my-god-pooja'),
              onPressed: () => openDailyPooja(context, d),
              icon: const Icon(Icons.local_fire_department_outlined),
              label: BiPair(context.l.dailyPooja, context.l2.dailyPooja,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: K.ivory), secondaryColor: K.goldSoft),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              key: const ValueKey('my-god-chant'),
              onPressed: () {
                if (chant != null) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChantPlayerScreen(stotraId: chant.id)));
                } else {
                  KalpamShell.go(2);
                }
              },
              icon: const Icon(Icons.graphic_eq),
              label: BiPair(context.l.chanting, context.l2.chanting,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: K.maroon)),
            ),
          ),
        ]),
      ]),
    );
  }

  void _pickGod(BuildContext context) {
    final app = AppScope.read(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: K.ivory,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          ListTile(
            key: const ValueKey('pick-day-god'),
            leading: const CircleAvatar(radius: 20, backgroundColor: K.goldSoft, child: Icon(Icons.calendar_view_week, color: K.maroon)),
            title: Text(ctx.l.chooseByDay),
            subtitle: Text(ctx.l.chooseByDayDesc, maxLines: 2),
            trailing: app.dayGodMode ? const Icon(Icons.check, color: K.maroon) : null,
            onTap: () {
              app.setProfile(deity: AppState.dayGodId);
              Navigator.pop(ctx);
            },
          ),
          for (final d in app.repo.deities.values.where((d) => !d.isLight))
            ListTile(
              leading: DeityAvatar(deity: d, size: 40),
              title: Text(d.name.of(app.lang)),
              subtitle: Text(d.name.of(app.lang == 'en' ? 'te' : 'en')),
              trailing: app.deityId == d.id ? const Icon(Icons.check, color: K.maroon) : null,
              onTap: () {
                app.setProfile(deity: d.id);
                Navigator.pop(ctx);
              },
            ),
        ]),
      ),
    );
  }
}

// ------------------------------------------------------------------ today strip

class _TodayStrip extends StatelessWidget {
  const _TodayStrip();
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final p = app.panchang;
    final l = context.l;
    final tt = Theme.of(context).textTheme;
    final wg = app.weekdayGod;
    final parayanam = app.repo.parayanamFor(app.today.weekday);

    final l2 = context.l2;
    Widget cell(String label, String label2, String value, {String? sub}) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$label · $label2', style: tt.bodySmall),
            Text(value, style: tt.titleSmall?.copyWith(color: K.maroon, fontWeight: FontWeight.w700)),
            if (sub != null) Text(sub, style: tt.bodySmall?.copyWith(fontSize: 11)),
          ]),
        );

    return Column(children: [
      GoldCard(
        key: const ValueKey('panchang-strip'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PanchangamScreen())),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Bi((l) => l.panchangam, style: tt.titleLarge),
            const Spacer(),
            const Icon(Icons.chevron_right, color: K.gold),
          ]),
          const GoldRule(),
          Row(children: [
            cell(l.tithi, l2.tithi, context.t(p.tithi.name), sub: l.until(fmtTime(context, p.tithi.endsAt))),
            cell(l.nakshatram, l2.nakshatram, context.t(p.nakshatra.name), sub: l.until(fmtTime(context, p.nakshatra.endsAt))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            cell(l.sunrise, l2.sunrise, fmtTime(context, p.sunrise)),
            cell(l.sunset, l2.sunset, fmtTime(context, p.sunset)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            cell(l.rahuKalam, l2.rahuKalam, '${fmtTime(context, p.rahuKalam.start)} – ${fmtTime(context, p.rahuKalam.end)}'),
          ]),
        ]),
      ),
      for (final r in app.recurringToday) ...[
        const SizedBox(height: 12),
        GoldCard(
          child: Row(children: [
            const Icon(Icons.event_available, color: K.saffron),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${l.todayVratam} · ${l2.todayVratam}', style: tt.bodySmall),
                BiL(r.name, style: tt.titleMedium?.copyWith(color: K.maroon)),
              ]),
            ),
            app.isRecurringJoined(r.id)
                ? OutlinedButton.icon(onPressed: () => app.toggleRecurring(r.id), icon: const Icon(Icons.check),
                    label: BiPair(l.joined, l2.joined, style: const TextStyle(fontWeight: FontWeight.w600, color: K.maroon)))
                : FilledButton(onPressed: () => app.toggleRecurring(r.id),
                    child: BiPair(l.join, l2.join, style: const TextStyle(fontWeight: FontWeight.w600, color: K.ivory), secondaryColor: K.goldSoft)),
          ]),
        ),
      ],
      if (wg != null) ...[
        const SizedBox(height: 12),
        GoldCard(
          onTap: () => openDailyPooja(context, wg),
          child: Row(children: [
            DeityAvatar(deity: wg, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${l.weekdayGod} · ${l2.weekdayGod} — ${context.t(p.weekdayName)}', style: tt.bodySmall),
                BiL(wg.name, style: tt.titleMedium?.copyWith(color: K.maroon)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: K.gold),
          ]),
        ),
      ],
      if (parayanam.isNotEmpty) ...[
        const SizedBox(height: 12),
        GoldCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Bi((l) => l.parayanamToday, style: tt.titleMedium?.copyWith(color: K.maroon)),
            const SizedBox(height: 6),
            for (final s in parayanam)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book, color: K.gold),
                title: Text(context.t(s.title)),
                subtitle: Text(context.t2(s.title)),
                trailing: const Icon(Icons.play_circle_outline, color: K.maroon),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChantPlayerScreen(stotraId: s.id))),
              ),
          ]),
        ),
      ],
    ]);
  }
}

class _SecondarySeasonCard extends StatelessWidget {
  const _SecondarySeasonCard({required this.season});
  final FlagshipSeason season;
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final d = app.repo.deities[season.deityId]!;
    final tt = Theme.of(context).textTheme;
    return GoldCard(
      color: season.quiet ? K.ivoryDeep : null,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PoojaSetupScreen(deityId: d.id))),
      child: Row(children: [
        DeityAvatar(deity: d, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            BiL(season.title, style: tt.titleMedium?.copyWith(color: K.maroon)),
            const SizedBox(height: 2),
            Text(context.t(season.subtitle), style: tt.bodySmall),
            for (final m in season.milestones.where((m) => !m.date.isBefore(app.today)).take(2))
              Text('${fmtDate(context, m.date)} · ${context.t(m.name)}', style: tt.bodySmall?.copyWith(color: K.saffron)),
          ]),
        ),
      ]),
    );
  }
}

/// Daily Pooja for a god: the sanctum where one is open, otherwise (light
/// packs such as Sai Baba and Surya) the guided morning ritual.
void openDailyPooja(BuildContext context, DeityPack d) {
  if (d.isLight) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RitualScreen(slot: RitualSlot.morning)));
    return;
  }
  KalpamShell.go(1);
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PoojaSetupScreen(deityId: d.id)));
}
