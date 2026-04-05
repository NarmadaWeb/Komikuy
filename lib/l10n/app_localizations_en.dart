// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSection => 'General';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Get updates for your library';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Select application language';

  @override
  String get storageSection => 'Storage';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheSubtitle => 'Free up space by clearing image cache';

  @override
  String get clearCacheConfirmTitle => 'Clear Cache';

  @override
  String get clearCacheConfirmMessage => 'Are you sure you want to clear the image cache?';

  @override
  String get clearCacheSuccessMessage => 'Image cache cleared successfully';

  @override
  String get aboutSection => 'About';

  @override
  String get aboutKomikuy => 'About Komikuy';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get close => 'Close';
}
