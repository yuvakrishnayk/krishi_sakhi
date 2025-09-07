// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Krishi Sakhi';

  @override
  String get drawerHome => 'Home';

  @override
  String get drawerLearningChat => 'Learning Chat';

  @override
  String get drawerCourses => 'Courses';

  @override
  String get drawerForum => 'Forum';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get userName => 'Raj Kumar';

  @override
  String projectsCount(Object count) {
    return 'Projects: $count';
  }

  @override
  String get sinceDate => 'Since: Jan 2024';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutQuestion => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose Language';
}
