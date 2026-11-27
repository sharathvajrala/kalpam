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

  @override
  String get useMyLocation => 'నా ప్రస్తుత స్థానం వాడండి';

  @override
  String get gpsFailed => 'స్థానం తెలియలేదు. దయచేసి మీ నగరం వెతకండి.';

  @override
  String get cityWhy =>
      'సూర్యోదయం, తిథి, రాహు కాలం, మీ సంకల్పం ఈ నగరానికి లెక్కించబడతాయి.';

  @override
  String get cityNotSet => 'మీ నగరం ఎంచుకోండి';

  @override
  String get gotraHelp => 'మీ సంకల్పంలో చెప్పబడుతుంది';

  @override
  String get janmaNakshatram => 'జన్మ నక్షత్రం';

  @override
  String get notSet => 'ఎంచుకోలేదు';

  @override
  String get reminders => 'రోజువారీ గుర్తుచేతలు';

  @override
  String get remindersDesc =>
      'ఉదయ, సాయంత్ర పూజకు సున్నితమైన గుర్తుచేత. పూజ జరుగుతున్నప్పుడు ఎప్పుడూ రాదు.';

  @override
  String get morningReminder => 'ఉదయ పూజ';

  @override
  String get eveningReminder => 'సాయంత్ర దీపం';

  @override
  String get familyProfiles => 'కుటుంబ సభ్యులు';

  @override
  String get familyProfilesDesc =>
      'సంకల్పంలో ఎవరి పేరు, గోత్రం చెప్పాలో ఎంచుకోండి.';

  @override
  String get addProfile => 'కుటుంబ సభ్యుని చేర్చండి';

  @override
  String get editProfile => 'వివరాలు మార్చండి';

  @override
  String get remove => 'తొలగించు';

  @override
  String get cancel => 'రద్దు';

  @override
  String sankalpamFor(String name) {
    return '$name గారి సంకల్పం';
  }

  @override
  String get yourData => 'మీ సమాచారం';

  @override
  String get yourDataDesc =>
      'అన్నీ ఈ ఫోన్‌లోనే ఉంటాయి. ఖాతా తెరిస్తేనే సింక్ అవుతుంది.';

  @override
  String get exportData => 'నా సమాచారం ఎగుమతి';

  @override
  String get deleteAll => 'నా సమాచారం మొత్తం తొలగించు';

  @override
  String get deleteAllConfirm =>
      'ఇది మీ ప్రొఫైళ్ళు, ట్రాకర్లు, అమరికలను ఈ ఫోన్ నుండి శాశ్వతంగా తొలగిస్తుంది.';

  @override
  String get poojaHow => 'పూజ ఎలా చేయాలనుకుంటున్నారు?';

  @override
  String get archana => 'అర్చన';

  @override
  String get archanaDesc => 'స్వామి ప్రతి నామానికి ఒక పుష్పం';

  @override
  String get archanaOff => 'వద్దు';

  @override
  String archanaShort(int n) {
    return 'సంక్షిప్తం · $n';
  }

  @override
  String archanaFull(int n) {
    return 'పూర్తి · $n';
  }

  @override
  String nameOf(int n, int total) {
    return '$totalలో $nవ నామం';
  }

  @override
  String countOf(int n, int total) {
    return '$totalలో $n';
  }

  @override
  String get beingPerformed => 'మీ కోసం జరుగుతోంది';

  @override
  String get backToToday => 'నేటికి తిరిగి';

  @override
  String sanctumAfterReview(String god) {
    return 'అయ్యప్ప సన్నిధానం సమీక్ష తర్వాత $god సన్నిధానం తెరుచుకుంటుంది. అయ్యప్ప సన్నిధానం ఇప్పుడే తెరిచి ఉంది.';
  }

  @override
  String get liquidWater => 'జలం';

  @override
  String get liquidMilk => 'పాలు';

  @override
  String get liquidPanchamrutam => 'పంచామృతం';

  @override
  String get liquidGhee => 'నెయ్యి';

  @override
  String get hintTap => 'సన్నిధానాన్ని తాకండి';

  @override
  String get hintCircle => 'హారతి పళ్ళెం స్వామి చుట్టూ సవ్యదిశలో తిప్పండి';

  @override
  String get hintShower => 'పుష్పాలు చల్లడానికి పైకి స్వైప్ చేయండి';

  @override
  String get hintPour => 'పోయడానికి కిందికి లాగండి, లేదా ఫోన్ వంచండి';

  @override
  String get hintSwipeDown =>
      'కొబ్బరికాయ కొట్టడానికి గట్టిగా కిందికి స్వైప్ చేయండి';

  @override
  String get hintShake => 'గంట మోగించడానికి ఫోన్ ఊపండి, లేదా తాకండి';

  @override
  String get hintBlow => 'శంఖం ఊదడానికి నొక్కి పట్టుకోండి';

  @override
  String get hintWalk => 'ప్రదక్షిణకు ఎడమ కుడి స్వైప్ చేయండి';

  @override
  String get hintArchana => 'పుష్పం సమర్పించడానికి తాకండి లేదా పైకి విసరండి';

  @override
  String get chooseByDay => 'రోజును బట్టి ఎంచుకోండి';

  @override
  String get chooseByDayDesc =>
      'సోమ శివుడు · మంగళ హనుమాన్ · బుధ అయ్యప్ప · గురు సాయిబాబా · శుక్ర లక్ష్మి · శని వేంకటేశ్వరుడు · ఆది సూర్యుడు';

  @override
  String get godByDay => 'నేటి దైవం · వారం ప్రకారం';

  @override
  String get morningRitual => 'ఉదయ నిత్య అర్చన';

  @override
  String get eveningRitual => 'సాయంత్ర దీపారాధన';

  @override
  String get dailyRituals => 'నిత్య ఆరాధన';

  @override
  String atSunrise(String time) {
    return 'సూర్యోదయం $time';
  }

  @override
  String atSunset(String time) {
    return 'సూర్యాస్తమయం $time';
  }

  @override
  String get doneToday => 'నేడు పూర్తయింది';

  @override
  String archanaFullN(int n) {
    return 'పూర్తి · $n నామాలు';
  }

  @override
  String archanaShortN(int n) {
    return 'సంక్షిప్తం · $n నామాలు';
  }

  @override
  String get suprabhatam => 'సుప్రభాతం';

  @override
  String get deepam => 'దీపం';

  @override
  String get aarti => 'హారతి';

  @override
  String get closingPrayer => 'ముగింపు ప్రార్థన';

  @override
  String get arghyam => 'సూర్య అర్ఘ్యం';

  @override
  String get arghyamDesc =>
      'సూర్యునికి అభిముఖంగా దోసిలితో మూడుసార్లు జలం సమర్పించి నమస్కరించండి.';

  @override
  String get deepamDesc => 'దేవుని ముందు దీపం వెలిగించండి.';

  @override
  String get aartiDesc => 'హారతిని మూడుసార్లు సవ్యదిశలో తిప్పండి.';

  @override
  String get closingDesc => 'నమస్కరించి నేటి పూజను ముగించండి.';

  @override
  String get sankalpamDesc =>
      'కుడి అరచేతిలో అక్షతలు పట్టుకుని నేటి సంకల్పం చెప్పండి.';

  @override
  String get offerFlower => 'పుష్పం సమర్పించండి';

  @override
  String get markDone => 'అయింది';

  @override
  String get performInSannidhanam => 'సన్నిధానంలో చేయండి';

  @override
  String get ritualComplete => 'ఆరాధన సంపూర్ణం';

  @override
  String get eveningAnchor => 'సాయంత్ర గుర్తుచేత';

  @override
  String get anchorTime => 'నా సమయం';

  @override
  String get anchorSunset => 'స్థానిక సూర్యాస్తమయం';

  @override
  String get byGod => 'దేవుని వారీగా';

  @override
  String get byCategory => 'వర్గాల వారీగా';

  @override
  String get catSahasranamam => 'సహస్రనామం';

  @override
  String get catAshtottaram => 'అష్టోత్తరం';

  @override
  String get catChalisa => 'చాలీసా';

  @override
  String get catStotram => 'స్తోత్రం';

  @override
  String get catSuprabhatam => 'సుప్రభాతం';

  @override
  String get catSaranam => 'శరణం';

  @override
  String get catKeertana => 'కీర్తన';

  @override
  String get catMantram => 'మంత్రం';

  @override
  String get catNamavali => 'నామావళి';

  @override
  String get catNamajapam => 'నామజపం';

  @override
  String linesCount(int n) {
    return '$n పంక్తులు';
  }

  @override
  String get sampleShort => 'నమూనా';

  @override
  String lineOf(int n, int total) {
    return '$totalలో $nవ పంక్తి';
  }

  @override
  String repeatOf(int n, int total) {
    return '$totalలో $nవ సారి';
  }

  @override
  String get tapToCount => 'లెక్కించడానికి తాకండి';

  @override
  String malasCount(int n) {
    return '$n మాలలు';
  }

  @override
  String get countRepeats => 'ప్రతి పునరావృతాన్ని మాలలో లెక్కించు';

  @override
  String get voiceReads =>
      'రికార్డింగ్ త్వరలో. అప్పటి వరకు వాయిస్ గైడ్ ప్రతి పంక్తి చదువుతుంది.';

  @override
  String get japaTarget => 'లక్ష్యం';

  @override
  String get sourceLabel => 'మూలం';

  @override
  String get chantComplete => 'పారాయణం సంపూర్ణం';

  @override
  String get playAll => 'అన్నీ వినండి';

  @override
  String get loopPlaylist => 'ప్లేలిస్ట్ మళ్ళీ మళ్ళీ';

  @override
  String get upNext => 'తదుపరి';

  @override
  String aboutMin(int n) {
    return '~$n నిమి';
  }

  @override
  String bhajanOf(int n, int total) {
    return '$totalలో $nవ భజన';
  }

  @override
  String get lyricsSample => 'సాహిత్యం ధృవీకరణ కావాలి';

  @override
  String get offlineLyrics => 'సాహిత్యం ఆఫ్‌లైన్‌లోనూ';

  @override
  String nSubhodayamTitle(String god) {
    return 'శుభోదయం · $god';
  }

  @override
  String nSunLine(String dusk, String rise) {
    return 'సూర్యోదయం $rise · సూర్యాస్తమయం $dusk';
  }

  @override
  String nTodayIs(String name) {
    return 'నేడు: $name';
  }

  @override
  String nMorningBody(String god) {
    return '$god ఉదయపు అర్చన సిద్ధంగా ఉంది, మీకు వీలైనప్పుడు.';
  }

  @override
  String get nEveningTitle => 'సంధ్యా సమయం';

  @override
  String nEveningBody(String god, String time) {
    return 'సాయంత్రం దీపం వెలిగించి $godకు హారతి ఇవ్వండి. సూర్యాస్తమయం $time.';
  }

  @override
  String nTomorrowTitle(String name) {
    return 'రేపు: $name';
  }

  @override
  String get nTomorrowBody =>
      'ఈ రాత్రే పూజా సామగ్రి సిద్ధం చేసుకోండి. జాబితా కోసం తాకండి.';

  @override
  String nFestivalBody(String god) {
    return 'నేటి $god ప్రత్యేక పూజ, అర్చన సిద్ధంగా ఉన్నాయి.';
  }

  @override
  String nPeakBody(String time) {
    return 'నేడు ప్రత్యేక పూజ, $timeకు ప్రత్యక్ష హారతి.';
  }

  @override
  String nInviteTitle(int days, String name) {
    return '$days రోజుల్లో $name ప్రారంభం';
  }

  @override
  String get nInviteBody => 'సంకల్పం చేసి, భక్తులందరితో కలిసి ఆచరించండి.';

  @override
  String nClosingTitle(String name) {
    return 'ఉద్యాపనం · $name';
  }

  @override
  String get nClosingBody => 'ఉద్యాపన పూజతో, కృతజ్ఞతతో ఉత్సవాన్ని ముగించండి.';

  @override
  String nChecklistSummary(String items) {
    return 'నేడు: $items';
  }

  @override
  String nHalfwayTitle(int day, int total) {
    return 'సగం పూర్తి · $totalలో $dayవ రోజు';
  }

  @override
  String nFinalTitle(int day, int total) {
    return 'చివరి రోజు · $totalలో $dayవ రోజు';
  }

  @override
  String nFinalBody(String vratam) {
    return 'నేడు ఉద్యాపనం. కృతజ్ఞతతో మీ $vratam పూర్తి చేయండి.';
  }

  @override
  String nResumeTitle(int day, int total) {
    return 'స్వాగతం · $totalలో $dayవ రోజు';
  }

  @override
  String get nResumeBody =>
      'ప్రతి రోజూ ఒక కొత్త సమర్పణ. మీకు వీలైనప్పుడు కొనసాగించండి.';

  @override
  String get nNudgeTitle => 'సాయంత్ర నియమాలు';

  @override
  String nNudgeBody(int count) {
    return 'నేటి జాబితాలో $count మిగిలి ఉన్నాయి, మీకు వీలైనప్పుడు.';
  }

  @override
  String get notifications => 'నోటిఫికేషన్లు';

  @override
  String get notificationsDesc =>
      'ఈ ఫోన్‌లోనే షెడ్యూల్ అయ్యే సున్నితమైన గుర్తింపులు. పూజ జరుగుతున్నప్పుడు ఏదీ రాదు.';

  @override
  String get nTypeSubhodayam => 'సూర్యోదయాన శుభోదయం పంచాంగం';

  @override
  String get nTypeMorning => 'ఉదయపు పూజ గుర్తింపు';

  @override
  String get nTypeEvening => 'సాయంత్ర సంధ్యా గుర్తింపు';

  @override
  String get nTypeFestivals => 'పండుగలు, ప్రత్యేక దినాలు';

  @override
  String get nTypeVratam => 'మాల, వ్రత దినచర్య';

  @override
  String get quietHours => 'నిశ్శబ్ద సమయం';

  @override
  String get fromTime => 'నుండి';

  @override
  String get toTime => 'వరకు';

  @override
  String get subhodayamTime => 'శుభోదయం సమయం';

  @override
  String get atSunriseShort => 'సూర్యోదయానికి';

  @override
  String minAfterSunrise(int n) {
    return '+$n నిమి';
  }

  @override
  String get comingUp => 'రాబోయేవి';

  @override
  String get nothingScheduled => 'రాబోయే వారంలో ఏదీ లేదు.';

  @override
  String get exactTitle => 'సమయానికి గుర్తింపులు';

  @override
  String get exactDesc =>
      'బ్యాటరీ ఆదా కోసం Android గుర్తింపులను ఆలస్యం చేయవచ్చు. శుభోదయం సూర్యోదయానికే రావాలంటే ఖచ్చిత సమయం అనుమతించండి. ఇంకా ఆలస్యమైతే Android అమరికల్లో కల్పం బ్యాటరీ వినియోగాన్ని Unrestricted గా మార్చండి. ఏ విధంగానైనా కల్పం పూర్తిగా పనిచేస్తుంది.';

  @override
  String get allowExact => 'ఖచ్చిత సమయం అనుమతించండి';

  @override
  String get allowNotifications => 'నోటిఫికేషన్లు అనుమతించండి';

  @override
  String get gotIt => 'సరే';

  @override
  String get joinDaysTitle => 'ఎన్ని రోజులు ఆచరిస్తారు?';

  @override
  String joinDaysStandard(int n) {
    return 'సంప్రదాయ సంఖ్య $n రోజులు.';
  }

  @override
  String nDays(int n) {
    return '$n రోజులు';
  }

  @override
  String get startsOn => 'ప్రారంభం';

  @override
  String get checkInTime => 'రోజువారీ గుర్తింపు సమయం';

  @override
  String get beginSankalpam => 'సంకల్పం ప్రారంభించండి';

  @override
  String get elderTodayPooja => 'నేటి పూజ';

  @override
  String get elderBeginPooja => 'నేటి పూజ ప్రారంభించండి';

  @override
  String elderWatchFor(String god) {
    return 'దర్శన మోడ్ · $god';
  }

  @override
  String elderGuidedFor(String god) {
    return 'వాయిస్ మార్గదర్శనంతో · $god';
  }

  @override
  String get listenToday => 'నేటి వివరాలు వినండి';

  @override
  String get speakCommand => 'ఆదేశం చెప్పండి';

  @override
  String get listening => 'వింటున్నాను…';

  @override
  String heard(String name) {
    return 'విన్నది: $name';
  }

  @override
  String get voiceHelp =>
      'చెప్పండి: పూజ, ఉదయం, సాయంత్రం, పంచాంగం, జపం, భజనలు, నేడు, లేదా ఆపు.';

  @override
  String get voiceNotUnderstood => 'క్షమించండి, అర్థం కాలేదు.';

  @override
  String get micUnavailable =>
      'ఈ పరికరంలో వాయిస్ ఆదేశాలు అందుబాటులో లేవు. ప్రతి బటన్ కూడా చదివి వినిపిస్తుంది.';

  @override
  String digestGreeting(String greeting, String name) {
    return '$greeting, $name.';
  }

  @override
  String digestDay(String nakshatram, String tithi, String weekday) {
    return 'నేడు $weekday: $tithi, $nakshatram నక్షత్రం.';
  }

  @override
  String digestSun(String dusk, String rise) {
    return 'సూర్యోదయం $rise, సూర్యాస్తమయం $dusk.';
  }

  @override
  String digestGod(String god) {
    return 'నేటి దైవం: $god.';
  }

  @override
  String digestPending(String ritual) {
    return 'మీ $ritual మీకు వీలైనప్పుడు సిద్ధంగా ఉంది.';
  }

  @override
  String get digestAllDone => 'నేటి పూజలు పూర్తయ్యాయి. శుభాశీస్సులు.';

  @override
  String get elderModeOnboard => 'పెద్ద అక్షరాలు, వాయిస్ మార్గదర్శనం కావాలా?';
}
