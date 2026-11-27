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
    // name + gotram are required: Next stays disabled until both are filled
    final next = find.byKey(const ValueKey('onboarding-next'));
    expect(t.widget<FilledButton>(next).onPressed, isNull);
    await t.enterText(find.byKey(const ValueKey('field-name')), 'Sharath');
    await t.pump();
    expect(t.widget<FilledButton>(next).onPressed, isNull);
    await t.enterText(find.byKey(const ValueKey('field-gotra')), 'Bharadwaja');
    await t.pump();
    await t.tap(next);
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('remind-morning')), findsOneWidget);
    await t.tap(find.text('Begin'));
    await t.pumpAndSettle();
    expect(state.devoteeName, 'Sharath');
    expect(state.gotra, 'Bharadwaja');
    expect(state.morningReminder!.hhmm, '05:30');
    expect(state.eveningReminder!.hhmm, '18:30');
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
    final state = await t.runAsync(() => makeState({'onboarded': true, 'lang': 'en', 'gpsLat': 17.0, 'gpsLon': 78.0}));
    await t.pumpWidget(KalpamApp(state: state!));
    await t.pumpAndSettle();
    expect(state.city.id, 'hyderabad');
    expect(find.text('Set your city'), findsOneWidget);
    expect(find.text('Subhodayam'), findsOneWidget);
    final prefs = await t.runAsync(SharedPreferences.getInstance);
    expect(prefs!.containsKey('gpsLat'), isFalse, reason: 'coordinates are never kept');
  });

  test('family profiles switch whose Sankalpam is spoken', () async {
    final state = await makeState({'onboarded': true, 'lang': 'te', 'city': 'tirupati'});
    final a = await state.saveFamilyProfile(name: 'శరత్', gotra: 'భారద్వాజ');
    final b = await state.saveFamilyProfile(name: 'లక్ష్మి', gotra: 'కాశ్యప', janmaNakshatra: 4);
    expect(state.activeProfile!.id, a);
    String spoken() => state.sankalpam(deity: state.deity, vratam: null).full;
    expect(spoken(), contains('శరత్'));
    await state.switchProfile(b);
    expect(spoken(), contains('లక్ష్మి'));
    expect(spoken(), contains('కాశ్యప గోత్రస్య'));
    expect(spoken(), contains('తిరుపతి'));
    await state.removeFamilyProfile(b);
    expect(state.activeProfile!.id, a);
    await state.removeFamilyProfile(a);
    expect(state.profiles, hasLength(1), reason: 'one profile always remains');
  });

  test('export contains only the approved fields; delete-all wipes everything', () async {
    final state = await makeState({'onboarded': true, 'lang': 'en', 'city': 'chennai'});
    await state.saveFamilyProfile(name: 'Sharath', gotra: 'Bharadwaja', janmaNakshatra: 5);
    await state.startDeeksha('ayyappa_mandala', DateTime.utc(2026, 11, 16), 41);
    final json = state.exportAll();
    expect(json, contains('"Chennai"'));
    expect(json, contains('Bharadwaja'));
    expect(json, contains('ayyappa_mandala'));
    for (final banned in ['lat', 'lon', 'phone', 'email', 'dob', 'contacts']) {
      expect(json.toLowerCase(), isNot(contains('"$banned')), reason: banned);
    }
    await state.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
    expect(state.onboarded, isFalse);
    expect(state.profiles, isEmpty);
    expect(state.deekshas, isEmpty);
    expect(state.hasCity, isFalse);
  });
}
