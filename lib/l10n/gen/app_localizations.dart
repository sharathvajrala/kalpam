import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kalpam'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your sankalpam — every day, every vratam'**
  String get tagline;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabSannidhanam.
  ///
  /// In en, this message translates to:
  /// **'Sannidhanam'**
  String get tabSannidhanam;

  /// No description provided for @tabGrantham.
  ///
  /// In en, this message translates to:
  /// **'Grantham'**
  String get tabGrantham;

  /// No description provided for @tabBhajans.
  ///
  /// In en, this message translates to:
  /// **'Bhajans'**
  String get tabBhajans;

  /// No description provided for @tabGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get tabGroups;

  /// No description provided for @subhodayam.
  ///
  /// In en, this message translates to:
  /// **'Subhodayam'**
  String get subhodayam;

  /// No description provided for @subhaSayantram.
  ///
  /// In en, this message translates to:
  /// **'Subha Sayantram'**
  String get subhaSayantram;

  /// No description provided for @myGod.
  ///
  /// In en, this message translates to:
  /// **'My God'**
  String get myGod;

  /// No description provided for @dailyPooja.
  ///
  /// In en, this message translates to:
  /// **'Daily Pooja'**
  String get dailyPooja;

  /// No description provided for @chanting.
  ///
  /// In en, this message translates to:
  /// **'Chanting'**
  String get chanting;

  /// No description provided for @joinSankalpam.
  ///
  /// In en, this message translates to:
  /// **'Join the Sankalpam'**
  String get joinSankalpam;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @dayOf.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String dayOf(int day, int total);

  /// No description provided for @daysToPeak.
  ///
  /// In en, this message translates to:
  /// **'{days} days to {peak}'**
  String daysToPeak(int days, String peak);

  /// No description provided for @peakToday.
  ///
  /// In en, this message translates to:
  /// **'{peak} is today'**
  String peakToday(String peak);

  /// No description provided for @startsIn.
  ///
  /// In en, this message translates to:
  /// **'Begins in {days} days'**
  String startsIn(int days);

  /// No description provided for @seasonClosing.
  ///
  /// In en, this message translates to:
  /// **'Season complete — Udyapanam'**
  String get seasonClosing;

  /// No description provided for @nextFlagship.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String nextFlagship(String name);

  /// No description provided for @todayKatha.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Katha'**
  String get todayKatha;

  /// No description provided for @todayBhajan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Bhajan'**
  String get todayBhajan;

  /// No description provided for @seasonPooja.
  ///
  /// In en, this message translates to:
  /// **'Season Pooja'**
  String get seasonPooja;

  /// No description provided for @samagriChecklist.
  ///
  /// In en, this message translates to:
  /// **'Samagri checklist'**
  String get samagriChecklist;

  /// No description provided for @panchangam.
  ///
  /// In en, this message translates to:
  /// **'Panchangam'**
  String get panchangam;

  /// No description provided for @tithi.
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get tithi;

  /// No description provided for @nakshatram.
  ///
  /// In en, this message translates to:
  /// **'Nakshatram'**
  String get nakshatram;

  /// No description provided for @yogam.
  ///
  /// In en, this message translates to:
  /// **'Yogam'**
  String get yogam;

  /// No description provided for @karanam.
  ///
  /// In en, this message translates to:
  /// **'Karanam'**
  String get karanam;

  /// No description provided for @masam.
  ///
  /// In en, this message translates to:
  /// **'Masam'**
  String get masam;

  /// No description provided for @samvatsaram.
  ///
  /// In en, this message translates to:
  /// **'Samvatsaram'**
  String get samvatsaram;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @rahuKalam.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kalam'**
  String get rahuKalam;

  /// No description provided for @yamagandam.
  ///
  /// In en, this message translates to:
  /// **'Yamagandam'**
  String get yamagandam;

  /// No description provided for @gulikaKalam.
  ///
  /// In en, this message translates to:
  /// **'Gulika Kalam'**
  String get gulikaKalam;

  /// No description provided for @until.
  ///
  /// In en, this message translates to:
  /// **'until {time}'**
  String until(String time);

  /// No description provided for @todayVratam.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Vratam'**
  String get todayVratam;

  /// No description provided for @weekdayGod.
  ///
  /// In en, this message translates to:
  /// **'Today\'s God'**
  String get weekdayGod;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @chooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose your city'**
  String get chooseCity;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @elderMode.
  ///
  /// In en, this message translates to:
  /// **'Elder Mode'**
  String get elderMode;

  /// No description provided for @elderModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Bigger text, spoken guidance and Watch Mode by default'**
  String get elderModeDesc;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @gotra.
  ///
  /// In en, this message translates to:
  /// **'Gotra'**
  String get gotra;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @chooseGod.
  ///
  /// In en, this message translates to:
  /// **'Choose your God'**
  String get chooseGod;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kalpam'**
  String get welcome;

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'For your Sankalpam'**
  String get aboutYou;

  /// No description provided for @aboutYouDesc.
  ///
  /// In en, this message translates to:
  /// **'Your name, gotra and city are spoken in every Sankalpam. They stay on this phone.'**
  String get aboutYouDesc;

  /// No description provided for @modeHandsOn.
  ///
  /// In en, this message translates to:
  /// **'Hands-on Pooja'**
  String get modeHandsOn;

  /// No description provided for @modeHandsOnDesc.
  ///
  /// In en, this message translates to:
  /// **'Perform every upachara yourself'**
  String get modeHandsOnDesc;

  /// No description provided for @modeWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch Mode'**
  String get modeWatch;

  /// No description provided for @modeWatchDesc.
  ///
  /// In en, this message translates to:
  /// **'The pooja is performed for you, like a temple deeparadhana'**
  String get modeWatchDesc;

  /// No description provided for @chooseLength.
  ///
  /// In en, this message translates to:
  /// **'Pooja length'**
  String get chooseLength;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String minutes(int n);

  /// No description provided for @beginPooja.
  ///
  /// In en, this message translates to:
  /// **'Begin Pooja'**
  String get beginPooja;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String stepOf(int n, int total);

  /// No description provided for @doItForMe.
  ///
  /// In en, this message translates to:
  /// **'Do this for me'**
  String get doItForMe;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @endPooja.
  ///
  /// In en, this message translates to:
  /// **'End pooja'**
  String get endPooja;

  /// No description provided for @poojaComplete.
  ///
  /// In en, this message translates to:
  /// **'Pooja complete'**
  String get poojaComplete;

  /// No description provided for @poojaCompleteMsg.
  ///
  /// In en, this message translates to:
  /// **'May {god} bless you and your family.'**
  String poojaCompleteMsg(String god);

  /// No description provided for @yourSankalpam.
  ///
  /// In en, this message translates to:
  /// **'Your Sankalpam'**
  String get yourSankalpam;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @placeholderSanctum.
  ///
  /// In en, this message translates to:
  /// **'Preview sanctum — 3D idol coming soon'**
  String get placeholderSanctum;

  /// No description provided for @recordingSoon.
  ///
  /// In en, this message translates to:
  /// **'Recording coming soon'**
  String get recordingSoon;

  /// No description provided for @parayanamToday.
  ///
  /// In en, this message translates to:
  /// **'Parayanam today'**
  String get parayanamToday;

  /// No description provided for @allStotras.
  ///
  /// In en, this message translates to:
  /// **'All stotras'**
  String get allStotras;

  /// No description provided for @poojaVidhanams.
  ///
  /// In en, this message translates to:
  /// **'Pooja Vidhanams'**
  String get poojaVidhanams;

  /// No description provided for @sung.
  ///
  /// In en, this message translates to:
  /// **'Sung'**
  String get sung;

  /// No description provided for @learnMode.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnMode;

  /// No description provided for @repeatLine.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatLine;

  /// No description provided for @japaCounter.
  ///
  /// In en, this message translates to:
  /// **'Japa'**
  String get japaCounter;

  /// No description provided for @meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaning;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @malaDone.
  ///
  /// In en, this message translates to:
  /// **'Mala complete · {count}'**
  String malaDone(int count);

  /// No description provided for @sampleText.
  ///
  /// In en, this message translates to:
  /// **'Sample text — full verified text coming soon'**
  String get sampleText;

  /// No description provided for @seasonPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Season playlist'**
  String get seasonPlaylist;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @allBhajans.
  ///
  /// In en, this message translates to:
  /// **'All bhajans'**
  String get allBhajans;

  /// No description provided for @familyCircles.
  ///
  /// In en, this message translates to:
  /// **'Family Circles'**
  String get familyCircles;

  /// No description provided for @familyCirclesDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep a vratam or mala together and see each other\'s day count.'**
  String get familyCirclesDesc;

  /// No description provided for @guruswamyGroups.
  ///
  /// In en, this message translates to:
  /// **'Guruswamy Groups'**
  String get guruswamyGroups;

  /// No description provided for @guruswamyDesc.
  ///
  /// In en, this message translates to:
  /// **'Deeksha day counts, announcements, yatra poll, Virtual Queue list and expense split.'**
  String get guruswamyDesc;

  /// No description provided for @groupsOpening.
  ///
  /// In en, this message translates to:
  /// **'Groups open with Makaravilakku, 14 Jan. Pooja, chanting and trackers never need an account.'**
  String get groupsOpening;

  /// No description provided for @notifyMe.
  ///
  /// In en, this message translates to:
  /// **'Tell me when Groups open'**
  String get notifyMe;

  /// No description provided for @katha.
  ///
  /// In en, this message translates to:
  /// **'Katha'**
  String get katha;

  /// No description provided for @samagri.
  ///
  /// In en, this message translates to:
  /// **'Samagri'**
  String get samagri;

  /// No description provided for @sankalpam.
  ///
  /// In en, this message translates to:
  /// **'Sankalpam'**
  String get sankalpam;

  /// No description provided for @vidhanam.
  ///
  /// In en, this message translates to:
  /// **'Vidhanam'**
  String get vidhanam;

  /// No description provided for @tracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get tracker;

  /// No description provided for @udyapanam.
  ///
  /// In en, this message translates to:
  /// **'Udyapanam'**
  String get udyapanam;

  /// No description provided for @fasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get fasting;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Deeksha rules'**
  String get rules;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @irumudi.
  ///
  /// In en, this message translates to:
  /// **'Irumudi'**
  String get irumudi;

  /// No description provided for @irumudiFront.
  ///
  /// In en, this message translates to:
  /// **'Front pouch (Mun Kettu)'**
  String get irumudiFront;

  /// No description provided for @irumudiBack.
  ///
  /// In en, this message translates to:
  /// **'Back pouch (Pin Kettu)'**
  String get irumudiBack;

  /// No description provided for @maladharana.
  ///
  /// In en, this message translates to:
  /// **'Maladharana Mantram'**
  String get maladharana;

  /// No description provided for @startDeeksha.
  ///
  /// In en, this message translates to:
  /// **'Start my deeksha'**
  String get startDeeksha;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @deekshaDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get deekshaDays;

  /// No description provided for @deekshaDay.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String deekshaDay(int n);

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'{n} days kept in a row'**
  String streak(int n);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{n} days left'**
  String daysLeft(int n);

  /// No description provided for @sabarimalaLive.
  ///
  /// In en, this message translates to:
  /// **'Sabarimala Live'**
  String get sabarimalaLive;

  /// No description provided for @nadaOpen.
  ///
  /// In en, this message translates to:
  /// **'Nada open'**
  String get nadaOpen;

  /// No description provided for @nadaClosed.
  ///
  /// In en, this message translates to:
  /// **'Nada closed'**
  String get nadaClosed;

  /// No description provided for @nowPooja.
  ///
  /// In en, this message translates to:
  /// **'Now: {name}'**
  String nowPooja(String name);

  /// No description provided for @nextPooja.
  ///
  /// In en, this message translates to:
  /// **'Next: {name} at {time}'**
  String nextPooja(String name, String time);

  /// No description provided for @scheduleNote.
  ///
  /// In en, this message translates to:
  /// **'Typical season schedule. Always check official TDB notices.'**
  String get scheduleNote;

  /// No description provided for @virtualQueue.
  ///
  /// In en, this message translates to:
  /// **'Book Virtual Queue on the official site'**
  String get virtualQueue;

  /// No description provided for @noVip.
  ///
  /// In en, this message translates to:
  /// **'Kalpam never sells darshan. Booking is free on the official site.'**
  String get noVip;

  /// No description provided for @annadanam.
  ///
  /// In en, this message translates to:
  /// **'Annadanam near you'**
  String get annadanam;

  /// No description provided for @templesNear.
  ///
  /// In en, this message translates to:
  /// **'Ayyappa temples and Padi Poojas'**
  String get templesNear;

  /// No description provided for @feedPending.
  ///
  /// In en, this message translates to:
  /// **'Live listings appear here once verified organisers publish them for your city.'**
  String get feedPending;

  /// No description provided for @beginUdyapanam.
  ///
  /// In en, this message translates to:
  /// **'Begin Udyapanam'**
  String get beginUdyapanam;

  /// No description provided for @certificate.
  ///
  /// In en, this message translates to:
  /// **'Completion certificate'**
  String get certificate;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter {n}'**
  String chapter(int n);

  /// No description provided for @certificateText.
  ///
  /// In en, this message translates to:
  /// **'{name} completed the {vratam} of {days} days.'**
  String certificateText(int days, String name, String vratam);

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get notStarted;

  /// No description provided for @openVratam.
  ///
  /// In en, this message translates to:
  /// **'Open vratam'**
  String get openVratam;

  /// No description provided for @voiceGuide.
  ///
  /// In en, this message translates to:
  /// **'Voice guide'**
  String get voiceGuide;

  /// No description provided for @devotee.
  ///
  /// In en, this message translates to:
  /// **'Devotee'**
  String get devotee;

  /// No description provided for @allGods.
  ///
  /// In en, this message translates to:
  /// **'All Gods'**
  String get allGods;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @gpsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location. Please search for your city.'**
  String get gpsFailed;

  /// No description provided for @cityWhy.
  ///
  /// In en, this message translates to:
  /// **'Sunrise, tithi, Rahu Kalam and your Sankalpam are calculated for this city.'**
  String get cityWhy;

  /// No description provided for @cityNotSet.
  ///
  /// In en, this message translates to:
  /// **'Set your city'**
  String get cityNotSet;

  /// No description provided for @gotraHelp.
  ///
  /// In en, this message translates to:
  /// **'Spoken in your Sankalpam'**
  String get gotraHelp;

  /// No description provided for @janmaNakshatram.
  ///
  /// In en, this message translates to:
  /// **'Janma nakshatram'**
  String get janmaNakshatram;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get reminders;

  /// No description provided for @remindersDesc.
  ///
  /// In en, this message translates to:
  /// **'A gentle reminder for your morning and evening pooja. Never during a pooja.'**
  String get remindersDesc;

  /// No description provided for @morningReminder.
  ///
  /// In en, this message translates to:
  /// **'Morning pooja'**
  String get morningReminder;

  /// No description provided for @eveningReminder.
  ///
  /// In en, this message translates to:
  /// **'Evening deepam'**
  String get eveningReminder;

  /// No description provided for @familyProfiles.
  ///
  /// In en, this message translates to:
  /// **'Family profiles'**
  String get familyProfiles;

  /// No description provided for @familyProfilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose whose name and gotram are spoken in the Sankalpam.'**
  String get familyProfilesDesc;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add family member'**
  String get addProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @sankalpamFor.
  ///
  /// In en, this message translates to:
  /// **'Sankalpam for {name}'**
  String sankalpamFor(String name);

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// No description provided for @yourDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone. Nothing is synced unless you create an account.'**
  String get yourDataDesc;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportData;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all my data'**
  String get deleteAll;

  /// No description provided for @deleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your profiles, trackers and settings from this phone.'**
  String get deleteAllConfirm;

  /// No description provided for @poojaHow.
  ///
  /// In en, this message translates to:
  /// **'How would you like to do the pooja?'**
  String get poojaHow;

  /// No description provided for @archana.
  ///
  /// In en, this message translates to:
  /// **'Archana'**
  String get archana;

  /// No description provided for @archanaDesc.
  ///
  /// In en, this message translates to:
  /// **'One flower for each name of Swamy'**
  String get archanaDesc;

  /// No description provided for @archanaOff.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get archanaOff;

  /// No description provided for @archanaShort.
  ///
  /// In en, this message translates to:
  /// **'Short · {n}'**
  String archanaShort(int n);

  /// No description provided for @archanaFull.
  ///
  /// In en, this message translates to:
  /// **'Full · {n}'**
  String archanaFull(int n);

  /// No description provided for @nameOf.
  ///
  /// In en, this message translates to:
  /// **'Name {n} of {total}'**
  String nameOf(int n, int total);

  /// No description provided for @countOf.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total}'**
  String countOf(int n, int total);

  /// No description provided for @beingPerformed.
  ///
  /// In en, this message translates to:
  /// **'Being performed for you'**
  String get beingPerformed;

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get backToToday;

  /// No description provided for @sanctumAfterReview.
  ///
  /// In en, this message translates to:
  /// **'{god}\'s sanctum opens after the Ayyappa sanctum is reviewed. Ayyappa\'s sanctum is open now.'**
  String sanctumAfterReview(String god);

  /// No description provided for @liquidWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get liquidWater;

  /// No description provided for @liquidMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get liquidMilk;

  /// No description provided for @liquidPanchamrutam.
  ///
  /// In en, this message translates to:
  /// **'Panchamrutam'**
  String get liquidPanchamrutam;

  /// No description provided for @liquidGhee.
  ///
  /// In en, this message translates to:
  /// **'Ghee'**
  String get liquidGhee;

  /// No description provided for @hintTap.
  ///
  /// In en, this message translates to:
  /// **'Tap the sanctum'**
  String get hintTap;

  /// No description provided for @hintCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle the plate clockwise around Swamy'**
  String get hintCircle;

  /// No description provided for @hintShower.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to shower flowers'**
  String get hintShower;

  /// No description provided for @hintPour.
  ///
  /// In en, this message translates to:
  /// **'Drag down, or tilt the phone, to pour'**
  String get hintPour;

  /// No description provided for @hintSwipeDown.
  ///
  /// In en, this message translates to:
  /// **'Swipe down firmly to break the coconut'**
  String get hintSwipeDown;

  /// No description provided for @hintShake.
  ///
  /// In en, this message translates to:
  /// **'Shake the phone, or tap, to ring the bell'**
  String get hintShake;

  /// No description provided for @hintBlow.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to blow the shankh'**
  String get hintBlow;

  /// No description provided for @hintWalk.
  ///
  /// In en, this message translates to:
  /// **'Sweep left and right to walk around Swamy'**
  String get hintWalk;

  /// No description provided for @hintArchana.
  ///
  /// In en, this message translates to:
  /// **'Tap or flick up to offer a flower'**
  String get hintArchana;

  /// No description provided for @chooseByDay.
  ///
  /// In en, this message translates to:
  /// **'Choose for me by day'**
  String get chooseByDay;

  /// No description provided for @chooseByDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Mon Shiva · Tue Hanuman · Wed Ayyappa · Thu Sai Baba · Fri Lakshmi · Sat Venkateswara · Sun Surya'**
  String get chooseByDayDesc;

  /// No description provided for @godByDay.
  ///
  /// In en, this message translates to:
  /// **'Today\'s God · by the day'**
  String get godByDay;

  /// No description provided for @morningRitual.
  ///
  /// In en, this message translates to:
  /// **'Morning Nitya Archana'**
  String get morningRitual;

  /// No description provided for @eveningRitual.
  ///
  /// In en, this message translates to:
  /// **'Evening Deeparadhana'**
  String get eveningRitual;

  /// No description provided for @dailyRituals.
  ///
  /// In en, this message translates to:
  /// **'Daily rituals'**
  String get dailyRituals;

  /// No description provided for @atSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise {time}'**
  String atSunrise(String time);

  /// No description provided for @atSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset {time}'**
  String atSunset(String time);

  /// No description provided for @doneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get doneToday;

  /// No description provided for @archanaFullN.
  ///
  /// In en, this message translates to:
  /// **'Full · {n} names'**
  String archanaFullN(int n);

  /// No description provided for @archanaShortN.
  ///
  /// In en, this message translates to:
  /// **'Short · {n} names'**
  String archanaShortN(int n);

  /// No description provided for @suprabhatam.
  ///
  /// In en, this message translates to:
  /// **'Suprabhatam'**
  String get suprabhatam;

  /// No description provided for @deepam.
  ///
  /// In en, this message translates to:
  /// **'Deepam'**
  String get deepam;

  /// No description provided for @aarti.
  ///
  /// In en, this message translates to:
  /// **'Aarti'**
  String get aarti;

  /// No description provided for @closingPrayer.
  ///
  /// In en, this message translates to:
  /// **'Closing prayer'**
  String get closingPrayer;

  /// No description provided for @arghyam.
  ///
  /// In en, this message translates to:
  /// **'Surya Arghyam'**
  String get arghyam;

  /// No description provided for @arghyamDesc.
  ///
  /// In en, this message translates to:
  /// **'Face the sun and offer water from cupped hands three times, then bow.'**
  String get arghyamDesc;

  /// No description provided for @deepamDesc.
  ///
  /// In en, this message translates to:
  /// **'Light the lamp before the god.'**
  String get deepamDesc;

  /// No description provided for @aartiDesc.
  ///
  /// In en, this message translates to:
  /// **'Wave the aarti in three clockwise circles.'**
  String get aartiDesc;

  /// No description provided for @closingDesc.
  ///
  /// In en, this message translates to:
  /// **'Bow down and close the day\'s worship.'**
  String get closingDesc;

  /// No description provided for @sankalpamDesc.
  ///
  /// In en, this message translates to:
  /// **'Hold akshatas in your right palm and take the day\'s Sankalpam.'**
  String get sankalpamDesc;

  /// No description provided for @offerFlower.
  ///
  /// In en, this message translates to:
  /// **'Offer a flower'**
  String get offerFlower;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get markDone;

  /// No description provided for @performInSannidhanam.
  ///
  /// In en, this message translates to:
  /// **'Perform in Sannidhanam'**
  String get performInSannidhanam;

  /// No description provided for @ritualComplete.
  ///
  /// In en, this message translates to:
  /// **'Ritual complete'**
  String get ritualComplete;

  /// No description provided for @eveningAnchor.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder at'**
  String get eveningAnchor;

  /// No description provided for @anchorTime.
  ///
  /// In en, this message translates to:
  /// **'My time'**
  String get anchorTime;

  /// No description provided for @anchorSunset.
  ///
  /// In en, this message translates to:
  /// **'Local sunset'**
  String get anchorSunset;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
