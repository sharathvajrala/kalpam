import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Spoken guidance (Sankalpam, step prompts, Elder Mode readouts).
///
/// Uses the device TTS engine (Telugu "te-IN" / English "en-IN") until the
/// commissioned voice-guide recordings land (ASSETS_TODO.md
/// audio.voiceguide.*). Never throws: if TTS is unavailable the UI still shows
/// the text.
class VoiceGuide {
  VoiceGuide._();
  static final VoiceGuide instance = VoiceGuide._();

  FlutterTts? _tts;
  final ValueNotifier<bool> speaking = ValueNotifier(false);
  bool enabled = true;

  /// Test hook: record instead of speaking.
  @visibleForTesting
  static List<String>? spokenLog;

  Future<FlutterTts?> _engine() async {
    if (_tts != null) return _tts;
    try {
      final t = FlutterTts();
      t.setStartHandler(() => speaking.value = true);
      t.setCompletionHandler(() => speaking.value = false);
      t.setCancelHandler(() => speaking.value = false);
      t.setErrorHandler((_) => speaking.value = false);
      await t.setSpeechRate(0.42);
      _tts = t;
    } catch (_) {
      _tts = null;
    }
    return _tts;
  }

  Future<void> speak(String text, {required String lang}) async {
    if (!enabled || text.trim().isEmpty) return;
    if (spokenLog != null) {
      spokenLog!.add(text);
      return;
    }
    try {
      final t = await _engine();
      if (t == null) return;
      await t.stop();
      await t.setLanguage(lang == 'te' ? 'te-IN' : 'en-IN');
      await t.speak(text);
    } catch (_) {
      speaking.value = false;
    }
  }

  Future<void> stop() async {
    speaking.value = false;
    if (spokenLog != null) return;
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
