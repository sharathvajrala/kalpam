import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'core/content/pack_repository.dart';

/// Optional fixed date for demos / screenshots:
/// `flutter run --dart-define=KALPAM_NOW=2026-12-20T07:30:00+05:30`
const _fixedNow = String.fromEnvironment('KALPAM_NOW');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = await PackRepository.load(rootBundle.loadString);
  final prefs = await SharedPreferences.getInstance();
  final fixed = _fixedNow.isEmpty ? null : DateTime.parse(_fixedNow);
  final state = AppState(repo: repo, prefs: prefs, clock: fixed == null ? null : () => fixed);
  runApp(KalpamApp(state: state));
}
