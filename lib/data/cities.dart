import '../core/content/localized.dart';
import '../core/panchangam/panchangam.dart';

/// Offline city list. Fixed-offset zones only in Phase A (no DST) — see
/// ASSUMPTIONS.md. GPS lookup picks the nearest entry.
const cities = <City>[
  City(id: 'hyderabad', name: LocalizedText.bi('Hyderabad', 'హైదరాబాదు'), lat: 17.385, lon: 78.4867, utcOffsetMin: 330),
  City(id: 'vijayawada', name: LocalizedText.bi('Vijayawada', 'విజయవాడ'), lat: 16.5062, lon: 80.648, utcOffsetMin: 330),
  City(id: 'visakhapatnam', name: LocalizedText.bi('Visakhapatnam', 'విశాఖపట్నం'), lat: 17.6868, lon: 83.2185, utcOffsetMin: 330),
  City(id: 'tirupati', name: LocalizedText.bi('Tirupati', 'తిరుపతి'), lat: 13.6288, lon: 79.4192, utcOffsetMin: 330),
  City(id: 'guntur', name: LocalizedText.bi('Guntur', 'గుంటూరు'), lat: 16.3067, lon: 80.4365, utcOffsetMin: 330),
  City(id: 'warangal', name: LocalizedText.bi('Warangal', 'వరంగల్'), lat: 17.9689, lon: 79.5941, utcOffsetMin: 330),
  City(id: 'rajahmundry', name: LocalizedText.bi('Rajahmundry', 'రాజమండ్రి'), lat: 17.0005, lon: 81.804, utcOffsetMin: 330),
  City(id: 'kakinada', name: LocalizedText.bi('Kakinada', 'కాకినాడ'), lat: 16.9891, lon: 82.2475, utcOffsetMin: 330),
  City(id: 'nellore', name: LocalizedText.bi('Nellore', 'నెల్లూరు'), lat: 14.4426, lon: 79.9865, utcOffsetMin: 330),
  City(id: 'kurnool', name: LocalizedText.bi('Kurnool', 'కర్నూలు'), lat: 15.8281, lon: 78.0373, utcOffsetMin: 330),
  City(id: 'karimnagar', name: LocalizedText.bi('Karimnagar', 'కరీంనగర్'), lat: 18.4386, lon: 79.1288, utcOffsetMin: 330),
  City(id: 'nizamabad', name: LocalizedText.bi('Nizamabad', 'నిజామాబాద్'), lat: 18.6725, lon: 78.094, utcOffsetMin: 330),
  City(id: 'anantapur', name: LocalizedText.bi('Anantapur', 'అనంతపురం'), lat: 14.6819, lon: 77.6006, utcOffsetMin: 330),
  City(id: 'kadapa', name: LocalizedText.bi('Kadapa', 'కడప'), lat: 14.4673, lon: 78.8242, utcOffsetMin: 330),
  City(id: 'chennai', name: LocalizedText.bi('Chennai', 'చెన్నై'), lat: 13.0827, lon: 80.2707, utcOffsetMin: 330),
  City(id: 'bengaluru', name: LocalizedText.bi('Bengaluru', 'బెంగళూరు'), lat: 12.9716, lon: 77.5946, utcOffsetMin: 330),
  City(id: 'kochi', name: LocalizedText.bi('Kochi', 'కొచ్చి'), lat: 9.9312, lon: 76.2673, utcOffsetMin: 330),
  City(id: 'thiruvananthapuram', name: LocalizedText.bi('Thiruvananthapuram', 'తిరువనంతపురం'), lat: 8.5241, lon: 76.9366, utcOffsetMin: 330),
  City(id: 'sabarimala', name: LocalizedText.bi('Sabarimala', 'శబరిమల'), lat: 9.4346, lon: 77.0814, utcOffsetMin: 330),
  City(id: 'madurai', name: LocalizedText.bi('Madurai', 'మదురై'), lat: 9.9252, lon: 78.1198, utcOffsetMin: 330),
  City(id: 'coimbatore', name: LocalizedText.bi('Coimbatore', 'కోయంబత్తూరు'), lat: 11.0168, lon: 76.9558, utcOffsetMin: 330),
  City(id: 'mumbai', name: LocalizedText.bi('Mumbai', 'ముంబై'), lat: 19.076, lon: 72.8777, utcOffsetMin: 330),
  City(id: 'pune', name: LocalizedText.bi('Pune', 'పూణే'), lat: 18.5204, lon: 73.8567, utcOffsetMin: 330),
  City(id: 'delhi', name: LocalizedText.bi('New Delhi', 'న్యూఢిల్లీ'), lat: 28.6139, lon: 77.209, utcOffsetMin: 330),
  City(id: 'kolkata', name: LocalizedText.bi('Kolkata', 'కోల్‌కతా'), lat: 22.5726, lon: 88.3639, utcOffsetMin: 330),
  City(id: 'varanasi', name: LocalizedText.bi('Varanasi', 'వారణాసి'), lat: 25.3176, lon: 82.9739, utcOffsetMin: 330),
  City(id: 'singapore', name: LocalizedText.bi('Singapore', 'సింగపూర్'), lat: 1.3521, lon: 103.8198, utcOffsetMin: 480, tzName: 'Asia/Singapore'),
  City(id: 'kuala_lumpur', name: LocalizedText.bi('Kuala Lumpur', 'కౌలాలంపూర్'), lat: 3.139, lon: 101.6869, utcOffsetMin: 480, tzName: 'Asia/Kuala_Lumpur'),
  City(id: 'dubai', name: LocalizedText.bi('Dubai', 'దుబాయ్'), lat: 25.2048, lon: 55.2708, utcOffsetMin: 240, tzName: 'Asia/Dubai'),
  City(id: 'doha', name: LocalizedText.bi('Doha', 'దోహా'), lat: 25.2854, lon: 51.531, utcOffsetMin: 180, tzName: 'Asia/Qatar'),
];

City cityById(String? id) => cities.firstWhere((c) => c.id == id, orElse: () => cities.first);
