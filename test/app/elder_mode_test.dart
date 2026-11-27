import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/core/voice/voice_commands.dart';
import 'package:kalpam/core/voice/voice_guide.dart';
import 'package:kalpam/core/voice/voice_listener.dart';
import 'package:kalpam/features/elder/elder_mode.dart';
import 'package:kalpam/core/rituals/daily_rituals.dart';
import 'package:kalpam/features/rituals/ritual_screen.dart';
import 'package:kalpam/features/sannidhanam/pooja_screen.dart';
import 'package:kalpam/features/today/panchangam_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeListener implements VoiceListener {
  FakeListener(this.heard, {this.ok = true});
  String heard;
  bool ok;
  int listens = 0;
  @override
  Future<bool> available() async => ok;
  @override
  Future<String> listenOnce({required String lang}) async {
    listens++;
    return heard;
  }

  @override
  Future<void> cancel() async {}
}

Future<void> frames(WidgetTester t, [int n = 10]) async {
  for (var i = 0; i < n; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('voice commands', () {
    test('English and Telugu keywords, specific before general', () {
      expect(VoiceCommands.parse('start the pooja'), VoiceCommand.pooja);
      expect(VoiceCommands.parse('Puja'), VoiceCommand.pooja);
      expect(VoiceCommands.parse('పూజ చేయండి'), VoiceCommand.pooja);
      expect(VoiceCommands.parse('evening pooja'), VoiceCommand.evening);
      expect(VoiceCommands.parse('సాయంత్రం పూజ'), VoiceCommand.evening);
      expect(VoiceCommands.parse('ఉదయం అర్చన'), VoiceCommand.morning);
      expect(VoiceCommands.parse("what's today's tithi"), VoiceCommand.panchangam);
      expect(VoiceCommands.parse('పంచాంగం'), VoiceCommand.panchangam);
      expect(VoiceCommands.parse('play bhajans'), VoiceCommand.bhajans);
      expect(VoiceCommands.parse('భజనలు'), VoiceCommand.bhajans);
      expect(VoiceCommands.parse('Vishnu Sahasranamam'), VoiceCommand.chanting);
      expect(VoiceCommands.parse('ఆపు'), VoiceCommand.stop);
      expect(VoiceCommands.parse('stop the bhajan'), VoiceCommand.stop);
      expect(VoiceCommands.parse('go home'), VoiceCommand.today);
      expect(VoiceCommands.parse('hmm'), isNull);
      expect(VoiceCommands.parse(''), isNull);
    });
  });

  Future<AppState> boot(WidgetTester t, {String lang = 'en', String now = '2026-11-27T06:30:00+05:30', String deity = 'ayyappa'}) async {
    t.view.physicalSize = const Size(1080, 2220);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    VoiceGuide.spokenLog = [];
    SharedPreferences.setMockInitialValues({
      'onboarded': true, 'lang': lang, 'deity': deity, 'city': 'hyderabad', 'elder': true,
      'remindMorning': '05:30', 'remindEvening': '18:30',
      'profiles': '[{"id":"p1","name":"Lakshmi","gotra":"Kashyapa"}]', 'activeProfile': 'p1',
    });
    final repo = await t.runAsync(() => PackRepository.load((p) => File(p).readAsString()));
    final fixed = DateTime.parse(now);
    final state = AppState(repo: repo!, prefs: await SharedPreferences.getInstance(), clock: () => fixed);
    KalpamShell.tabIndex.value = 0;
    PoojaScreen.debugUseSensors = false;
    await t.pumpWidget(KalpamApp(state: state));
    await frames(t);
    return state;
  }

  testWidgets('Today read aloud: greeting, Panchangam, sunrise, the god, what is pending', (t) async {
    final s = await boot(t);
    final text = todayDigest(s);
    expect(text, startsWith('Subhodayam, Lakshmi.'));
    expect(text, contains('Today is Friday: Krishna Paksha Tritiya, Ardra nakshatram.'));
    expect(text, contains('Sunrise 6:27 AM, sunset 5:39 PM.'));
    expect(text, contains("Today's god: Swamy Ayyappa."));
    expect(text, contains('Morning Nitya Archana is ready'));
    for (final w in ['missed', 'late', 'streak']) {
      expect(text.toLowerCase(), isNot(contains(w)));
    }
    await t.drag(find.descendant(of: find.byType(ListView), matching: find.byKey(const ValueKey('elder-today'))), const Offset(0, -200));
    await frames(t);
    await t.tap(find.byKey(const ValueKey('elder-listen-today')));
    await t.pump();
    expect(VoiceGuide.spokenLog, [text]);
  });

  testWidgets('Elder Today: one tap runs the pooja in Watch Mode in the sanctum', (t) async {
    await boot(t);
    expect(find.byKey(const ValueKey('elder-today')), findsOneWidget);
    expect(find.text('Watch Mode · Swamy Ayyappa'), findsOneWidget);
    expect(find.byKey(const ValueKey('voice-mic')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('elder-begin-pooja')));
    await t.tap(find.byKey(const ValueKey('elder-begin-pooja')));
    await frames(t);
    final screen = t.widget<PoojaScreen>(find.byType(PoojaScreen));
    expect(screen.mode.name, 'watch');
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('Elder Today for a god without an open sanctum: the guided ritual reads each step', (t) async {
    await boot(t, deity: 'shiva');
    expect(find.textContaining('Guided with voice'), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('elder-begin-pooja')));
    await t.tap(find.byKey(const ValueKey('elder-begin-pooja')));
    await frames(t);
    expect(find.byType(RitualScreen), findsOneWidget);
    expect(VoiceGuide.spokenLog, isNotEmpty, reason: 'the first step (Sankalpam) is read aloud');
    expect(VoiceGuide.spokenLog!.first, contains('Lakshmi'));
    final before = VoiceGuide.spokenLog!.length;
    await t.scrollUntilVisible(find.byKey(const Key('ritual-next')), 200, scrollable: find.descendant(of: find.byType(RitualScreen), matching: find.byType(Scrollable)).first);
    await t.drag(find.descendant(of: find.byType(RitualScreen), matching: find.byType(Scrollable)).first, const Offset(0, -150));
    await frames(t);
    await t.tap(find.byKey(const Key('ritual-next')));
    await t.pump(const Duration(milliseconds: 500));
    expect(VoiceGuide.spokenLog!.length, greaterThan(before), reason: 'the next step is read too');
  });

  testWidgets('Voice navigation: the mic hears a command and acts on it', (t) async {
    final fake = FakeListener('bhajans');
    VoiceListener.instance = fake;
    await boot(t);
    await t.tap(find.byKey(const ValueKey('voice-mic')));
    await frames(t);
    expect(fake.listens, 1);
    expect(KalpamShell.tabIndex.value, 3);
    expect(VoiceGuide.spokenLog!.last, 'Bhajans');

    fake.heard = 'పంచాంగం';
    await frames(t, 50); // let the "Heard" note clear
    await t.tap(find.byKey(const ValueKey('voice-mic')));
    await frames(t);
    expect(find.byType(PanchangamScreen), findsOneWidget);
    expect(VoiceGuide.spokenLog!.last, contains('Sunrise'));

    fake.heard = 'something else';
    KalpamApp.navigatorKey.currentState!.pop();
    await frames(t, 50);
    await t.tap(find.byKey(const ValueKey('voice-mic')));
    await frames(t);
    expect(VoiceGuide.spokenLog!.last, contains('Say: Pooja'));
    await t.pump(const Duration(seconds: 5));
  });

  testWidgets('No microphone: says so kindly, nothing breaks', (t) async {
    VoiceListener.instance = FakeListener('', ok: false);
    await boot(t, lang: 'te');
    await t.tap(find.byKey(const ValueKey('voice-mic')));
    await frames(t);
    expect(VoiceGuide.spokenLog!.last, contains('వాయిస్ ఆదేశాలు'));
    await t.pump(const Duration(seconds: 5));
  });

  testWidgets('Elder Mode off: no mic, no Elder card', (t) async {
    final s = await boot(t);
    await s.setElderMode(false);
    await frames(t);
    expect(find.byKey(const ValueKey('voice-mic')), findsNothing);
    expect(find.byKey(const ValueKey('elder-today')), findsNothing);
  });

  for (final lang in ['te', 'en']) {
    testWidgets('Elder Mode, small phone, $lang: every ritual step fits', (t) async {
      final s = await boot(t, lang: lang);
      expect(s.elderMode, isTrue);
      final problems = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (d) => problems.add(d.exceptionAsString().split('\n').first);
      for (final slot in RitualSlot.values) {
        KalpamApp.navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => RitualScreen(slot: slot)));
        await frames(t);
        for (var guard = 0; guard < 60 && find.byKey(const Key('ritual-complete')).evaluate().isEmpty; guard++) {
          final offer = find.byKey(const Key('offer-flower'));
          final target = offer.evaluate().isNotEmpty ? offer : find.byKey(const Key('ritual-next'));
          // The active step may lie beyond the lazily built part of the list.
          final list = find.descendant(of: find.byType(RitualScreen), matching: find.byType(Scrollable)).first;
          for (var i = 0; i < 20 && target.evaluate().isEmpty; i++) {
            final pos = (t.state(list) as ScrollableState).position;
            pos.jumpTo((pos.pixels + 400).clamp(0, pos.maxScrollExtent));
            await t.pump(const Duration(milliseconds: 50));
          }
          Scrollable.ensureVisible(target.evaluate().first, alignment: 0.5).ignore();
          await t.pump(const Duration(milliseconds: 100));
          t.widget<ButtonStyleButton>(target).onPressed!();
          await t.pump(const Duration(milliseconds: 200));
        }
        if (find.byKey(const Key('ritual-complete')).evaluate().isEmpty) problems.add('${slot.name}: did not finish');
        KalpamApp.navigatorKey.currentState!.pop();
        await frames(t);
      }
      FlutterError.onError = old;
      expect(problems, isEmpty);
    });
  }
}
