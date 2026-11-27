import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/core/voice/voice_guide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Grantham: library leads with the core set; chant-along plays, repeats and counts japa', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    VoiceGuide.spokenLog = [];
    SharedPreferences.setMockInitialValues({'onboarded': true, 'lang': 'en', 'deity': 'ayyappa', 'city': 'hyderabad'});
    final repo = await t.runAsync(() => PackRepository.load((p) => File(p).readAsString()));
    final fixed = DateTime.parse('2026-11-28T06:30:00+05:30'); // Saturday: Vishnu Sahasranamam + Hanuman Chalisa
    final state = AppState(repo: repo!, prefs: await SharedPreferences.getInstance(), clock: () => fixed);
    KalpamShell.tabIndex.value = 2;
    await t.pumpWidget(KalpamApp(state: state));
    await t.pumpAndSettle();

    expect(find.text('Parayanam today'), findsOneWidget);
    expect(find.byKey(const ValueKey('stotra-hanuman_chalisa')), findsWidgets);
    expect(find.text('Sample'), findsWidgets, reason: 'unverified texts are flagged');
    expect(find.text('Swamy Ayyappa'), findsOneWidget, reason: 'your god leads the library');

    await t.tap(find.byKey(const ValueKey('stotra-ayyappa_saranam_108')).last);
    await t.pumpAndSettle();
    expect(find.textContaining('Recording coming soon'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('repeat-11')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('chant-play')));
    for (var i = 0; i < 40; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('Repeat '), findsOneWidget);
    expect(find.textContaining('Line 1 of 12'), findsOneWidget, reason: 'still repeating the first line');
    expect(VoiceGuide.spokenLog!.first, 'స్వామియే శరణం అయ్యప్ప');
    await t.tap(find.byKey(const ValueKey('chant-play'))); // pause
    await t.pump();

    await t.scrollUntilVisible(find.byKey(const ValueKey('japa-tap')), 300);
    await t.drag(find.byType(Scrollable).last, const Offset(0, -400));
    await t.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await t.tap(find.byKey(const ValueKey('japa-tap')));
    }
    await t.pump();
    expect(find.text('5'), findsOneWidget);
    await t.pageBack();
    await t.pumpAndSettle();
    expect(state.japaCount('ayyappa_saranam_108'), 5, reason: 'japa count persists');
    VoiceGuide.spokenLog = null;
  });
}
