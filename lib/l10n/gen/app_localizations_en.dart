// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kalpam';

  @override
  String get tagline => 'Your sankalpam — every day, every vratam';

  @override
  String get tabToday => 'Today';

  @override
  String get tabSannidhanam => 'Sannidhanam';

  @override
  String get tabGrantham => 'Grantham';

  @override
  String get tabBhajans => 'Bhajans';

  @override
  String get tabGroups => 'Groups';

  @override
  String get subhodayam => 'Subhodayam';

  @override
  String get subhaSayantram => 'Subha Sayantram';

  @override
  String get myGod => 'My God';

  @override
  String get dailyPooja => 'Daily Pooja';

  @override
  String get chanting => 'Chanting';

  @override
  String get joinSankalpam => 'Join the Sankalpam';

  @override
  String get continueLabel => 'Continue';

  @override
  String dayOf(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String daysToPeak(int days, String peak) {
    return '$days days to $peak';
  }

  @override
  String peakToday(String peak) {
    return '$peak is today';
  }

  @override
  String startsIn(int days) {
    return 'Begins in $days days';
  }

  @override
  String get seasonClosing => 'Season complete — Udyapanam';

  @override
  String nextFlagship(String name) {
    return 'Next: $name';
  }

  @override
  String get todayKatha => 'Today\'s Katha';

  @override
  String get todayBhajan => 'Today\'s Bhajan';

  @override
  String get seasonPooja => 'Season Pooja';

  @override
  String get samagriChecklist => 'Samagri checklist';

  @override
  String get panchangam => 'Panchangam';

  @override
  String get tithi => 'Tithi';

  @override
  String get nakshatram => 'Nakshatram';

  @override
  String get yogam => 'Yogam';

  @override
  String get karanam => 'Karanam';

  @override
  String get masam => 'Masam';

  @override
  String get samvatsaram => 'Samvatsaram';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get rahuKalam => 'Rahu Kalam';

  @override
  String get yamagandam => 'Yamagandam';

  @override
  String get gulikaKalam => 'Gulika Kalam';

  @override
  String until(String time) {
    return 'until $time';
  }

  @override
  String get todayVratam => 'Today\'s Vratam';

  @override
  String get weekdayGod => 'Today\'s God';

  @override
  String get join => 'Join';

  @override
  String get joined => 'Joined';

  @override
  String get city => 'City';

  @override
  String get chooseCity => 'Choose your city';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get elderMode => 'Elder Mode';

  @override
  String get elderModeDesc =>
      'Bigger text, spoken guidance and Watch Mode by default';

  @override
  String get yourName => 'Your name';

  @override
  String get gotra => 'Gotra';

  @override
  String get save => 'Save';

  @override
  String get chooseGod => 'Choose your God';

  @override
  String get welcome => 'Welcome to Kalpam';

  @override
  String get begin => 'Begin';

  @override
  String get optional => 'optional';

  @override
  String get next => 'Next';

  @override
  String get aboutYou => 'For your Sankalpam';

  @override
  String get aboutYouDesc =>
      'Your name, gotra and city are spoken in every Sankalpam. They stay on this phone.';

  @override
  String get modeHandsOn => 'Hands-on Pooja';

  @override
  String get modeHandsOnDesc => 'Perform every upachara yourself';

  @override
  String get modeWatch => 'Watch Mode';

  @override
  String get modeWatchDesc =>
      'The pooja is performed for you, like a temple deeparadhana';

  @override
  String get chooseLength => 'Pooja length';

  @override
  String minutes(int n) {
    return '$n min';
  }

  @override
  String get beginPooja => 'Begin Pooja';

  @override
  String stepOf(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get doItForMe => 'Do this for me';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get endPooja => 'End pooja';

  @override
  String get poojaComplete => 'Pooja complete';

  @override
  String poojaCompleteMsg(String god) {
    return 'May $god bless you and your family.';
  }

  @override
  String get yourSankalpam => 'Your Sankalpam';

  @override
  String get listen => 'Listen';

  @override
  String get stop => 'Stop';

  @override
  String get placeholderSanctum => 'Preview sanctum — 3D idol coming soon';

  @override
  String get recordingSoon => 'Recording coming soon';

  @override
  String get parayanamToday => 'Parayanam today';

  @override
  String get allStotras => 'All stotras';

  @override
  String get poojaVidhanams => 'Pooja Vidhanams';

  @override
  String get sung => 'Sung';

  @override
  String get learnMode => 'Learn';

  @override
  String get repeatLine => 'Repeat';

  @override
  String get japaCounter => 'Japa';

  @override
  String get meaning => 'Meaning';

  @override
  String get reset => 'Reset';

  @override
  String malaDone(int count) {
    return 'Mala complete · $count';
  }

  @override
  String get sampleText => 'Sample text — full verified text coming soon';

  @override
  String get seasonPlaylist => 'Season playlist';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get allBhajans => 'All bhajans';

  @override
  String get familyCircles => 'Family Circles';

  @override
  String get familyCirclesDesc =>
      'Keep a vratam or mala together and see each other\'s day count.';

  @override
  String get guruswamyGroups => 'Guruswamy Groups';

  @override
  String get guruswamyDesc =>
      'Deeksha day counts, announcements, yatra poll, Virtual Queue list and expense split.';

  @override
  String get groupsOpening =>
      'Groups open with Makaravilakku, 14 Jan. Pooja, chanting and trackers never need an account.';

  @override
  String get notifyMe => 'Tell me when Groups open';

  @override
  String get katha => 'Katha';

  @override
  String get samagri => 'Samagri';

  @override
  String get sankalpam => 'Sankalpam';

  @override
  String get vidhanam => 'Vidhanam';

  @override
  String get tracker => 'Tracker';

  @override
  String get udyapanam => 'Udyapanam';

  @override
  String get fasting => 'Fasting';

  @override
  String get rules => 'Deeksha rules';

  @override
  String get morning => 'Morning';

  @override
  String get evening => 'Evening';

  @override
  String get irumudi => 'Irumudi';

  @override
  String get irumudiFront => 'Front pouch (Mun Kettu)';

  @override
  String get irumudiBack => 'Back pouch (Pin Kettu)';

  @override
  String get maladharana => 'Maladharana Mantram';

  @override
  String get startDeeksha => 'Start my deeksha';

  @override
  String get startDate => 'Start date';

  @override
  String get deekshaDays => 'Days';

  @override
  String deekshaDay(int n) {
    return 'Day $n';
  }

  @override
  String streak(int n) {
    return '$n days kept in a row';
  }

  @override
  String daysLeft(int n) {
    return '$n days left';
  }

  @override
  String get sabarimalaLive => 'Sabarimala Live';

  @override
  String get nadaOpen => 'Nada open';

  @override
  String get nadaClosed => 'Nada closed';

  @override
  String nowPooja(String name) {
    return 'Now: $name';
  }

  @override
  String nextPooja(String name, String time) {
    return 'Next: $name at $time';
  }

  @override
  String get scheduleNote =>
      'Typical season schedule. Always check official TDB notices.';

  @override
  String get virtualQueue => 'Book Virtual Queue on the official site';

  @override
  String get noVip =>
      'Kalpam never sells darshan. Booking is free on the official site.';

  @override
  String get annadanam => 'Annadanam near you';

  @override
  String get templesNear => 'Ayyappa temples and Padi Poojas';

  @override
  String get feedPending =>
      'Live listings appear here once verified organisers publish them for your city.';

  @override
  String get beginUdyapanam => 'Begin Udyapanam';

  @override
  String get certificate => 'Completion certificate';

  @override
  String get share => 'Share';

  @override
  String chapter(int n) {
    return 'Chapter $n';
  }

  @override
  String certificateText(int days, String name, String vratam) {
    return '$name completed the $vratam of $days days.';
  }

  @override
  String get notStarted => 'Not started';

  @override
  String get openVratam => 'Open vratam';

  @override
  String get voiceGuide => 'Voice guide';

  @override
  String get devotee => 'Devotee';

  @override
  String get allGods => 'All Gods';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get gpsFailed =>
      'Couldn\'t get your location. Please search for your city.';

  @override
  String get cityWhy =>
      'Sunrise, tithi, Rahu Kalam and your Sankalpam are calculated for this city.';

  @override
  String get cityNotSet => 'Set your city';

  @override
  String get gotraHelp => 'Spoken in your Sankalpam';

  @override
  String get janmaNakshatram => 'Janma nakshatram';

  @override
  String get notSet => 'Not set';

  @override
  String get reminders => 'Daily reminders';

  @override
  String get remindersDesc =>
      'A gentle reminder for your morning and evening pooja. Never during a pooja.';

  @override
  String get morningReminder => 'Morning pooja';

  @override
  String get eveningReminder => 'Evening deepam';

  @override
  String get familyProfiles => 'Family profiles';

  @override
  String get familyProfilesDesc =>
      'Choose whose name and gotram are spoken in the Sankalpam.';

  @override
  String get addProfile => 'Add family member';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get remove => 'Remove';

  @override
  String get cancel => 'Cancel';

  @override
  String sankalpamFor(String name) {
    return 'Sankalpam for $name';
  }

  @override
  String get yourData => 'Your data';

  @override
  String get yourDataDesc =>
      'Everything stays on this phone. Nothing is synced unless you create an account.';

  @override
  String get exportData => 'Export my data';

  @override
  String get deleteAll => 'Delete all my data';

  @override
  String get deleteAllConfirm =>
      'This permanently deletes your profiles, trackers and settings from this phone.';

  @override
  String get poojaHow => 'How would you like to do the pooja?';

  @override
  String get archana => 'Archana';

  @override
  String get archanaDesc => 'One flower for each name of Swamy';

  @override
  String get archanaOff => 'None';

  @override
  String archanaShort(int n) {
    return 'Short · $n';
  }

  @override
  String archanaFull(int n) {
    return 'Full · $n';
  }

  @override
  String nameOf(int n, int total) {
    return 'Name $n of $total';
  }

  @override
  String countOf(int n, int total) {
    return '$n of $total';
  }

  @override
  String get beingPerformed => 'Being performed for you';

  @override
  String get backToToday => 'Back to Today';

  @override
  String sanctumAfterReview(String god) {
    return '$god\'s sanctum opens after the Ayyappa sanctum is reviewed. Ayyappa\'s sanctum is open now.';
  }

  @override
  String get liquidWater => 'Water';

  @override
  String get liquidMilk => 'Milk';

  @override
  String get liquidPanchamrutam => 'Panchamrutam';

  @override
  String get liquidGhee => 'Ghee';

  @override
  String get hintTap => 'Tap the sanctum';

  @override
  String get hintCircle => 'Circle the plate clockwise around Swamy';

  @override
  String get hintShower => 'Swipe up to shower flowers';

  @override
  String get hintPour => 'Drag down, or tilt the phone, to pour';

  @override
  String get hintSwipeDown => 'Swipe down firmly to break the coconut';

  @override
  String get hintShake => 'Shake the phone, or tap, to ring the bell';

  @override
  String get hintBlow => 'Press and hold to blow the shankh';

  @override
  String get hintWalk => 'Sweep left and right to walk around Swamy';

  @override
  String get hintArchana => 'Tap or flick up to offer a flower';
}
