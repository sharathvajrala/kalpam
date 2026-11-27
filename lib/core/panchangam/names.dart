import '../content/localized.dart';

typedef L = LocalizedText;

/// 1..15 within a paksha. Index 15 is Pournami (shukla) / Amavasya (krishna).
const tithiNames = <L>[
  L.bi('Prathama', 'పాడ్యమి'), L.bi('Dwitiya', 'విదియ'), L.bi('Tritiya', 'తదియ'),
  L.bi('Chaturthi', 'చవితి'), L.bi('Panchami', 'పంచమి'), L.bi('Shashti', 'షష్ఠి'),
  L.bi('Saptami', 'సప్తమి'), L.bi('Ashtami', 'అష్టమి'), L.bi('Navami', 'నవమి'),
  L.bi('Dashami', 'దశమి'), L.bi('Ekadashi', 'ఏకాదశి'), L.bi('Dwadashi', 'ద్వాదశి'),
  L.bi('Trayodashi', 'త్రయోదశి'), L.bi('Chaturdashi', 'చతుర్దశి'),
];
const pournami = L.bi('Pournami', 'పౌర్ణమి');
const amavasya = L.bi('Amavasya', 'అమావాస్య');
const shuklaPaksha = L.bi('Shukla Paksha', 'శుక్ల పక్షం');
const krishnaPaksha = L.bi('Krishna Paksha', 'కృష్ణ పక్షం');

const nakshatraNames = <L>[
  L.bi('Ashwini', 'అశ్విని'), L.bi('Bharani', 'భరణి'), L.bi('Krittika', 'కృత్తిక'),
  L.bi('Rohini', 'రోహిణి'), L.bi('Mrigashira', 'మృగశిర'), L.bi('Ardra', 'ఆర్ద్ర'),
  L.bi('Punarvasu', 'పునర్వసు'), L.bi('Pushyami', 'పుష్యమి'), L.bi('Ashlesha', 'ఆశ్లేష'),
  L.bi('Magha', 'మఖ'), L.bi('Purva Phalguni', 'పుబ్బ'), L.bi('Uttara Phalguni', 'ఉత్తర'),
  L.bi('Hasta', 'హస్త'), L.bi('Chitra', 'చిత్త'), L.bi('Swati', 'స్వాతి'),
  L.bi('Vishakha', 'విశాఖ'), L.bi('Anuradha', 'అనూరాధ'), L.bi('Jyeshtha', 'జ్యేష్ఠ'),
  L.bi('Moola', 'మూల'), L.bi('Purva Ashadha', 'పూర్వాషాఢ'), L.bi('Uttara Ashadha', 'ఉత్తరాషాఢ'),
  L.bi('Shravanam', 'శ్రవణం'), L.bi('Dhanishta', 'ధనిష్ఠ'), L.bi('Shatabhisham', 'శతభిషం'),
  L.bi('Purva Bhadra', 'పూర్వాభాద్ర'), L.bi('Uttara Bhadra', 'ఉత్తరాభాద్ర'), L.bi('Revati', 'రేవతి'),
];

const yogaNames = <L>[
  L.bi('Vishkambha', 'విష్కంభ'), L.bi('Priti', 'ప్రీతి'), L.bi('Ayushman', 'ఆయుష్మాన్'),
  L.bi('Saubhagya', 'సౌభాగ్య'), L.bi('Shobhana', 'శోభన'), L.bi('Atiganda', 'అతిగండ'),
  L.bi('Sukarma', 'సుకర్మ'), L.bi('Dhriti', 'ధృతి'), L.bi('Shula', 'శూల'),
  L.bi('Ganda', 'గండ'), L.bi('Vriddhi', 'వృద్ధి'), L.bi('Dhruva', 'ధ్రువ'),
  L.bi('Vyaghata', 'వ్యాఘాత'), L.bi('Harshana', 'హర్షణ'), L.bi('Vajra', 'వజ్ర'),
  L.bi('Siddhi', 'సిద్ధి'), L.bi('Vyatipata', 'వ్యతీపాత'), L.bi('Variyan', 'వరీయాన్'),
  L.bi('Parigha', 'పరిఘ'), L.bi('Shiva', 'శివ'), L.bi('Siddha', 'సిద్ధ'),
  L.bi('Sadhya', 'సాధ్య'), L.bi('Shubha', 'శుభ'), L.bi('Shukla', 'శుక్ల'),
  L.bi('Brahma', 'బ్రహ్మ'), L.bi('Indra', 'ఐంద్ర'), L.bi('Vaidhriti', 'వైధృతి'),
];

const _movableKaranas = <L>[
  L.bi('Bava', 'బవ'), L.bi('Balava', 'బాలవ'), L.bi('Kaulava', 'కౌలవ'),
  L.bi('Taitila', 'తైతుల'), L.bi('Gara', 'గరజి'), L.bi('Vanija', 'వణిజ'),
  L.bi('Vishti', 'విష్టి'),
];

/// Karana for half-tithi number 1..60.
L karanaName(int halfTithi) {
  if (halfTithi == 1) return const L.bi('Kimstughna', 'కింస్తుఘ్న');
  if (halfTithi == 58) return const L.bi('Shakuni', 'శకుని');
  if (halfTithi == 59) return const L.bi('Chatushpada', 'చతుష్పాద');
  if (halfTithi == 60) return const L.bi('Naga', 'నాగవ');
  return _movableKaranas[(halfTithi - 2) % 7];
}

const masaNames = <L>[
  L.bi('Chaitra', 'చైత్రం'), L.bi('Vaishakha', 'వైశాఖం'), L.bi('Jyeshtha', 'జ్యేష్ఠం'),
  L.bi('Ashadha', 'ఆషాఢం'), L.bi('Shravana', 'శ్రావణం'), L.bi('Bhadrapada', 'భాద్రపదం'),
  L.bi('Ashwayuja', 'ఆశ్వయుజం'), L.bi('Karthika', 'కార్తీకం'), L.bi('Margashira', 'మార్గశిరం'),
  L.bi('Pushya', 'పుష్యం'), L.bi('Magha', 'మాఘం'), L.bi('Phalguna', 'ఫాల్గుణం'),
];

const rashiNames = <L>[
  L.bi('Mesha', 'మేషం'), L.bi('Vrishabha', 'వృషభం'), L.bi('Mithuna', 'మిథునం'),
  L.bi('Karkataka', 'కర్కాటకం'), L.bi('Simha', 'సింహం'), L.bi('Kanya', 'కన్య'),
  L.bi('Tula', 'తుల'), L.bi('Vrischika', 'వృశ్చికం'), L.bi('Dhanus', 'ధనుస్సు'),
  L.bi('Makara', 'మకరం'), L.bi('Kumbha', 'కుంభం'), L.bi('Meena', 'మీనం'),
];

/// ISO weekday 1=Mon..7=Sun.
const weekdayNames = <L>[
  L.bi('Monday', 'సోమవారం'), L.bi('Tuesday', 'మంగళవారం'), L.bi('Wednesday', 'బుధవారం'),
  L.bi('Thursday', 'గురువారం'), L.bi('Friday', 'శుక్రవారం'), L.bi('Saturday', 'శనివారం'),
  L.bi('Sunday', 'ఆదివారం'),
];

/// Sankalpam vasara names (Indu vasare…), ISO weekday order.
const vasaraSanskrit = <L>[
  L.bi('Indu Vasare', 'ఇందు వాసరే'), L.bi('Bhauma Vasare', 'భౌమ వాసరే'),
  L.bi('Saumya Vasare', 'సౌమ్య వాసరే'), L.bi('Guru Vasare', 'గురు వాసరే'),
  L.bi('Bhrigu Vasare', 'భృగు వాసరే'), L.bi('Sthira Vasare', 'స్థిర వాసరే'),
  L.bi('Bhanu Vasare', 'భాను వాసరే'),
];

const rituNames = <L>[
  L.bi('Vasanta', 'వసంత'), L.bi('Grishma', 'గ్రీష్మ'), L.bi('Varsha', 'వర్ష'),
  L.bi('Sharad', 'శరద్'), L.bi('Hemanta', 'హేమంత'), L.bi('Shishira', 'శిశిర'),
];

const _samEn = [
  'Prabhava', 'Vibhava', 'Shukla', 'Pramoduta', 'Prajotpatti', 'Angirasa',
  'Shrimukha', 'Bhava', 'Yuva', 'Dhatu', 'Ishvara', 'Bahudhanya', 'Pramathi',
  'Vikrama', 'Vrisha', 'Chitrabhanu', 'Svabhanu', 'Tarana', 'Parthiva', 'Vyaya',
  'Sarvajit', 'Sarvadhari', 'Virodhi', 'Vikriti', 'Khara', 'Nandana', 'Vijaya',
  'Jaya', 'Manmatha', 'Durmukhi', 'Hevilambi', 'Vilambi', 'Vikari', 'Sharvari',
  'Plava', 'Shubhakritu', 'Shobhakritu', 'Krodhi', 'Vishvavasu', 'Parabhava',
  'Plavanga', 'Kilaka', 'Saumya', 'Sadharana', 'Virodhikritu', 'Paridhavi',
  'Pramadicha', 'Ananda', 'Rakshasa', 'Nala', 'Pingala', 'Kalayukti',
  'Siddharthi', 'Raudri', 'Durmati', 'Dundubhi', 'Rudhirodgari', 'Raktakshi',
  'Krodhana', 'Akshaya',
];
const _samTe = [
  'ప్రభవ', 'విభవ', 'శుక్ల', 'ప్రమోదూత', 'ప్రజోత్పత్తి', 'ఆంగీరస', 'శ్రీముఖ', 'భావ',
  'యువ', 'ధాత', 'ఈశ్వర', 'బహుధాన్య', 'ప్రమాది', 'విక్రమ', 'వృష', 'చిత్రభాను',
  'స్వభాను', 'తారణ', 'పార్థివ', 'వ్యయ', 'సర్వజిత్', 'సర్వధారి', 'విరోధి', 'వికృతి',
  'ఖర', 'నందన', 'విజయ', 'జయ', 'మన్మథ', 'దుర్ముఖి', 'హేవిళంబి', 'విళంబి', 'వికారి',
  'శార్వరి', 'ప్లవ', 'శుభకృత్', 'శోభకృత్', 'క్రోధి', 'విశ్వావసు', 'పరాభవ', 'ప్లవంగ',
  'కీలక', 'సౌమ్య', 'సాధారణ', 'విరోధికృత్', 'పరీధావి', 'ప్రమాదీచ', 'ఆనంద', 'రాక్షస',
  'నల', 'పింగళ', 'కాళయుక్తి', 'సిద్ధార్థి', 'రౌద్రి', 'దుర్మతి', 'దుందుభి',
  'రుధిరోద్గారి', 'రక్తాక్షి', 'క్రోధన', 'అక్షయ',
];

L samvatsaraName(int index0) =>
    LocalizedText({'en': _samEn[index0 % 60], 'te': _samTe[index0 % 60]});
