import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/features/sannidhanam/pooja_screen.dart';
import 'package:kalpam/features/sannidhanam/pooja_setup_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Sannidhanam: Watch Mode with archana runs to the gentle completion', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    PoojaScreen.debugTimeScale = 0.002;
    PoojaScreen.debugUseSensors = false;
    SharedPreferences.setMockInitialValues({
      'onboarded': true, 'lang': 'en', 'deity': 'ayyappa', 'city': 'hyderabad',
      'profiles': '[{"id":"p1","name":"Sharath","gotra":"Bharadwaja"}]', 'activeProfile': 'p1',
    });
    final repo = await t.runAsync(() => PackRepository.load((p) => File(p).readAsString()));
    final fixed = DateTime.parse('2026-11-27T07:30:00+05:30');
    final state = AppState(repo: repo!, prefs: await SharedPreferences.getInstance(), clock: () => fixed);
    await t.pumpWidget(KalpamApp(state: state));
    await t.pump(const Duration(milliseconds: 100));
    KalpamShell.go(1);
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('mode-watch')), findsOneWidget);
    await t.tap(find.byKey(const Key('mode-watch')));
    await t.pump();
    final list = find.descendant(of: find.byType(PoojaSetupBody), matching: find.byType(Scrollable)).first;
    await t.scrollUntilVisible(find.byKey(const Key('archana-short')), 200, scrollable: list);
    await t.tap(find.byKey(const Key('archana-short')));
    await t.pump();
    expect(find.textContaining('Sharath'), findsWidgets, reason: 'Sankalpam preview names the devotee');
    await t.scrollUntilVisible(find.byKey(const Key('begin-pooja')), 200, scrollable: list);
    await t.drag(list, const Offset(0, -300));
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.byKey(const Key('begin-pooja')));
    for (var i = 0; i < 400 && find.byKey(const Key('pooja-done')).evaluate().isEmpty; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Pooja complete'), findsOneWidget);
    expect(find.textContaining('points', findRichText: true), findsNothing);
    await t.tap(find.byKey(const Key('pooja-done')));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('begin-pooja')), findsOneWidget);
  });
}
