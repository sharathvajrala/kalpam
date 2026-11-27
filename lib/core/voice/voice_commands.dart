/// Elder Mode voice navigation: spoken words -> one app action.
///
/// Pure Dart and deliberately forgiving: it looks for a keyword anywhere in
/// what the recognizer heard, in English or Telugu ("evening pooja",
/// "సాయంత్రం పూజ", "play bhajans"). More specific commands are checked first,
/// so "evening pooja" opens the evening ritual rather than the pooja.
library;

enum VoiceCommand { stop, help, settings, morning, evening, panchangam, pooja, chanting, bhajans, sannidhanam, groups, today }

class VoiceCommands {
  const VoiceCommands._();

  static const _keywords = <VoiceCommand, List<String>>{
    VoiceCommand.stop: ['stop', 'quiet', 'silence', 'ఆపు', 'ఆపండి', 'ఆగు'],
    VoiceCommand.help: ['help', 'what can', 'సహాయం', 'సహాయ'],
    VoiceCommand.settings: ['setting', 'అమరిక', 'సెట్టింగ్'],
    VoiceCommand.morning: ['morning', 'archana', 'suprabhat', 'ఉదయ', 'అర్చన', 'సుప్రభాత'],
    VoiceCommand.evening: ['evening', 'sandhya', 'deepam', 'aarti', 'arati', 'harathi', 'సాయంత్ర', 'సంధ్య', 'దీపం', 'హారతి'],
    VoiceCommand.panchangam: ['panchang', 'tithi', 'nakshatra', 'rahu', 'పంచాంగ', 'తిథి', 'నక్షత్ర', 'రాహు'],
    VoiceCommand.pooja: ['pooja', 'puja', 'worship', 'పూజ'],
    VoiceCommand.chanting: ['chant', 'grantham', 'stotra', 'sahasranam', 'chalisa', 'japa', 'జపం', 'గ్రంథ', 'స్తోత్ర', 'సహస్రనామ', 'చాలీసా'],
    VoiceCommand.bhajans: ['bhajan', 'song', 'keertan', 'kirtan', 'music', 'భజన', 'పాట', 'కీర్తన'],
    VoiceCommand.sannidhanam: ['sannidhanam', 'sanctum', 'temple', 'సన్నిధాన', 'గుడి', 'ఆలయ'],
    VoiceCommand.groups: ['group', 'family', 'బృంద', 'కుటుంబ'],
    VoiceCommand.today: ['today', 'home', 'back', 'నేడు', 'ఈరోజు', 'హోమ్', 'వెనుక'],
  };

  /// The command in [heard], or null when nothing matched.
  static VoiceCommand? parse(String heard) {
    final s = heard.toLowerCase().trim();
    if (s.isEmpty) return null;
    for (final c in VoiceCommand.values) {
      if (_keywords[c]!.any(s.contains)) return c;
    }
    return null;
  }
}
