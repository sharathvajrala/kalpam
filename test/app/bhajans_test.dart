import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/core/voice/voice_guide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Bhajans: season playlist plays all, advances to the next bhajan, flags unverified lyrics', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    VoiceGuide.spokenLog = [];
    SharedPreferences.setMockInitialValues({'onboarded': true, 'lang': 'en', 'deity': 'venkateswara', 'city': 'hyderabad'});
    final repo = await t.runAsync(() => PackRepository.load((p) => File(p).readAsString()));
    final fixed = DateTime.parse('2026-11-28T06:30:00+05:30');
    final state = AppState(repo: repo!, prefs: await SharedPreferences.getInstance(), clock: () => fixed);
    KalpamShell.tabIndex.value = 3;
    await t.pumpWidget(KalpamApp(state: state));
    await t.pumpAndSettle();

    expect(find.byKey(const ValueKey('season-playlist')), findsOneWidget, reason: 'Mandala season playlist leads');
    expect(find.byKey(const ValueKey('bhajan-govinda_namalu')), findsOneWidget, reason: 'my god (Venkateswara) next');
    await t.tap(find.byKey(const ValueKey('season-play-all')));
    await t.pumpAndSettle();
    expect(find.text('Bhajan 1 of 3'), findsOneWidget);
    expect(find.text('Lyrics pending verification'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('bhajan-play')));
    for (var i = 0; i < 400 && find.text('Bhajan 2 of 3').evaluate().isEmpty; i++) {
      await t.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Bhajan 2 of 3'), findsOneWidget, reason: 'auto-advance');
    expect(VoiceGuide.spokenLog, isNotEmpty);
    await t.tap(find.byKey(const ValueKey('bhajan-play')));
    await t.pumpAndSettle();
    VoiceGuide.spokenLog = null;
  });
}
