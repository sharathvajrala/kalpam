import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/voice/voice_guide.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../pooja_engine/pooja_session.dart';
import '../sannidhanam/pooja_screen.dart';
import '../sannidhanam/pooja_setup_screen.dart';

/// Guided Nitya Archana for any god: step by step with the voice guide.
/// The archana offers one flower per name; for gods whose sanctum is open
/// (Ayyappa today) the same plan can be performed in the Sannidhanam.
class RitualScreen extends StatefulWidget {
  const RitualScreen({super.key, required this.slot});
  final RitualSlot slot;

  @override
  State<RitualScreen> createState() => _RitualScreenState();
}

class _RitualScreenState extends State<RitualScreen> {
  int _step = 0;
  int _offered = 0;
  bool _complete = false;

  bool _spokeFirst = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_spokeFirst) {
      _spokeFirst = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _guide());
    }
  }

  @override
  void dispose() {
    VoiceGuide.instance.stop();
    super.dispose();
  }

  /// Elder Mode: the voice guide reads each step as it becomes active.
  void _guide() {
    if (!mounted) return;
    final app = AppScope.read(context);
    if (!app.elderMode) return;
    final l = lookupAppLocalizations(Locale(app.lang));
    final plan = app.ritualPlan(widget.slot);
    if (_complete) {
      _speak('${l.ritualComplete}. ${l.poojaCompleteMsg(plan.deity.name.of(app.lang))}');
      return;
    }
    final st = plan.steps[_step];
    final text = switch (st.kind) {
      RitualStepKind.sankalpam => app.sankalpam(deity: plan.deity, vratam: null).full,
      RitualStepKind.suprabhatam || RitualStepKind.chant => '${_title(l, st)}. ${st.stotra!.lines.map((x) => x.script).join(' ')}',
      RitualStepKind.archana => '${l.archana}. ${l.offerFlower}.',
      RitualStepKind.offering => '${l.arghyam}. ${l.arghyamDesc}',
      RitualStepKind.deepam => '${l.deepam}. ${l.deepamDesc}',
      RitualStepKind.aarti => '${l.aarti}. ${l.aartiDesc}',
      RitualStepKind.closing => '${l.closingPrayer}. ${l.closingDesc}',
    };
    _speak(text);
  }

  void _speak(String text) => VoiceGuide.instance.speak(text, lang: AppScope.read(context).lang);

  void _next(RitualPlan plan) {
    if (_step < plan.steps.length - 1) {
      setState(() {
        _step++;
        _offered = 0;
      });
    } else {
      setState(() => _complete = true);
      AppScope.read(context).setRitualDone(widget.slot, true);
    }
    _guide();
  }

  String _title(AppLocalizations l, RitualStep s) => switch (s.kind) {
        RitualStepKind.sankalpam => l.sankalpam,
        RitualStepKind.suprabhatam => l.suprabhatam,
        RitualStepKind.chant => s.stotra!.title.of(l.localeName),
        RitualStepKind.offering => l.arghyam,
        RitualStepKind.deepam => l.deepam,
        RitualStepKind.archana => l.archana,
        RitualStepKind.aarti => l.aarti,
        RitualStepKind.closing => l.closingPrayer,
      };

  IconData _icon(RitualStepKind k) => switch (k) {
        RitualStepKind.sankalpam => Icons.front_hand_outlined,
        RitualStepKind.suprabhatam => Icons.wb_twilight,
        RitualStepKind.chant => Icons.graphic_eq,
        RitualStepKind.offering => Icons.water_drop_outlined,
        RitualStepKind.deepam => Icons.local_fire_department_outlined,
        RitualStepKind.archana => Icons.local_florist_outlined,
        RitualStepKind.aarti => Icons.brightness_7_outlined,
        RitualStepKind.closing => Icons.self_improvement,
      };

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    final plan = app.ritualPlan(widget.slot);
    final sanctumOpen = PoojaSetupBodyGate.openSanctums.contains(plan.deity.id) && !_complete && _step == 0;
    final title = widget.slot == RitualSlot.morning ? (AppLocalizations l) => l.morningRitual : (AppLocalizations l) => l.eveningRitual;

    return Scaffold(
      appBar: AppBar(title: Bi(title, style: tt.titleLarge)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(children: [
            Expanded(child: BiL(plan.deity.name, style: tt.titleMedium?.copyWith(color: K.maroon))),
            if (app.dayGodMode) Bi((l) => l.godByDay, style: tt.labelSmall?.copyWith(color: K.gold), align: CrossAxisAlignment.end),
          ]),
          if (widget.slot == RitualSlot.morning && plan.archana != null && _step == 0 && !_complete) ...[
            const SizedBox(height: 12),
            ArchanaFormChips(slot: widget.slot),
          ],
          if (sanctumOpen) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('ritual-sannidhanam'),
              icon: const Icon(Icons.temple_hindu_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => PoojaScreen(
                  deity: plan.deity,
                  vidhanam: app.ritualPlanner.toVidhanam(plan),
                  mode: app.elderMode ? PoojaMode.watch : PoojaMode.handsOn,
                  sankalpamText: app.sankalpam(deity: plan.deity, vratam: null).full,
                  onCompleted: () => AppScope.read(context).setRitualDone(widget.slot, true),
                ),
              )),
              label: Bi((l) => l.performInSannidhanam, style: tt.labelLarge),
            ),
          ],
          const SizedBox(height: 12),
          if (_complete)
            GoldCard(
              key: const Key('ritual-complete'),
              child: Column(children: [
                const Icon(Icons.local_florist, color: K.gold, size: 32),
                const SizedBox(height: 8),
                Bi((l) => l.ritualComplete, style: tt.titleLarge, align: CrossAxisAlignment.center),
                const SizedBox(height: 6),
                Text(context.l.poojaCompleteMsg(context.t(plan.deity.name)), textAlign: TextAlign.center, style: tt.bodyMedium),
                const SizedBox(height: 14),
                FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l.backToToday)),
              ]),
            ),
          for (final (i, s) in plan.steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _stepCard(context, plan, i, s),
            ),
        ],
      ),
    );
  }

  Widget _stepCard(BuildContext context, RitualPlan plan, int i, RitualStep s) {
    final tt = Theme.of(context).textTheme;
    final active = i == _step && !_complete;
    final done = i < _step || _complete;
    final header = Row(children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: done ? K.success : (active ? K.maroon : K.ivoryDeep),
        child: Icon(done ? Icons.check : _icon(s.kind), size: 18, color: done || active ? Colors.white : K.inkSoft),
      ),
      const SizedBox(width: 12),
      Expanded(child: BiPair(_title(context.l, s), _title(context.l2, s), style: tt.titleMedium)),
      if (s.kind == RitualStepKind.archana) Text('${s.names.length}', style: tt.labelLarge?.copyWith(color: K.gold)),
    ]);
    if (!active) return GoldCard(padding: const EdgeInsets.all(12), child: header);

    final app = context.app;
    Widget body;
    switch (s.kind) {
      case RitualStepKind.sankalpam:
        final text = app.sankalpam(deity: plan.deity, vratam: null).full;
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.l.sankalpamDesc, style: tt.bodySmall?.copyWith(color: K.inkSoft)),
          const SizedBox(height: 8),
          Text(text, style: tt.bodyMedium?.copyWith(height: 1.6)),
          _actions(context, plan, listen: text),
        ]);
      case RitualStepKind.suprabhatam || RitualStepKind.chant:
        final st = s.stotra!;
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final line in st.lines) ...[
            Text(line.script, style: tt.titleMedium?.copyWith(fontFamily: K.teluguSerif, color: K.maroon)),
            Text(line.translit, style: tt.bodySmall?.copyWith(color: K.inkSoft)),
            const SizedBox(height: 6),
          ],
          if (!st.complete) PlaceholderChip(context.l.sampleText),
          _actions(context, plan, listen: st.lines.map((l) => l.script).join(' ')),
        ]);
      case RitualStepKind.archana:
        final n = s.names.length;
        final cur = s.names[_offered.clamp(0, n - 1)];
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.l.nameOf(_offered + 1, n), style: tt.labelLarge?.copyWith(color: K.gold)),
          const SizedBox(height: 6),
          Text(cur.script, key: const Key('ritual-name'), style: tt.headlineSmall?.copyWith(fontFamily: K.teluguSerif, color: K.maroon)),
          Text(cur.translit, style: tt.bodyMedium),
          Text(context.t(cur.meaning), style: tt.bodySmall?.copyWith(color: K.inkSoft)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: _offered / n, minHeight: 6, backgroundColor: K.ivoryDeep,
                valueColor: const AlwaysStoppedAnimation(K.saffron)),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('offer-flower'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            icon: const Icon(Icons.local_florist),
            label: Text(context.l.offerFlower),
            onPressed: () {
              _speak(cur.script);
              if (_offered + 1 >= n) {
                _next(plan);
              } else {
                setState(() => _offered++);
              }
            },
          ),
        ]);
      case RitualStepKind.offering:
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.l.arghyamDesc, style: tt.bodyMedium),
          _actions(context, plan),
        ]);
      case RitualStepKind.deepam:
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.l.deepamDesc, style: tt.bodyMedium), _actions(context, plan)]);
      case RitualStepKind.aarti:
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.l.aartiDesc, style: tt.bodyMedium), _actions(context, plan)]);
      case RitualStepKind.closing:
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.l.closingDesc, style: tt.bodyMedium),
          Text(context.t(plan.deity.closingName), style: tt.bodySmall?.copyWith(color: K.inkSoft)),
          _actions(context, plan),
        ]);
    }
    return GoldCard(
      key: Key('ritual-step-$i'),
      color: K.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [header, const SizedBox(height: 12), body]),
    );
  }

  Widget _actions(BuildContext context, RitualPlan plan, {String? listen}) {
    final listenButton = listen == null
        ? null
        : OutlinedButton.icon(
            onPressed: () => _speak(listen),
            icon: const Icon(Icons.volume_up_outlined),
            label: Text(context.l.listen),
          );
    final done = FilledButton(
      key: const Key('ritual-next'),
      style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
      onPressed: () => _next(plan),
      child: Text(context.l.markDone),
    );
    // Elder Mode: full-width buttons, one above the other.
    if (context.app.elderMode) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (listenButton != null) ...[listenButton, const SizedBox(height: 10)],
          done,
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(children: [?listenButton, const Spacer(), done]),
    );
  }
}

/// Full / short archana for today (remembered as the next day's default).
class ArchanaFormChips extends StatelessWidget {
  const ArchanaFormChips({super.key, required this.slot});
  final RitualSlot slot;
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final planner = app.ritualPlanner;
    final form = app.archanaFormFor(app.today);
    final tt = Theme.of(context).textTheme;
    return Wrap(spacing: 8, children: [
      for (final f in ArchanaForm.values)
        ChoiceChip(
          key: Key('archana-form-${f.name}'),
          selected: form == f,
          onSelected: (_) => app.setArchanaForm(f),
          label: Bi(
            (l) => f == ArchanaForm.full
                ? l.archanaFullN(planner.archanaNames(app.deity, f).length)
                : l.archanaShortN(planner.archanaNames(app.deity, f).length),
            style: tt.labelLarge,
          ),
        ),
    ]);
  }
}
