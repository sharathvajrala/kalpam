import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> makeState(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final repo = await PackRepository.load((p) => File(p).readAsString());
  final fixed = DateTime.parse('2026-11-27T07:30:00+05:30');
  return AppState(repo: repo, prefs: await SharedPreferences.getInstance(), clock: () => fixed);
}

void main() {
  testWidgets('onboarding: language, god, city, about -> Today', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final state = await t.runAsync(() => makeState({}));
    await t.pumpWidget(KalpamApp(state: state!));
    await t.pumpAndSettle();
    expect(state.hasCity, isFalse);
    await t.tap(find.text('English'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('god-ayyappa')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('city-vijayawada')));
    await t.pumpAndSettle();
    expect(state.cityId, 'vijayawada');
    await t.tap(find.text('Begin'));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('flagship-hero')), findsOneWidget);
    expect(find.byKey(const ValueKey('my-god'), skipOffstage: false), findsOneWidget);
    expect(find.textContaining('48 days to Makara Jyothi'), findsOneWidget);
    await t.scrollUntilVisible(find.byKey(const ValueKey('panchang-strip')), 300);
    expect(find.byKey(const ValueKey('panchang-strip')), findsOneWidget);
  });

  testWidgets('no city set: Hyderabad fallback and a Set-your-city prompt', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final state = await t.runAsync(() => makeState({'onboarded': true, 'lang': 'en'}));
    await t.pumpWidget(KalpamApp(state: state!));
    await t.pumpAndSettle();
    expect(state.city.id, 'hyderabad');
    expect(find.text('Set your city'), findsOneWidget);
    expect(find.text('Subhodayam'), findsOneWidget);
  });
}
