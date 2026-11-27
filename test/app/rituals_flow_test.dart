import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/core/rituals/daily_rituals.dart';
import 'package:kalpam/core/voice/voice_guide.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Day God Thursday: Sai Baba leads, morning Nitya Archana completes and shows done', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    VoiceGuide.spokenLog = [];
    SharedPreferences.setMockInitialValues({
      'onboarded': true, 'lang': 'en', 'deity': 'day', 'city': 'vijayawada',
      'profiles': '[{"id":"p1","name":"Sharath","gotra":"Bharadwaja"}]', 'activeProfile': 'p1',
    });
    final repo = await t.runAsync(() => PackRepository.load((p) => File(p).readAsString()));
    final fixed = DateTime.parse('2026-11-26T06:30:00+05:30'); // Thursday
    final state = AppState(repo: repo!, prefs: await SharedPreferences.getInstance(), clock: () => fixed);
    KalpamShell.tabIndex.value = 0;
    await t.pumpWidget(KalpamApp(state: state));
    await t.pumpAndSettle();

    await t.scrollUntilVisible(find.byKey(const ValueKey('my-god')), 300);
    expect(find.text("Today's God · by the day"), findsOneWidget);
    expect(find.text('Sri Shirdi Sai Baba'), findsWidgets);
    await t.scrollUntilVisible(find.byKey(const ValueKey('rituals-card')), 300);
    expect(find.text('Morning Nitya Archana'), findsOneWidget);

    await t.tap(find.byKey(const ValueKey('ritual-morning')));
    await t.pumpAndSettle();
    expect(find.textContaining('Sai Baba'), findsWidgets);
    expect(find.textContaining('shraddha and saburi'), findsOneWidget, reason: 'Sankalpam names the god and purpose');

    for (var guard = 0; guard < 60 && find.byKey(const Key('ritual-complete')).evaluate().isEmpty; guard++) {
      final offer = find.byKey(const Key('offer-flower'));
      final next = find.byKey(const Key('ritual-next'));
      final target = offer.evaluate().isNotEmpty ? offer : next;
      await t.ensureVisible(target);
      await t.tap(target);
      await t.pumpAndSettle();
    }
    expect(find.byKey(const Key('ritual-complete')), findsOneWidget);
    expect(state.ritualDone(RitualSlot.morning), isTrue);
    expect(VoiceGuide.spokenLog, contains('ఓం సాయినాథాయ నమః'));
    VoiceGuide.spokenLog = null;
  });
}
