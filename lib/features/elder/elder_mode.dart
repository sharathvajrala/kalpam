/// Elder Mode: one-tap pooja, today read aloud, and voice navigation.
///
/// Elder Mode keeps every screen (it is the same app, bigger), and adds:
/// * a "Today's pooja" card at the top of Today: one tap and the day's
///   pooja runs in Watch Mode in the sanctum (or the guided ritual with
///   voice for gods whose sanctum is not open yet);
/// * "Listen to today": the Panchangam, the day's god and what is still
///   pending, spoken in the user's language;
/// * a microphone button on every tab: say "Pooja", "Evening",
///   "Panchangam", "Bhajans"… (English or Telugu).
library;

import 'package:material_ui/material_ui.dart';

import '../../app/app.dart';
import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/voice/voice_commands.dart';
import '../../core/voice/voice_guide.dart';
import '../../core/voice/voice_listener.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../pooja_engine/pooja_session.dart';
import '../rituals/ritual_screen.dart';
import '../sannidhanam/pooja_screen.dart';
import '../sannidhanam/pooja_setup_screen.dart';
import '../settings/settings_screen.dart';
import '../today/panchangam_screen.dart';

AppLocalizations _l(AppState app) => lookupAppLocalizations(Locale(app.lang));

String _time(AppState app, DateTime utc) {
  final l = app.city.local(utc);
  final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  return '$h:${l.minute.toString().padLeft(2, '0')} ${l.hour < 12 ? 'AM' : 'PM'}';
}

/// The ritual that fits the time of day: morning until 3 PM, then evening.
RitualSlot currentSlot(AppState app) => app.city.local(app.now.toUtc()).hour < 15 ? RitualSlot.morning : RitualSlot.evening;

/// Today, spoken: greeting, Panchangam, sunrise/sunset, the day's god and
/// the ritual still waiting (never a reproach).
String todayDigest(AppState app) {
  final l = _l(app);
  final lang = app.lang;
  final p = app.panchang;
  final evening = app.city.local(app.now.toUtc()).hour >= 16;
  final greeting = evening ? l.subhaSayantram : l.subhodayam;
  final morningDone = app.ritualDone(RitualSlot.morning);
  final eveningDone = app.ritualDone(RitualSlot.evening);
  final pending = !morningDone && !evening
      ? l.morningRitual
      : (!eveningDone && evening ? l.eveningRitual : null);
  return [
    app.devoteeName.isEmpty ? '$greeting.' : l.digestGreeting(greeting, app.devoteeName),
    l.digestDay(p.nakshatra.name.of(lang), '${p.tithi.paksha.of(lang)} ${p.tithi.name.of(lang)}', p.weekdayName.of(lang)),
    l.digestSun(_time(app, p.sunset), _time(app, p.sunrise)),
    l.digestGod(app.deity.name.of(lang)),
    if (pending != null) l.digestPending(pending) else if (morningDone && eveningDone) l.digestAllDone,
  ].join(' ');
}

/// One tap: the day's pooja. Gods with an open sanctum run in Watch Mode in
/// the sanctum; the others open the guided ritual, which speaks each step.
void startTodaysPooja(BuildContext context) {
  final app = AppScope.read(context);
  final slot = currentSlot(app);
  final plan = app.ritualPlan(slot);
  final nav = Navigator.of(context);
  if (PoojaSetupBodyGate.openSanctums.contains(plan.deity.id)) {
    nav.push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PoojaScreen(
        deity: plan.deity,
        vidhanam: app.ritualPlanner.toVidhanam(plan),
        mode: PoojaMode.watch,
        sankalpamText: app.sankalpam(deity: plan.deity, vratam: null).full,
        onCompleted: () => app.setRitualDone(slot, true),
      ),
    ));
  } else {
    nav.push(MaterialPageRoute(builder: (_) => RitualScreen(slot: slot)));
  }
}

/// Carries out a spoken command. Unknown words get the help sentence.
void runVoiceCommand(BuildContext context, VoiceCommand? c) {
  final app = AppScope.read(context);
  final l = _l(app);
  final voice = VoiceGuide.instance;
  void say(String s) => voice.speak(s, lang: app.lang);
  final nav = KalpamApp.navigatorKey.currentState ?? Navigator.of(context);
  void tab(int i, String name) {
    nav.popUntil((r) => r.isFirst);
    KalpamShell.go(i);
    say(name);
  }

  switch (c) {
    case null:
      say('${l.voiceNotUnderstood} ${l.voiceHelp}');
    case VoiceCommand.stop:
      voice.stop();
    case VoiceCommand.help:
      say(l.voiceHelp);
    case VoiceCommand.settings:
      nav.push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
      say(l.settings);
    case VoiceCommand.morning || VoiceCommand.evening:
      final slot = c == VoiceCommand.morning ? RitualSlot.morning : RitualSlot.evening;
      nav.popUntil((r) => r.isFirst);
      KalpamShell.go(0);
      nav.push(MaterialPageRoute(builder: (_) => RitualScreen(slot: slot)));
    case VoiceCommand.panchangam:
      nav.push(MaterialPageRoute(builder: (_) => const PanchangamScreen()));
      say(todayDigest(app));
    case VoiceCommand.pooja:
      nav.popUntil((r) => r.isFirst);
      KalpamShell.go(0);
      startTodaysPooja(nav.context);
    case VoiceCommand.today:
      tab(0, l.tabToday);
    case VoiceCommand.sannidhanam:
      tab(1, l.tabSannidhanam);
    case VoiceCommand.chanting:
      tab(2, l.tabGrantham);
    case VoiceCommand.bhajans:
      tab(3, l.tabBhajans);
    case VoiceCommand.groups:
      tab(4, l.tabGroups);
  }
}

/// Top of Today in Elder Mode.
class ElderTodayCard extends StatelessWidget {
  const ElderTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final tt = Theme.of(context).textTheme;
    final slot = currentSlot(app);
    final plan = app.ritualPlan(slot);
    final inSanctum = PoojaSetupBodyGate.openSanctums.contains(plan.deity.id);
    final done = app.ritualDone(slot);
    final god = context.t(plan.deity.name);
    return GoldCard(
      key: const ValueKey('elder-today'),
      color: K.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Bi((l) => l.elderTodayPooja, style: tt.titleLarge?.copyWith(color: K.maroon)),
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey('elder-begin-pooja'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(84), backgroundColor: done ? K.success : K.maroon),
          onPressed: () => startTodaysPooja(context),
          child: Row(children: [
            Icon(done ? Icons.check_circle : Icons.play_circle_fill, size: 44, color: K.goldSoft),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(done ? context.l.ritualComplete : context.l.elderBeginPooja,
                    style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                Text(inSanctum ? context.l.elderWatchFor(god) : context.l.elderGuidedFor(god),
                    style: tt.bodyMedium?.copyWith(color: K.goldSoft)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const ValueKey('elder-listen-today'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
          onPressed: () => VoiceGuide.instance.speak(todayDigest(app), lang: app.lang),
          icon: const Icon(Icons.volume_up, size: 30),
          label: Bi((l) => l.listenToday, style: tt.titleMedium),
        ),
      ]),
    );
  }
}

/// Elder Mode microphone: listens once, shows what it heard, acts.
class VoiceMicButton extends StatefulWidget {
  const VoiceMicButton({super.key});
  @override
  State<VoiceMicButton> createState() => _VoiceMicButtonState();
}

class _VoiceMicButtonState extends State<VoiceMicButton> {
  bool _listening = false;

  Future<void> _go() async {
    final app = AppScope.read(context);
    final l = _l(app);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (_listening) return;
    await VoiceGuide.instance.stop();
    if (!await VoiceListener.instance.available()) {
      messenger?.showSnackBar(SnackBar(content: Text(l.micUnavailable)));
      VoiceGuide.instance.speak(l.micUnavailable, lang: app.lang);
      return;
    }
    setState(() => _listening = true);
    messenger?.showSnackBar(SnackBar(content: Text(l.listening), duration: const Duration(seconds: 6)));
    final heard = await VoiceListener.instance.listenOnce(lang: app.lang);
    if (!mounted) return;
    setState(() => _listening = false);
    messenger?.hideCurrentSnackBar();
    if (heard.isNotEmpty) messenger?.showSnackBar(SnackBar(content: Text(l.heard(heard))));
    runVoiceCommand(context, VoiceCommands.parse(heard));
  }

  @override
  Widget build(BuildContext context) => FloatingActionButton.large(
        key: const ValueKey('voice-mic'),
        heroTag: 'voice-mic',
        tooltip: context.l.speakCommand,
        backgroundColor: _listening ? K.saffron : K.maroon,
        foregroundColor: K.goldSoft,
        onPressed: _go,
        child: Icon(_listening ? Icons.graphic_eq : Icons.mic, size: 40),
      );
}
