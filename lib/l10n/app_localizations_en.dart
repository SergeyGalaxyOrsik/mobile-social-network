// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Social Network';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Log out';

  @override
  String helloUser(String name) {
    return 'Hello,\n$name!';
  }

  @override
  String get login => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get signIn => 'Sign in';

  @override
  String get noAccountRegister => 'No account? Register';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create account';

  @override
  String get displayNameOptional => 'Name (optional)';

  @override
  String get displayName => 'Nickname';

  @override
  String get enterName => 'Enter nickname';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerButton => 'Register';

  @override
  String get haveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageRu => 'Russian';

  @override
  String get languageEn => 'English';
}
