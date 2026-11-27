import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Listens for one short spoken command (Elder Mode). The microphone is
/// opened only when the user taps the mic button, never in the background,
/// and never during a pooja.
abstract class VoiceListener {
  /// Whether speech recognition works on this device (asks for the mic
  /// permission the first time).
  Future<bool> available();

  /// Listens once and returns what was heard ('' when nothing was heard).
  Future<String> listenOnce({required String lang});

  Future<void> cancel();

  /// The app-wide listener; tests replace it.
  static VoiceListener instance = SpeechVoiceListener();
}

class SpeechVoiceListener implements VoiceListener {
  final _stt = SpeechToText();
  bool? _ok;

  @override
  Future<bool> available() async {
    if (_ok != null) return _ok!;
    try {
      _ok = await _stt.initialize();
    } catch (_) {
      _ok = false;
    }
    return _ok!;
  }

  @override
  Future<String> listenOnce({required String lang}) async {
    if (!await available()) return '';
    final done = Completer<String>();
    var last = '';
    void finish() {
      if (!done.isCompleted) done.complete(last);
    }

    try {
      await _stt.listen(
        onResult: (SpeechRecognitionResult r) {
          last = r.recognizedWords;
          if (r.finalResult) finish();
        },
        listenOptions: SpeechListenOptions(
          localeId: lang == 'te' ? 'te_IN' : 'en_IN',
          listenFor: const Duration(seconds: 6),
          pauseFor: const Duration(seconds: 2),
          partialResults: true,
          cancelOnError: true,
        ),
      );
    } catch (e) {
      debugPrint('voice listen failed: $e');
      finish();
    }
    // Safety net: never wait longer than the listening window.
    return done.future.timeout(const Duration(seconds: 9), onTimeout: () => last);
  }

  @override
  Future<void> cancel() async {
    try {
      await _stt.cancel();
    } catch (_) {}
  }
}
