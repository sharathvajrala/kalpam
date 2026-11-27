import '../core/voice/voice_guide.dart';
import 'pooja_session.dart';

/// Sends pooja guidance to the device voice guide in the user's language.
class TtsVoice implements VoicePort {
  TtsVoice(this.lang);
  final String lang;
  @override
  void speak(String text) => VoiceGuide.instance.speak(text, lang: lang);
  @override
  void stop() => VoiceGuide.instance.stop();
}
