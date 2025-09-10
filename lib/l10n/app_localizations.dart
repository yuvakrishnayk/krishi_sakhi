import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Krishi Sakhi'**
  String get appTitle;

  /// No description provided for @drawerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHome;

  /// No description provided for @drawerLearningChat.
  ///
  /// In en, this message translates to:
  /// **'Learning Chat'**
  String get drawerLearningChat;

  /// No description provided for @drawerCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get drawerCourses;

  /// No description provided for @drawerForum.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get drawerForum;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Raj Kumar'**
  String get userName;

  /// No description provided for @projectsCount.
  ///
  /// In en, this message translates to:
  /// **'Projects: {count}'**
  String projectsCount(Object count);

  /// No description provided for @sinceDate.
  ///
  /// In en, this message translates to:
  /// **'Since: Jan 2024'**
  String get sinceDate;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutQuestion;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest News'**
  String get latestNews;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @dailyTip.
  ///
  /// In en, this message translates to:
  /// **'5-Minute Daily Tip'**
  String get dailyTip;

  /// No description provided for @monsoonAlert.
  ///
  /// In en, this message translates to:
  /// **'Monsoon Season Alert'**
  String get monsoonAlert;

  /// No description provided for @monsoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Prepare your fields for heavy rainfall. Ensure proper drainage channels are clear and ready for the upcoming monsoon rains.'**
  String get monsoonMessage;

  /// No description provided for @playAudio.
  ///
  /// In en, this message translates to:
  /// **'Play Audio'**
  String get playAudio;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @scattered.
  ///
  /// In en, this message translates to:
  /// **'Scattered Showers'**
  String get scattered;

  /// No description provided for @nowLabel.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowLabel;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @wateredToday.
  ///
  /// In en, this message translates to:
  /// **'Watered today'**
  String get wateredToday;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @rice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get rice;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @coconut.
  ///
  /// In en, this message translates to:
  /// **'Coconut'**
  String get coconut;

  /// No description provided for @riceField.
  ///
  /// In en, this message translates to:
  /// **'Rice Field'**
  String get riceField;

  /// No description provided for @startedMay.
  ///
  /// In en, this message translates to:
  /// **'Started: May 15'**
  String get startedMay;

  /// No description provided for @startedJun.
  ///
  /// In en, this message translates to:
  /// **'Started: Jun 02'**
  String get startedJun;

  /// No description provided for @startedApr.
  ///
  /// In en, this message translates to:
  /// **'Started: Apr 10'**
  String get startedApr;

  /// No description provided for @roadmap.
  ///
  /// In en, this message translates to:
  /// **'Roadmap'**
  String get roadmap;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String week(Object number);

  /// No description provided for @prepareNursery.
  ///
  /// In en, this message translates to:
  /// **'Prepare nursery'**
  String get prepareNursery;

  /// No description provided for @irrigateBeds.
  ///
  /// In en, this message translates to:
  /// **'Irrigate beds'**
  String get irrigateBeds;

  /// No description provided for @transplantSeedlings.
  ///
  /// In en, this message translates to:
  /// **'Transplant seedlings'**
  String get transplantSeedlings;

  /// No description provided for @applyUrea.
  ///
  /// In en, this message translates to:
  /// **'Apply urea'**
  String get applyUrea;

  /// No description provided for @checkLeafSpot.
  ///
  /// In en, this message translates to:
  /// **'Check for leaf spot'**
  String get checkLeafSpot;

  /// No description provided for @todaysTasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todaysTasks;

  /// No description provided for @yesterdaysTasks.
  ///
  /// In en, this message translates to:
  /// **'Yesterday\'s Tasks'**
  String get yesterdaysTasks;

  /// No description provided for @tasksFor.
  ///
  /// In en, this message translates to:
  /// **'Tasks for {date}'**
  String tasksFor(Object date);

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get noTasks;

  /// No description provided for @futureTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'Future tasks will be available on their scheduled date'**
  String get futureTaskMessage;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'DISMISS'**
  String get dismiss;

  /// No description provided for @applyFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Apply organic fertilizer'**
  String get applyFertilizer;

  /// No description provided for @irrigationCheck.
  ///
  /// In en, this message translates to:
  /// **'Irrigation check'**
  String get irrigationCheck;

  /// No description provided for @pestMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Pest monitoring'**
  String get pestMonitoring;

  /// No description provided for @harvestPlanning.
  ///
  /// In en, this message translates to:
  /// **'Harvest planning'**
  String get harvestPlanning;

  /// No description provided for @soilTesting.
  ///
  /// In en, this message translates to:
  /// **'Soil testing'**
  String get soilTesting;

  /// No description provided for @riceProject.
  ///
  /// In en, this message translates to:
  /// **'Rice Cultivation Project'**
  String get riceProject;

  /// No description provided for @weatherConditionsOptimal.
  ///
  /// In en, this message translates to:
  /// **'Weather conditions are optimal for field operations today.'**
  String get weatherConditionsOptimal;

  /// No description provided for @weatherConditionsSuitable.
  ///
  /// In en, this message translates to:
  /// **'Weather conditions were suitable for field activities.'**
  String get weatherConditionsSuitable;

  /// No description provided for @soilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get soilMoisture;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @fieldConditions.
  ///
  /// In en, this message translates to:
  /// **'Field Conditions'**
  String get fieldConditions;

  /// No description provided for @sunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get sunny;

  /// No description provided for @cloudy.
  ///
  /// In en, this message translates to:
  /// **'Was Cloudy'**
  String get cloudy;

  /// No description provided for @todaysAdvisory.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Advisory'**
  String get todaysAdvisory;

  /// No description provided for @advisoryFor.
  ///
  /// In en, this message translates to:
  /// **'Advisory for'**
  String get advisoryFor;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with our support team'**
  String get supportSubtitle;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @projectCount.
  ///
  /// In en, this message translates to:
  /// **'24 Projects'**
  String get projectCount;

  /// No description provided for @sinceJan.
  ///
  /// In en, this message translates to:
  /// **'Since Jan 2024'**
  String get sinceJan;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @helpMessage.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get helpMessage;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message Sent'**
  String get messageSent;

  /// No description provided for @thankYouMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for contacting us! We\'ll get back to you within 24 hours.'**
  String get thankYouMessage;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get fillAllFields;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'മലയാളം'**
  String get malayalam;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @faqLanguage.
  ///
  /// In en, this message translates to:
  /// **'How do I change the app language?'**
  String get faqLanguage;

  /// No description provided for @faqLanguageAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings and tap on the Language option. Select between English or Malayalam. The app will update to your chosen language instantly.'**
  String get faqLanguageAnswer;

  /// No description provided for @faqNotifications.
  ///
  /// In en, this message translates to:
  /// **'How do I enable or disable notifications?'**
  String get faqNotifications;

  /// No description provided for @faqNotificationsAnswer.
  ///
  /// In en, this message translates to:
  /// **'In Settings, use the Notifications switch to turn notifications on or off. You will receive updates about your projects and important information based on your preference.'**
  String get faqNotificationsAnswer;

  /// No description provided for @faqProfile.
  ///
  /// In en, this message translates to:
  /// **'How do I edit my profile information?'**
  String get faqProfile;

  /// No description provided for @faqProfileAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings and tap the edit icon on your profile section. You can change your name and profile picture by tapping on the camera icon.'**
  String get faqProfileAnswer;

  /// No description provided for @faqProjects.
  ///
  /// In en, this message translates to:
  /// **'How do I add or manage my agricultural projects?'**
  String get faqProjects;

  /// No description provided for @faqProjectsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Use the main dashboard to add new projects. You can track progress, add notes, and manage multiple farming activities from the projects section.'**
  String get faqProjectsAnswer;

  /// No description provided for @faqPerformance.
  ///
  /// In en, this message translates to:
  /// **'What should I do if the app is running slowly?'**
  String get faqPerformance;

  /// No description provided for @faqPerformanceAnswer.
  ///
  /// In en, this message translates to:
  /// **'Try closing and reopening the app. If the issue persists, restart your device. For continued problems, contact support.'**
  String get faqPerformanceAnswer;

  /// No description provided for @faqFarmingHelp.
  ///
  /// In en, this message translates to:
  /// **'How can I get help with farming techniques?'**
  String get faqFarmingHelp;

  /// No description provided for @faqFarmingHelpAnswer.
  ///
  /// In en, this message translates to:
  /// **'Use the Chatbot feature for instant farming advice, or visit the Forum section to connect with other farmers and share experiences.'**
  String get faqFarmingHelpAnswer;

  /// No description provided for @chatGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! How can I assist you today with your farming needs?'**
  String get chatGreeting;

  /// No description provided for @chatPestQuery.
  ///
  /// In en, this message translates to:
  /// **'I\'m having trouble with pests on my tomato plants, Can you help?'**
  String get chatPestQuery;

  /// No description provided for @chatPestResponse.
  ///
  /// In en, this message translates to:
  /// **'Of course! To better understand the issue, could you describe the pests or upload a photo of the affected plants?'**
  String get chatPestResponse;

  /// No description provided for @chatAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your message. I\'m analyzing your query and will provide you with the best farming advice!'**
  String get chatAnalyzing;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about farming...'**
  String get chatInputHint;

  /// No description provided for @selectAttachment.
  ///
  /// In en, this message translates to:
  /// **'Select Attachment'**
  String get selectAttachment;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @krishiAssist.
  ///
  /// In en, this message translates to:
  /// **'Krishi Assist'**
  String get krishiAssist;

  /// No description provided for @pests.
  ///
  /// In en, this message translates to:
  /// **'Pests'**
  String get pests;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @landSize.
  ///
  /// In en, this message translates to:
  /// **'Land Size (acres)'**
  String get landSize;

  /// No description provided for @cropType.
  ///
  /// In en, this message translates to:
  /// **'Crop Type'**
  String get cropType;

  /// No description provided for @variety.
  ///
  /// In en, this message translates to:
  /// **'Variety'**
  String get variety;

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilType;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Farming Experience (years)'**
  String get experience;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @novice.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get novice;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Project'**
  String get submit;

  /// No description provided for @wheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get wheat;

  /// No description provided for @corn.
  ///
  /// In en, this message translates to:
  /// **'Corn'**
  String get corn;

  /// No description provided for @soybeans.
  ///
  /// In en, this message translates to:
  /// **'Soybeans'**
  String get soybeans;

  /// No description provided for @cotton.
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get cotton;

  /// No description provided for @sugarcane.
  ///
  /// In en, this message translates to:
  /// **'Sugarcane'**
  String get sugarcane;

  /// No description provided for @barley.
  ///
  /// In en, this message translates to:
  /// **'Barley'**
  String get barley;

  /// No description provided for @oats.
  ///
  /// In en, this message translates to:
  /// **'Oats'**
  String get oats;

  /// No description provided for @clay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get clay;

  /// No description provided for @sandy.
  ///
  /// In en, this message translates to:
  /// **'Sandy'**
  String get sandy;

  /// No description provided for @loamy.
  ///
  /// In en, this message translates to:
  /// **'Loamy'**
  String get loamy;

  /// No description provided for @silty.
  ///
  /// In en, this message translates to:
  /// **'Silty'**
  String get silty;

  /// No description provided for @peaty.
  ///
  /// In en, this message translates to:
  /// **'Peaty'**
  String get peaty;

  /// No description provided for @chalky.
  ///
  /// In en, this message translates to:
  /// **'Chalky'**
  String get chalky;

  /// No description provided for @saline.
  ///
  /// In en, this message translates to:
  /// **'Saline'**
  String get saline;

  /// No description provided for @schemeSubsidy.
  ///
  /// In en, this message translates to:
  /// **'Subsidies for micro-irrigation systems'**
  String get schemeSubsidy;

  /// No description provided for @schemeSubsidySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 55% subsidy available'**
  String get schemeSubsidySubtitle;

  /// No description provided for @schemeDeadline.
  ///
  /// In en, this message translates to:
  /// **'Apply before September 25'**
  String get schemeDeadline;

  /// No description provided for @marketUpdate.
  ///
  /// In en, this message translates to:
  /// **'Coconut prices reach ₹40 per piece'**
  String get marketUpdate;

  /// No description provided for @marketSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local mandi rates updated'**
  String get marketSubtitle;

  /// No description provided for @openNavigationMenu.
  ///
  /// In en, this message translates to:
  /// **'Open navigation menu'**
  String get openNavigationMenu;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @irrigationNeeded.
  ///
  /// In en, this message translates to:
  /// **'Irrigation needed'**
  String get irrigationNeeded;

  /// No description provided for @riceMSPUpdate.
  ///
  /// In en, this message translates to:
  /// **'Rice MSP increased to ₹2,183/quintal'**
  String get riceMSPUpdate;

  /// No description provided for @mspEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective from October 1st'**
  String get mspEffectiveDate;

  /// No description provided for @pmKisanUpdate.
  ///
  /// In en, this message translates to:
  /// **'PM Kisan: 15th installment dates announced'**
  String get pmKisanUpdate;

  /// No description provided for @thrissurLocation.
  ///
  /// In en, this message translates to:
  /// **'Thrissur'**
  String get thrissurLocation;

  /// No description provided for @currentTemperature.
  ///
  /// In en, this message translates to:
  /// **'28°C'**
  String get currentTemperature;

  /// No description provided for @timeSlot3PM.
  ///
  /// In en, this message translates to:
  /// **'3PM'**
  String get timeSlot3PM;

  /// No description provided for @timeSlot4PM.
  ///
  /// In en, this message translates to:
  /// **'4PM'**
  String get timeSlot4PM;

  /// No description provided for @timeSlot5PM.
  ///
  /// In en, this message translates to:
  /// **'5PM'**
  String get timeSlot5PM;

  /// No description provided for @timeSlot6PM.
  ///
  /// In en, this message translates to:
  /// **'6PM'**
  String get timeSlot6PM;

  /// No description provided for @fieldSuffix.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get fieldSuffix;

  /// No description provided for @noTasksForDay.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get noTasksForDay;

  /// No description provided for @weatherOptimal.
  ///
  /// In en, this message translates to:
  /// **'Weather conditions are optimal for field operations today.'**
  String get weatherOptimal;

  /// No description provided for @weatherSuitable.
  ///
  /// In en, this message translates to:
  /// **'Weather conditions were suitable for field activities.'**
  String get weatherSuitable;

  /// No description provided for @pestAlert.
  ///
  /// In en, this message translates to:
  /// **'Pest Alert'**
  String get pestAlert;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @mediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get mediumRisk;

  /// No description provided for @leafFolderDetected.
  ///
  /// In en, this message translates to:
  /// **'Leaf Folder detected in nearby fields. Consider preventative measures within 48 hours.'**
  String get leafFolderDetected;

  /// No description provided for @brownPlantHopper.
  ///
  /// In en, this message translates to:
  /// **'Brown Plant Hopper risks were monitored and controlled.'**
  String get brownPlantHopper;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @irrigationOptimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal time for irrigation is before 10:00 AM today'**
  String get irrigationOptimal;

  /// No description provided for @fieldIrrigationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Field irrigation was completed'**
  String get fieldIrrigationCompleted;

  /// No description provided for @monitorPestActivity.
  ///
  /// In en, this message translates to:
  /// **'Monitor field edges for pest activity'**
  String get monitorPestActivity;

  /// No description provided for @pestMonitoringConducted.
  ///
  /// In en, this message translates to:
  /// **'Pest monitoring was conducted'**
  String get pestMonitoringConducted;

  /// No description provided for @considerFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Consider fertilizer application in Section B'**
  String get considerFertilizer;

  /// No description provided for @fieldNutrientsOptimal.
  ///
  /// In en, this message translates to:
  /// **'Field nutrients were at optimal levels'**
  String get fieldNutrientsOptimal;

  /// No description provided for @wasCloudy.
  ///
  /// In en, this message translates to:
  /// **'Was Cloudy'**
  String get wasCloudy;

  /// No description provided for @time9AM.
  ///
  /// In en, this message translates to:
  /// **'9:00 AM'**
  String get time9AM;

  /// No description provided for @time1130AM.
  ///
  /// In en, this message translates to:
  /// **'11:30 AM'**
  String get time1130AM;

  /// No description provided for @time2PM.
  ///
  /// In en, this message translates to:
  /// **'2:00 PM'**
  String get time2PM;

  /// No description provided for @time430PM.
  ///
  /// In en, this message translates to:
  /// **'4:30 PM'**
  String get time430PM;

  /// No description provided for @time10AM.
  ///
  /// In en, this message translates to:
  /// **'10:00 AM'**
  String get time10AM;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Krishi Sakhi'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your Farming Companion'**
  String get tagline;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'Raj Kumar'**
  String get defaultUserName;

  /// No description provided for @malayalamLanguage.
  ///
  /// In en, this message translates to:
  /// **'മലയാളം'**
  String get malayalamLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ml': return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
