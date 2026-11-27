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

  @override
  String get chooseByDay => 'Choose for me by day';

  @override
  String get chooseByDayDesc =>
      'Mon Shiva · Tue Hanuman · Wed Ayyappa · Thu Sai Baba · Fri Lakshmi · Sat Venkateswara · Sun Surya';

  @override
  String get godByDay => 'Today\'s God · by the day';

  @override
  String get morningRitual => 'Morning Nitya Archana';

  @override
  String get eveningRitual => 'Evening Deeparadhana';

  @override
  String get dailyRituals => 'Daily rituals';

  @override
  String atSunrise(String time) {
    return 'Sunrise $time';
  }

  @override
  String atSunset(String time) {
    return 'Sunset $time';
  }

  @override
  String get doneToday => 'Done today';

  @override
  String archanaFullN(int n) {
    return 'Full · $n names';
  }

  @override
  String archanaShortN(int n) {
    return 'Short · $n names';
  }

  @override
  String get suprabhatam => 'Suprabhatam';

  @override
  String get deepam => 'Deepam';

  @override
  String get aarti => 'Aarti';

  @override
  String get closingPrayer => 'Closing prayer';

  @override
  String get arghyam => 'Surya Arghyam';

  @override
  String get arghyamDesc =>
      'Face the sun and offer water from cupped hands three times, then bow.';

  @override
  String get deepamDesc => 'Light the lamp before the god.';

  @override
  String get aartiDesc => 'Wave the aarti in three clockwise circles.';

  @override
  String get closingDesc => 'Bow down and close the day\'s worship.';

  @override
  String get sankalpamDesc =>
      'Hold akshatas in your right palm and take the day\'s Sankalpam.';

  @override
  String get offerFlower => 'Offer a flower';

  @override
  String get markDone => 'Done';

  @override
  String get performInSannidhanam => 'Perform in Sannidhanam';

  @override
  String get ritualComplete => 'Ritual complete';

  @override
  String get eveningAnchor => 'Evening reminder at';

  @override
  String get anchorTime => 'My time';

  @override
  String get anchorSunset => 'Local sunset';

  @override
  String get byGod => 'By god';

  @override
  String get byCategory => 'By category';

  @override
  String get catSahasranamam => 'Sahasranamam';

  @override
  String get catAshtottaram => 'Ashtottaram';

  @override
  String get catChalisa => 'Chalisa';

  @override
  String get catStotram => 'Stotram';

  @override
  String get catSuprabhatam => 'Suprabhatam';

  @override
  String get catSaranam => 'Saranam';

  @override
  String get catKeertana => 'Keertana';

  @override
  String get catMantram => 'Mantram';

  @override
  String get catNamavali => 'Namavali';

  @override
  String get catNamajapam => 'Namajapam';

  @override
  String linesCount(int n) {
    return '$n lines';
  }

  @override
  String get sampleShort => 'Sample';

  @override
  String lineOf(int n, int total) {
    return 'Line $n of $total';
  }

  @override
  String repeatOf(int n, int total) {
    return 'Repeat $n of $total';
  }

  @override
  String get tapToCount => 'Tap to count';

  @override
  String malasCount(int n) {
    return '$n malas';
  }

  @override
  String get countRepeats => 'Count each repeat on the mala';

  @override
  String get voiceReads =>
      'Recording coming soon. The voice guide reads each line meanwhile.';

  @override
  String get japaTarget => 'Target';

  @override
  String get sourceLabel => 'Source';

  @override
  String get chantComplete => 'Parayanam complete';

  @override
  String get playAll => 'Play all';

  @override
  String get loopPlaylist => 'Repeat playlist';

  @override
  String get upNext => 'Up next';

  @override
  String aboutMin(int n) {
    return '~$n min';
  }

  @override
  String bhajanOf(int n, int total) {
    return 'Bhajan $n of $total';
  }

  @override
  String get lyricsSample => 'Lyrics pending verification';

  @override
  String get offlineLyrics => 'Lyrics work offline';

  @override
  String nSubhodayamTitle(String god) {
    return 'Subhodayam · $god';
  }

  @override
  String nSunLine(String dusk, String rise) {
    return 'Sunrise $rise · Sunset $dusk';
  }

  @override
  String nTodayIs(String name) {
    return 'Today: $name';
  }

  @override
  String nMorningBody(String god) {
    return 'Your morning archana for $god is ready whenever you are.';
  }

  @override
  String get nEveningTitle => 'Sandhya time';

  @override
  String nEveningBody(String god, String time) {
    return 'Light the evening deepam and offer aarti to $god. Sunset $time.';
  }

  @override
  String nTomorrowTitle(String name) {
    return 'Tomorrow: $name';
  }

  @override
  String get nTomorrowBody =>
      'Keep the samagri ready tonight. Tap for the checklist.';

  @override
  String nFestivalBody(String god) {
    return 'Today\'s special pooja and archana for $god are ready.';
  }

  @override
  String nPeakBody(String time) {
    return 'Special pooja today, and the live aarti at $time.';
  }

  @override
  String nInviteTitle(int days, String name) {
    return '$name begins in $days days';
  }

  @override
  String get nInviteBody =>
      'Join the Sankalpam and observe it together with devotees everywhere.';

  @override
  String nClosingTitle(String name) {
    return 'Udyapanam · $name';
  }

  @override
  String get nClosingBody =>
      'Close the season with the Udyapanam pooja and your thanks.';

  @override
  String nChecklistSummary(String items) {
    return 'Today: $items';
  }

  @override
  String nHalfwayTitle(int day, int total) {
    return 'Halfway · Day $day of $total';
  }

  @override
  String nFinalTitle(int day, int total) {
    return 'Final day · Day $day of $total';
  }

  @override
  String nFinalBody(String vratam) {
    return 'Today is the Udyapanam. Complete your $vratam with gratitude.';
  }

  @override
  String nResumeTitle(int day, int total) {
    return 'Welcome back · Day $day of $total';
  }

  @override
  String get nResumeBody =>
      'Every day is a fresh offering. Continue whenever you are ready.';

  @override
  String get nNudgeTitle => 'Evening observances';

  @override
  String nNudgeBody(int count) {
    return '$count left on today\'s checklist, whenever you are ready.';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDesc =>
      'Gentle reminders, scheduled on this phone. Nothing arrives during a pooja.';

  @override
  String get nTypeSubhodayam => 'Subhodayam Panchangam at sunrise';

  @override
  String get nTypeMorning => 'Morning ritual reminder';

  @override
  String get nTypeEvening => 'Evening Sandhya reminder';

  @override
  String get nTypeFestivals => 'Festivals and special days';

  @override
  String get nTypeVratam => 'Mala and vratam check-ins';

  @override
  String get quietHours => 'Quiet hours';

  @override
  String get fromTime => 'From';

  @override
  String get toTime => 'To';

  @override
  String get subhodayamTime => 'Subhodayam time';

  @override
  String get atSunriseShort => 'At sunrise';

  @override
  String minAfterSunrise(int n) {
    return '+$n min';
  }

  @override
  String get comingUp => 'Coming up';

  @override
  String get nothingScheduled => 'Nothing scheduled in the coming week.';

  @override
  String get exactTitle => 'On-time reminders';

  @override
  String get exactDesc =>
      'Android may delay reminders to save battery. For Subhodayam to arrive right at sunrise, allow exact timing. If reminders still come late, set Kalpam\'s battery use to Unrestricted in Android settings. Kalpam works fully either way.';

  @override
  String get allowExact => 'Allow exact timing';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get gotIt => 'Got it';

  @override
  String get joinDaysTitle => 'How many days will you keep it?';

  @override
  String joinDaysStandard(int n) {
    return 'The standard count is $n days.';
  }

  @override
  String nDays(int n) {
    return '$n days';
  }

  @override
  String get startsOn => 'Starts';

  @override
  String get checkInTime => 'Daily check-in time';

  @override
  String get beginSankalpam => 'Begin the Sankalpam';
}
