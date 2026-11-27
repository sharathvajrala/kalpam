// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'కల్పం';

  @override
  String get tagline => 'మీ సంకల్పం — ప్రతి రోజు, ప్రతి వ్రతం';

  @override
  String get tabToday => 'నేడు';

  @override
  String get tabSannidhanam => 'సన్నిధానం';

  @override
  String get tabGrantham => 'గ్రంథం';

  @override
  String get tabBhajans => 'భజనలు';

  @override
  String get tabGroups => 'బృందాలు';

  @override
  String get subhodayam => 'శుభోదయం';

  @override
  String get subhaSayantram => 'శుభ సాయంత్రం';

  @override
  String get myGod => 'నా ఇష్టదైవం';

  @override
  String get dailyPooja => 'నిత్య పూజ';

  @override
  String get chanting => 'జపం';

  @override
  String get joinSankalpam => 'సంకల్పం చేయండి';

  @override
  String get continueLabel => 'కొనసాగించండి';

  @override
  String dayOf(int day, int total) {
    return '$total రోజులలో $dayవ రోజు';
  }

  @override
  String daysToPeak(int days, String peak) {
    return '$peakకు $days రోజులు';
  }

  @override
  String peakToday(String peak) {
    return 'నేడే $peak';
  }

  @override
  String startsIn(int days) {
    return '$days రోజుల్లో ప్రారంభం';
  }

  @override
  String get seasonClosing => 'ఉత్సవం సంపూర్ణం — ఉద్యాపనం';

  @override
  String nextFlagship(String name) {
    return 'తదుపరి: $name';
  }

  @override
  String get todayKatha => 'నేటి కథ';

  @override
  String get todayBhajan => 'నేటి భజన';

  @override
  String get seasonPooja => 'ఉత్సవ పూజ';

  @override
  String get samagriChecklist => 'పూజా సామగ్రి';

  @override
  String get panchangam => 'పంచాంగం';

  @override
  String get tithi => 'తిథి';

  @override
  String get nakshatram => 'నక్షత్రం';

  @override
  String get yogam => 'యోగం';

  @override
  String get karanam => 'కరణం';

  @override
  String get masam => 'మాసం';

  @override
  String get samvatsaram => 'సంవత్సరం';

  @override
  String get sunrise => 'సూర్యోదయం';

  @override
  String get sunset => 'సూర్యాస్తమయం';

  @override
  String get rahuKalam => 'రాహు కాలం';

  @override
  String get yamagandam => 'యమగండం';

  @override
  String get gulikaKalam => 'గుళిక కాలం';

  @override
  String until(String time) {
    return '$time వరకు';
  }

  @override
  String get todayVratam => 'నేటి వ్రతం';

  @override
  String get weekdayGod => 'నేటి దైవం';

  @override
  String get join => 'చేరండి';

  @override
  String get joined => 'చేరారు';

  @override
  String get city => 'నగరం';

  @override
  String get chooseCity => 'మీ నగరం ఎంచుకోండి';

  @override
  String get search => 'వెతకండి';

  @override
  String get settings => 'అమరికలు';

  @override
  String get language => 'భాష';

  @override
  String get elderMode => 'పెద్దల మోడ్';

  @override
  String get elderModeDesc => 'పెద్ద అక్షరాలు, వాయిస్ మార్గదర్శనం, దర్శన మోడ్';

  @override
  String get yourName => 'మీ పేరు';

  @override
  String get gotra => 'గోత్రం';

  @override
  String get save => 'భద్రపరచు';

  @override
  String get chooseGod => 'మీ ఇష్టదైవాన్ని ఎంచుకోండి';

  @override
  String get welcome => 'కల్పానికి స్వాగతం';

  @override
  String get begin => 'ప్రారంభించండి';

  @override
  String get skip => 'దాటవేయి';

  @override
  String get optional => 'ఐచ్ఛికం';

  @override
  String get next => 'తదుపరి';

  @override
  String get aboutYou => 'మీ సంకల్పం కోసం';

  @override
  String get aboutYouDesc =>
      'మీ పేరు, గోత్రం, నగరం ప్రతి సంకల్పంలో చెప్పబడతాయి. ఇవి ఈ ఫోన్‌లోనే ఉంటాయి.';

  @override
  String get modeHandsOn => 'స్వయంగా పూజ';

  @override
  String get modeHandsOnDesc => 'ప్రతి ఉపచారం మీరే చేయండి';

  @override
  String get modeWatch => 'దర్శన మోడ్';

  @override
  String get modeWatchDesc => 'ఆలయ దీపారాధనలా పూజ మీ కోసం జరుగుతుంది';

  @override
  String get chooseLength => 'పూజ నిడివి';

  @override
  String minutes(int n) {
    return '$n నిమి';
  }

  @override
  String get beginPooja => 'పూజ ప్రారంభించండి';

  @override
  String stepOf(int n, int total) {
    return '$totalలో $nవ ఉపచారం';
  }

  @override
  String get doItForMe => 'నా కోసం చేయండి';

  @override
  String get pause => 'ఆపు';

  @override
  String get resume => 'కొనసాగించు';

  @override
  String get endPooja => 'పూజ ముగించు';

  @override
  String get poojaComplete => 'పూజ సంపూర్ణం';

  @override
  String poojaCompleteMsg(String god) {
    return '$god మీకు, మీ కుటుంబానికి ఆశీస్సులు అందించుగాక.';
  }

  @override
  String get yourSankalpam => 'మీ సంకల్పం';

  @override
  String get listen => 'వినండి';

  @override
  String get stop => 'ఆపు';

  @override
  String get placeholderSanctum => 'నమూనా సన్నిధానం — 3D విగ్రహం త్వరలో';

  @override
  String get recordingSoon => 'రికార్డింగ్ త్వరలో';

  @override
  String get parayanamToday => 'నేటి పారాయణం';

  @override
  String get allStotras => 'అన్ని స్తోత్రాలు';

  @override
  String get poojaVidhanams => 'పూజా విధానాలు';

  @override
  String get sung => 'గానం';

  @override
  String get learnMode => 'నేర్చుకోండి';

  @override
  String get repeatLine => 'పునరావృతం';

  @override
  String get japaCounter => 'జపం';

  @override
  String get meaning => 'అర్థం';

  @override
  String get reset => 'మళ్ళీ';

  @override
  String malaDone(int count) {
    return 'మాల పూర్తి · $count';
  }

  @override
  String get sampleText => 'నమూనా పాఠం — పూర్తి పాఠం త్వరలో';

  @override
  String get seasonPlaylist => 'ఉత్సవ భజనలు';

  @override
  String get lyrics => 'సాహిత్యం';

  @override
  String get allBhajans => 'అన్ని భజనలు';

  @override
  String get familyCircles => 'కుటుంబ బృందాలు';

  @override
  String get familyCirclesDesc =>
      'కలిసి వ్రతం / మాల చేయండి, ఒకరి రోజుల లెక్క ఒకరు చూడండి.';

  @override
  String get guruswamyGroups => 'గురుస్వామి బృందాలు';

  @override
  String get guruswamyDesc =>
      'దీక్ష రోజులు, ప్రకటనలు, యాత్ర తేదీ, వర్చువల్ క్యూ జాబితా, ఖర్చుల పంపకం.';

  @override
  String get groupsOpening =>
      'బృందాలు మకరవిళక్కు (జనవరి 14) నుండి. పూజ, జపం, ట్రాకర్లకు ఖాతా అవసరం లేదు.';

  @override
  String get notifyMe => 'బృందాలు ప్రారంభమైనప్పుడు తెలియజేయండి';

  @override
  String get katha => 'కథ';

  @override
  String get samagri => 'సామగ్రి';

  @override
  String get sankalpam => 'సంకల్పం';

  @override
  String get vidhanam => 'విధానం';

  @override
  String get tracker => 'ట్రాకర్';

  @override
  String get udyapanam => 'ఉద్యాపనం';

  @override
  String get fasting => 'ఉపవాస నియమాలు';

  @override
  String get rules => 'దీక్ష నియమాలు';

  @override
  String get morning => 'ఉదయం';

  @override
  String get evening => 'సాయంత్రం';

  @override
  String get irumudi => 'ఇరుముడి';

  @override
  String get irumudiFront => 'ముందు ముడి';

  @override
  String get irumudiBack => 'వెనుక ముడి';

  @override
  String get maladharana => 'మాలధారణ మంత్రం';

  @override
  String get startDeeksha => 'నా దీక్ష ప్రారంభించండి';

  @override
  String get startDate => 'ప్రారంభ తేదీ';

  @override
  String get deekshaDays => 'రోజులు';

  @override
  String deekshaDay(int n) {
    return '$nవ రోజు';
  }

  @override
  String streak(int n) {
    return 'వరుసగా $n రోజులు';
  }

  @override
  String daysLeft(int n) {
    return 'ఇంకా $n రోజులు';
  }

  @override
  String get sabarimalaLive => 'శబరిమల లైవ్';

  @override
  String get nadaOpen => 'నడ తెరిచి ఉంది';

  @override
  String get nadaClosed => 'నడ మూసి ఉంది';

  @override
  String nowPooja(String name) {
    return 'ఇప్పుడు: $name';
  }

  @override
  String nextPooja(String name, String time) {
    return 'తదుపరి: $timeకు $name';
  }

  @override
  String get scheduleNote =>
      'సాధారణ ఉత్సవ సమయాలు. అధికారిక దేవస్వం ప్రకటనలు తప్పక చూడండి.';

  @override
  String get virtualQueue => 'అధికారిక సైట్‌లో వర్చువల్ క్యూ బుక్ చేయండి';

  @override
  String get noVip => 'కల్పం దర్శనం అమ్మదు. అధికారిక సైట్‌లో బుకింగ్ ఉచితం.';

  @override
  String get annadanam => 'మీ దగ్గర అన్నదానం';

  @override
  String get templesNear => 'అయ్యప్ప ఆలయాలు, పడి పూజలు';

  @override
  String get feedPending =>
      'ధృవీకరించిన నిర్వాహకులు ప్రచురించగానే మీ నగర వివరాలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get beginUdyapanam => 'ఉద్యాపనం ప్రారంభించండి';

  @override
  String get certificate => 'సంపూర్ణ ధృవపత్రం';

  @override
  String get share => 'పంచుకోండి';

  @override
  String chapter(int n) {
    return '$nవ అధ్యాయం';
  }

  @override
  String certificateText(int days, String name, String vratam) {
    return '$name గారు $days రోజుల $vratam సంపూర్ణం చేశారు.';
  }

  @override
  String get notStarted => 'ప్రారంభించలేదు';

  @override
  String get openVratam => 'వ్రతం చూడండి';

  @override
  String get voiceGuide => 'వాయిస్ మార్గదర్శనం';

  @override
  String get devotee => 'భక్తుడు';

  @override
  String get allGods => 'అందరు దేవతలు';
}
