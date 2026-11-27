import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/app/app.dart';
import 'package:kalpam/app/app_state.dart';
import 'package:kalpam/core/content/pack_repository.dart';
import 'package:kalpam/core/rituals/daily_rituals.dart';
import 'package:kalpam/core/voice/voice_guide.dart';
import 'package:kalpam/features/bhajans/bhajan_player_screen.dart';
import 'package:kalpam/features/grantham/chant_player_screen.dart';
import 'package:kalpam/features/rituals/ritual_screen.dart';
import 'package:kalpam/features/sannidhanam/pooja_setup_screen.dart';
import 'package:kalpam/features/settings/settings_screen.dart';
import 'package:kalpam/features/today/panchangam_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Elder Mode audit: every Phase A screen on a small phone (360 x 740 dp)
/// with Elder Mode on, in both languages. Any layout overflow fails.
void main() {
  for (final lang in ['te', 'en']) {
    testWidgets('Elder Mode, small phone, $lang: no overflow on any screen', (
      t,
    ) async {
      t.view.physicalSize = const Size(1080, 2220);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      VoiceGuide.spokenLog = [];
      SharedPreferences.setMockInitialValues({
        'onboarded': true,
        'lang': lang,
        'deity': 'ayyappa',
        'city': 'visakhapatnam',
        'elder': true,
        'remindMorning': '05:30',
        'remindEvening': '18:30',
        'notifPrefs': '{"permissionAsked":true}',
        'profiles':
            '[{"id":"p1","name":"Venkata Subrahmanyam","gotra":"Srivatsa"}]',
        'activeProfile': 'p1',
      });
      final repo = await t.runAsync(
        () => PackRepository.load((p) => File(p).readAsString()),
      );
      final fixed = DateTime.parse('2026-11-27T06:30:00+05:30');
      final state = AppState(
        repo: repo!,
        prefs: await SharedPreferences.getInstance(),
        clock: () => fixed,
      );

      final problems = <String>[];
      final old = FlutterError.onError;
      var where = '';
      FlutterError.onError = (d) {
        final at =
            RegExp(r'(lib/[a-z_/]+\.dart:\d+)')
                .firstMatch(d.toString())
                ?.group(1) ??
            '';
        problems.add(
          '$where: ${d.exceptionAsString().split('\n').first} [$at]',
        );
      };
      addTearDown(() => FlutterError.onError = old);

      Future<void> scrollAll() async {
        for (final s in find.byType(Scrollable).evaluate().toList()) {
          final st = (s as StatefulElement).state as ScrollableState;
          if (st.axisDirection != AxisDirection.down) continue;
          for (
            var i = 0;
            i < 12 && st.position.pixels < st.position.maxScrollExtent;
            i++
          ) {
            st.position.jumpTo(
              (st.position.pixels + 500).clamp(0, st.position.maxScrollExtent),
            );
            await t.pump(const Duration(milliseconds: 50));
          }
        }
      }

      for (var tab = 0; tab < 5; tab++) {
        where = 'tab $tab';
        debugPrint('AUDIT $where');
        KalpamShell.tabIndex.value = tab;
        if (tab == 0) {
          await t.pumpWidget(KalpamApp(state: state));
        }
        await t.pump(const Duration(seconds: 1));
        await scrollAll();
      }
      KalpamShell.tabIndex.value = 0;
      await t.pump(const Duration(milliseconds: 300));
      // Tap targets on Today: Android's 48 dp guideline, and text contrast.
      final handle = t.ensureSemantics();
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(textContrastGuideline));
      handle.dispose();

      final screens = <String, Widget>{
        'settings': const SettingsScreen(),
        'panchangam': const PanchangamScreen(),
        'pooja setup': const PoojaSetupScreen(deityId: 'ayyappa'),
        'ritual morning': const RitualScreen(slot: RitualSlot.morning),
        'ritual evening': const RitualScreen(slot: RitualSlot.evening),
        'chant player': const ChantPlayerScreen(
          stotraId: 'vishnu_sahasranamam',
        ),
        'bhajan player': BhajanPlayerScreen(bhajanId: repo.bhajans.keys.first),
      };
      for (final e in screens.entries) {
        where = e.key;
        debugPrint('AUDIT $where');
        KalpamApp.navigatorKey.currentState!.push(
          MaterialPageRoute(builder: (_) => e.value),
        );
        await t.pump(const Duration(seconds: 1));
        await scrollAll();
        KalpamApp.navigatorKey.currentState!.pop();
        await t.pump(const Duration(milliseconds: 500));
      }
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
      // ignore: avoid_print
      debugPrint(problems.isEmpty ? 'clean' : problems.toSet().join('\n'));
      FlutterError.onError = old;
      expect(problems.toSet(), isEmpty);
    });
  }
}
