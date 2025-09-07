// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'കൃഷി സഖി';

  @override
  String get drawerHome => 'ഹോം';

  @override
  String get drawerLearningChat => 'ലേണിംഗ് ചാറ്റ്';

  @override
  String get drawerCourses => 'കോഴ്‌സുകൾ';

  @override
  String get drawerForum => 'ഫോറം';

  @override
  String get drawerSettings => 'സെറ്റിംഗ്‌സ്';

  @override
  String get userName => 'രാജ് കുമാർ';

  @override
  String projectsCount(Object count) {
    return 'പ്രോജക്റ്റുകൾ: $count';
  }

  @override
  String get sinceDate => 'ആരംഭം: ജനു 2024';

  @override
  String get signOut => 'പുറത്തുകടക്കുക';

  @override
  String get signOutQuestion => 'നിങ്ങൾക്ക് പുറത്തുകടക്കണമെന്ന് 확定?';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get settings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get language => 'ഭാഷ';

  @override
  String get chooseLanguage => 'ഭാഷ തിരഞ്ഞെടുക്കുക';
}
