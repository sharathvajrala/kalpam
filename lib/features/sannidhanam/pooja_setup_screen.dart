import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/content/localized.dart';
import '../../core/content/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../pooja_engine/pooja_session.dart';
import '../../pooja_engine/sanctum_bridge.dart';
import 'placeholder_sanctum.dart';
import 'pooja_screen.dart';

enum ArchanaChoice { none, short, full }

/// Only the Ayyappa sanctum opens until it has been reviewed (build addendum:
/// demo the engine with Ayyappa before any other god).
class PoojaSetupBodyGate {
  static const openSanctums = {'ayyappa'};
  static String openFor(String deityId) => openSanctums.contains(deityId) ? deityId : 'ayyappa';
}

/// Pushed from Today ("Daily Pooja"); the Sannidhanam tab shows the same body.
class PoojaSetupScreen extends StatelessWidget {
  const PoojaSetupScreen({super.key, required this.deityId});
  final String deityId;

  @override
  Widget build(BuildContext context) {
    final deity = context.app.repo.deities[deityId]!;
    return Scaffold(
      appBar: AppBar(title: BiL(deity.name, style: Theme.of(context).textTheme.titleLarge)),
      body: PoojaSetupBody(deityId: deityId),
    );
  }
}

/// Mode (Hands-on / Watch), length (5 / 15 / Shodashopachara), optional
/// archana, and a preview of the Sankalpam that will be spoken.
class PoojaSetupBody extends StatefulWidget {
  const PoojaSetupBody({super.key, required this.deityId, this.header});
  final String deityId;
  final Widget? header;

  @override
  State<PoojaSetupBody> createState() => _PoojaSetupBodyState();
}

class _PoojaSetupBodyState extends State<PoojaSetupBody> {
  PoojaMode? _mode;
  String? _vidhanamId;
  ArchanaChoice _archana = ArchanaChoice.none;
  final _previewBridge = SanctumBridge();

  List<TextLine> _names(DeityPack d) {
    final repo = context.app.repo;
    for (final id in [...d.stotras, ...d.chantings]) {
      final s = repo.stotras[id];
      if (s != null && (s.category == 'ashtottaram' || s.category == 'saranam')) return s.lines;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    final requested = app.repo.deities[widget.deityId]!;
    final deity = app.repo.deities[PoojaSetupBodyGate.openFor(requested.id)]!;
    final mode = _mode ?? (app.elderMode ? PoojaMode.watch : PoojaMode.handsOn);
    final vidhanam = deity.poojas.firstWhere((p) => p.id == _vidhanamId, orElse: () => deity.poojas.first);
    final names = _names(deity);
    final shortN = names.length < 16 ? names.length : 16;
    final sankalpam = app.sankalpam(deity: deity, vratam: null);

    Widget section(Widget title) => Padding(padding: const EdgeInsets.fromLTRB(4, 20, 4, 8), child: title);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        ?widget.header,
        if (requested.id != deity.id)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GoldCard(
              child: Row(children: [
                const Icon(Icons.info_outline, color: K.gold),
                const SizedBox(width: 12),
                Expanded(child: Bi((l) => l.sanctumAfterReview(l.localeName == 'te' ? requested.name.of('te') : requested.name.of('en')), style: tt.bodyMedium)),
              ]),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(K.radius),
          child: SizedBox(
            height: 240,
            child: Stack(children: [
              Positioned.fill(child: PlaceholderSanctum(bridge: _previewBridge, deity: deity)),
              Positioned(left: 12, bottom: 12, child: PlaceholderChip(context.l.placeholderSanctum)),
            ]),
          ),
        ),
        section(Bi((l) => l.poojaHow, style: tt.titleMedium)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _ModeCard(selected: mode == PoojaMode.handsOn, icon: Icons.back_hand_outlined,
              title: (l) => l.modeHandsOn, desc: (l) => l.modeHandsOnDesc, key: const Key('mode-handsOn'),
              onTap: () => setState(() => _mode = PoojaMode.handsOn))),
          const SizedBox(width: 12),
          Expanded(child: _ModeCard(selected: mode == PoojaMode.watch, icon: Icons.visibility_outlined,
              title: (l) => l.modeWatch, desc: (l) => l.modeWatchDesc, key: const Key('mode-watch'),
              onTap: () => setState(() => _mode = PoojaMode.watch))),
        ]),
        section(Bi((l) => l.chooseLength, style: tt.titleMedium)),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in deity.poojas)
            ChoiceChip(
              key: Key('length-${p.id}'),
              selected: p.id == vidhanam.id,
              onSelected: (_) => setState(() => _vidhanamId = p.id),
              label: BiPair(context.t(p.name), context.t2(p.name), style: tt.labelLarge),
            ),
        ]),
        if (names.isNotEmpty) ...[
          section(Bi((l) => l.archana, style: tt.titleMedium)),
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Bi((l) => l.archanaDesc, style: tt.bodySmall)),
          Wrap(spacing: 8, children: [
            for (final c in ArchanaChoice.values)
              ChoiceChip(
                key: Key('archana-${c.name}'),
                selected: _archana == c,
                onSelected: (_) => setState(() => _archana = c),
                label: Bi((l) => switch (c) {
                      ArchanaChoice.none => l.archanaOff,
                      ArchanaChoice.short => l.archanaShort(shortN),
                      ArchanaChoice.full => l.archanaFull(names.length),
                    }, style: tt.labelLarge),
              ),
          ]),
        ],
        section(Bi((l) => l.sankalpamFor(app.devoteeName.isEmpty ? l.devotee : app.devoteeName), style: tt.titleMedium)),
        GoldCard(
          child: Text(sankalpam.full, style: tt.bodyMedium?.copyWith(height: 1.6)),
        ),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('begin-pooja'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60)),
          onPressed: () {
            var v = vidhanam;
            if (_archana != ArchanaChoice.none) {
              final list = _archana == ArchanaChoice.short ? names.take(shortN).toList() : names;
              v = v.withArchana(PoojaStep.archana(
                title: const LocalizedText({'en': 'Archana', 'te': 'అర్చన'}),
                instruction: const LocalizedText({'en': 'Offer one flower for each name.', 'te': 'ప్రతి నామానికి ఒక పుష్పం సమర్పించండి.'}),
                names: list,
              ));
            }
            Navigator.of(context).push(MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => PoojaScreen(deity: deity, vidhanam: v, mode: mode, sankalpamText: sankalpam.full),
            ));
          },
          child: Bi((l) => l.beginPooja, style: tt.titleMedium?.copyWith(color: Colors.white), align: CrossAxisAlignment.center,
              secondaryColor: K.goldSoft),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({super.key, required this.selected, required this.icon, required this.title, required this.desc, required this.onTap});
  final bool selected;
  final IconData icon;
  final String Function(AppLocalizations l) title, desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GoldCard(
      onTap: onTap,
      color: selected ? K.maroon : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: selected ? K.goldSoft : K.maroon),
          const Spacer(),
          if (selected) const Icon(Icons.check_circle, color: K.goldSoft, size: 20),
        ]),
        const SizedBox(height: 10),
        Bi(title, style: tt.titleSmall?.copyWith(color: selected ? Colors.white : K.maroon),
            secondaryColor: selected ? K.goldSoft : null),
        const SizedBox(height: 6),
        Text(desc(context.l), style: tt.bodySmall?.copyWith(color: selected ? Colors.white70 : K.inkSoft)),
      ]),
    );
  }
}
