/// Daily Rituals: Nitya Archana, morning (sunrise) and evening (sunset).
///
/// The planner is pure data: it turns a god's pack into an ordered list of
/// ritual steps. The same plan drives the guided ritual screen for every god
/// and, where a sanctum exists, the pooja engine (via [toVidhanam]).
/// Archana length always comes from the pack (full = every name in the
/// namavali, short = the pack's shortCount), so the verified 108 names fill
/// in with no code change.
library;

import '../content/localized.dart';
import '../content/models.dart';
import '../content/pack_repository.dart';

enum RitualSlot { morning, evening }

enum ArchanaForm { full, short }

enum RitualStepKind { sankalpam, suprabhatam, chant, offering, deepam, archana, aarti, closing }

class RitualStep {
  const RitualStep(this.kind, {this.stotra, this.names = const [], this.offering});
  final RitualStepKind kind;

  /// Suprabhatam / chant text.
  final StotraItem? stotra;

  /// Archana names (one flower each).
  final List<TextLine> names;

  /// e.g. 'arghyam' for Surya.
  final String? offering;
}

class RitualPlan {
  const RitualPlan({required this.slot, required this.deity, required this.form, required this.steps});
  final RitualSlot slot;
  final DeityPack deity;
  final ArchanaForm form;
  final List<RitualStep> steps;

  RitualStep? get archana {
    for (final s in steps) {
      if (s.kind == RitualStepKind.archana) return s;
    }
    return null;
  }
}

class DailyRitualPlanner {
  const DailyRitualPlanner(this.repo);
  final PackRepository repo;

  /// All archana names for [deity] (empty if the pack has none yet).
  List<TextLine> archanaNames(DeityPack deity, ArchanaForm form) {
    final s = repo.stotras[deity.rituals.archana];
    if (s == null) return const [];
    if (form == ArchanaForm.full) return s.lines;
    final n = deity.rituals.shortCount.clamp(1, s.lines.length);
    return s.lines.take(n).toList();
  }

  RitualPlan plan(DeityPack deity, RitualSlot slot, {ArchanaForm form = ArchanaForm.full}) {
    final r = deity.rituals;
    StotraItem? st(String? id) => id == null ? null : repo.stotras[id];
    final steps = <RitualStep>[];
    if (slot == RitualSlot.morning) {
      steps.add(const RitualStep(RitualStepKind.sankalpam));
      final supra = st(r.suprabhatam);
      if (supra != null) steps.add(RitualStep(RitualStepKind.suprabhatam, stotra: supra));
      // e.g. Sunday: Aditya Hridayam + Surya arghyam / namaskaram
      final chant = st(r.morningChant);
      if (chant != null && form == ArchanaForm.full) steps.add(RitualStep(RitualStepKind.chant, stotra: chant));
      if (r.morningOffering != null) steps.add(RitualStep(RitualStepKind.offering, offering: r.morningOffering));
      steps.add(const RitualStep(RitualStepKind.deepam));
      final names = archanaNames(deity, form);
      if (names.isNotEmpty) steps.add(RitualStep(RitualStepKind.archana, names: names));
      steps.add(const RitualStep(RitualStepKind.aarti));
    } else {
      steps.add(const RitualStep(RitualStepKind.deepam));
      steps.add(const RitualStep(RitualStepKind.aarti));
      final chant = st(r.eveningChant);
      if (chant != null) steps.add(RitualStep(RitualStepKind.chant, stotra: chant));
      steps.add(const RitualStep(RitualStepKind.closing));
    }
    return RitualPlan(slot: slot, deity: deity, form: form, steps: steps);
  }

  /// The plan as a pooja for the sanctum (Hands-on or Watch Mode). Upachara
  /// steps are borrowed from the god's own vidhanam so mantras and gestures
  /// stay identical to the full pooja.
  PoojaVidhanam toVidhanam(RitualPlan plan) {
    final d = plan.deity;
    final base = [...d.poojas.expand((p) => p.steps)];
    PoojaStep? up(String u) {
      for (final s in base) {
        if (s.upachara == u) return s;
      }
      return null;
    }

    final out = <PoojaStep>[];
    void add(PoojaStep? s) {
      if (s != null) out.add(s);
    }

    for (final s in plan.steps) {
      switch (s.kind) {
        case RitualStepKind.sankalpam:
          add(up('sankalpam'));
          add(up('bell'));
        case RitualStepKind.suprabhatam || RitualStepKind.chant:
          final t = s.stotra!;
          // The closing already plays this chant (Ayyappa: Harivarasanam).
          if (d.closingAudio.uri.endsWith('/${t.id}')) continue;
          out.add(PoojaStep(
            upachara: 'chant',
            title: t.title,
            instruction: t.title,
            mantra: LocalizedText({'en': t.lines.map((l) => l.translit).join(' '), 'te': t.lines.map((l) => l.script).join(' ')}),
            voice: MediaRef.none,
            action: PoojaAction.none,
            target: 1,
            autoDurationSec: (t.lines.length * 6).clamp(10, 120),
          ));
        case RitualStepKind.offering:
          add(up(s.offering!) ?? up('arghyam'));
        case RitualStepKind.deepam:
          add(up('deepam'));
        case RitualStepKind.archana:
          out.add(PoojaStep.archana(
            title: const LocalizedText({'en': 'Nitya Archana', 'te': 'నిత్య అర్చన'}),
            instruction: const LocalizedText({'en': 'Offer one flower for each name.', 'te': 'ప్రతి నామానికి ఒక పుష్పం సమర్పించండి.'}),
            names: s.names,
          ));
        case RitualStepKind.aarti:
          add(up('aarti'));
        case RitualStepKind.closing:
          add(up('namaskaram'));
      }
    }
    // Every pooja ends with the god's closing (Ayyappa: Harivarasanam, curtains).
    add(up('closing'));
    final total = out.fold<int>(0, (a, s) => a + s.autoDurationSec);
    return PoojaVidhanam(
      id: 'ritual_${plan.slot.name}_${plan.form.name}',
      name: plan.slot == RitualSlot.morning
          ? const LocalizedText({'en': 'Morning Nitya Archana', 'te': 'ఉదయ నిత్య అర్చన'})
          : const LocalizedText({'en': 'Evening Deeparadhana', 'te': 'సాయంత్ర దీపారాధన'}),
      lengthMin: (total / 60).ceil(),
      steps: out,
    );
  }
}
