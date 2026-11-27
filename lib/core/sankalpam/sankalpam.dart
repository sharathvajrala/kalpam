/// Generates the spoken / displayed Sankalpam for a pooja.
///
/// Follows the traditional Telugu Smarta template
/// (… Shalivahana Shake, <Samvatsara> Nama Samvatsare, <Ayana>, <Ritu>,
/// <Masa> Mase, <Paksha>, <Tithi>, <Vasara>, <Nakshatra> …). Pending pandit
/// review (ASSETS_TODO.md text.sankalpam.template).
library;

import '../content/localized.dart';
import '../panchangam/panchangam.dart';

class SankalpamInput {
  const SankalpamInput({
    required this.day,
    required this.devoteeName,
    this.gotra,
    required this.deityName,
    required this.purpose,
    this.familyIncluded = true,
  });

  final PanchangDay day;
  final String devoteeName;
  final String? gotra;
  final LocalizedText deityName;
  final LocalizedText purpose;
  final bool familyIncluded;
}

class SankalpamText {
  const SankalpamText(this.lines);

  /// Ordered phrases, each a unit the voice guide speaks and the UI
  /// highlights.
  final List<String> lines;
  String get full => lines.join(' ');
}

class SankalpamGenerator {
  const SankalpamGenerator();

  SankalpamText generate(SankalpamInput i, String lang) {
    final d = i.day;
    final te = lang == 'te';
    String s(LocalizedText t) => t.of(te ? 'te' : 'en');
    final name = i.devoteeName.trim().isEmpty
        ? (te ? 'భక్తుడనైన నేను' : 'I, your devotee')
        : i.devoteeName.trim();
    final gotra = (i.gotra ?? '').trim();
    final city = s(d.city.name);

    if (te) {
      return SankalpamText([
        'మమ ఉపాత్త సమస్త దురితక్షయద్వారా శ్రీ పరమేశ్వర ప్రీత్యర్థం,',
        'శుభే శోభనే ముహూర్తే, శ్రీ మహావిష్ణోరాజ్ఞయా ప్రవర్తమానస్య,',
        'అద్య బ్రహ్మణః ద్వితీయ పరార్థే, శ్వేతవరాహ కల్పే, వైవస్వత మన్వంతరే, కలియుగే ప్రథమ పాదే,',
        'జంబూద్వీపే భరతవర్షే భరతఖండే, $city నగరే,',
        'శ్రీ ${s(d.samvatsara)} నామ సంవత్సరే, ${s(d.ayana)}, ${s(d.ritu)} ఋతౌ,',
        '${s(d.masa)} మాసే, ${s(d.tithi.paksha)}, ${s(d.tithi.name)} తిథౌ, ${s(d.vasara)}, ${s(d.nakshatra.name)} నక్షత్రే,',
        if (gotra.isNotEmpty) '$gotra గోత్రస్య, $name నామధేయస్య,' else '$name నామధేయస్య,',
        if (i.familyIncluded) 'సకుటుంబస్య క్షేమ స్థైర్య విజయ ఆయురారోగ్య ఐశ్వర్యాభివృద్ధ్యర్థం,',
        'శ్రీ ${s(i.deityName)} ప్రీత్యర్థం, ${s(i.purpose)},',
        'యథాశక్తి పూజాం కరిష్యే.',
      ]);
    }
    return SankalpamText([
      'To remove all my faults and to please the Supreme Lord,',
      'at this auspicious moment, by the command of Sri Maha Vishnu,',
      'in the second half of Brahma\'s life, in the Shveta Varaha Kalpa, Vaivasvata Manvantara, first quarter of Kali Yuga,',
      'in Jambudvipa, Bharata Varsha, in the city of $city,',
      'in the year ${s(d.samvatsara)}, ${s(d.ayana)}, ${s(d.ritu)} ritu,',
      'in the month of ${s(d.masa)}, ${s(d.tithi.paksha)}, on ${s(d.tithi.name)} tithi, ${s(d.vasara)}, under ${s(d.nakshatra.name)} nakshatra,',
      gotra.isNotEmpty ? '$name of $gotra gotra,' : '$name,',
      if (i.familyIncluded) 'for the well-being, health, success and prosperity of my family,',
      'to please ${s(i.deityName)}, ${s(i.purpose)},',
      'I perform this pooja to the best of my ability.',
    ]);
  }
}
