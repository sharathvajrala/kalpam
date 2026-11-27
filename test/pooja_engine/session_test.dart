import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/core/content/localized.dart';
import 'package:kalpam/core/content/models.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/pooja_engine/gestures.dart';
import 'package:kalpam/pooja_engine/pooja_session.dart';
import 'package:kalpam/pooja_engine/sanctum_bridge.dart';

void main() {
  late PackRepository repo;
  setUpAll(() async => repo = await PackRepository.load((p) => File(p).readAsString()));

  PoojaStep archana(PackRepository r, int n) => PoojaStep.archana(
        title: const LocalizedText({'en': 'Archana'}),
        instruction: const LocalizedText({'en': 'Offer'}),
        names: r.stotras['ayyappa_saranam_108']!.lines.take(n).toList(),
      );

  test('archana is inserted before the aarti', () {
    final v = repo.deities['ayyappa']!.pooja('nitya5')!.withArchana(archana(repo, 12));
    final order = v.steps.map((s) => s.upachara).toList();
    expect(order.indexOf('archana'), order.indexOf('aarti') - 1);
    expect(order.last, 'closing');
  });

  test('hands-on through the gesture recognizers, with the Sankalpam spoken first', () async {
    final d = repo.deities['ayyappa']!;
    final voice = SilentVoice();
    final bridge = SanctumBridge();
    final s = PoojaSession(
      deity: d, vidhanam: d.pooja('nitya5')!.withArchana(archana(repo, 3)), mode: PoojaMode.handsOn,
      bridge: bridge, lang: 'te', sankalpamText: 'మమ ఉపాత్త ... సంకల్పం', voice: voice, timeScale: 0.001,
    );
    await s.start();
    expect(voice.log.first, contains('సంకల్పం'));
    expect(s.recognizer, isA<TapRecognizer>());
    s.recognizer.tap(const Vec(0.5, 0.5)); // sankalpam accepted
    expect(s.step.upachara, 'bell');
    expect(s.recognizer, isA<ShakeRecognizer>());
    s.recognizer.accel(25, 10, 0, 1);
    s.recognizer.accel(25, 10, 0, 1.1); // same swing, debounced
    expect(s.actionsDone, 1);
    s.recognizer.tap(const Vec(0.5, 0.5));
    s.recognizer.tap(const Vec(0.5, 0.5));
    expect(s.step.upachara, 'deepam');
    s.recognizer.tap(const Vec(0.5, 0.5));
    expect(bridge.sentLog.any((m) => m.contains('lightLamp')), isTrue, reason: 'hands-on leaves the same visual');
    // pushpam: three upward swipes
    for (var i = 0; i < 3; i++) {
      s.recognizer.down(const Vec(0.5, 0.8), i.toDouble());
      s.recognizer.up(const Vec(0.5, 0.4), i + 0.3);
    }
    expect(s.step.upachara, 'naivedyam');
    s.recognizer.tap(const Vec(0.5, 0.5));
    // archana: one flower per name, the next name is spoken
    expect(s.step.upachara, 'archana');
    expect(s.nameIndex, 0);
    s.recognizer.tap(const Vec(0.5, 0.5));
    expect(s.nameIndex, 1);
    expect(voice.log.last, repo.stotras['ayyappa_saranam_108']!.lines[1].script);
    s.recognizer.tap(const Vec(0.5, 0.5));
    s.recognizer.tap(const Vec(0.5, 0.5));
    expect(s.step.upachara, 'aarti');
    // Do this for me performs just this step, then waits again
    s.performForMe();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(s.step.upachara, 'namaskaram');
    expect(s.recognizer, isA<TapRecognizer>());
    s.dispose();
  });

  test('watch mode highlights each archana name and closes the curtains with Harivarasanam', () async {
    final d = repo.deities['ayyappa']!;
    final bridge = SanctumBridge();
    final s = PoojaSession(
      deity: d, vidhanam: d.pooja('nitya5')!.withArchana(archana(repo, 12)), mode: PoojaMode.watch,
      bridge: bridge, lang: 'en', timeScale: 0.0005,
    );
    final seen = <int>{};
    s.addListener(() {
      if (s.step.upachara == 'archana') seen.add(s.nameIndex);
    });
    await s.start();
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (s.status != PoojaStatus.completed && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(s.status, PoojaStatus.completed);
    expect(seen.length, 12);
    final log = bridge.sentLog.join('\n');
    expect(log, contains('playClosingAudio'));
    expect(log.indexOf('playClosingAudio'), lessThan(log.indexOf('curtainsClose')));
    s.dispose();
  });

  test('switching to Watch mid-step, pause and resume', () async {
    final d = repo.deities['ayyappa']!;
    final s = PoojaSession(deity: d, vidhanam: d.pooja('nitya5')!, mode: PoojaMode.handsOn, bridge: SanctumBridge(), lang: 'en', timeScale: 0.001);
    await s.start();
    s.pause();
    expect(s.status, PoojaStatus.paused);
    expect(NotificationGate.allowNotifications, isFalse, reason: 'a paused pooja is still a pooja');
    s.resume();
    s.switchMode(PoojaMode.watch);
    expect(s.recognizer, isA<NoopRecognizer>());
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (s.status != PoojaStatus.completed && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(s.status, PoojaStatus.completed);
    expect(NotificationGate.allowNotifications, isTrue);
    s.dispose();
  });
}
