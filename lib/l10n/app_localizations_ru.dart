// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Социальная сеть';

  @override
  String get home => 'Главная';

  @override
  String get settings => 'Настройки';

  @override
  String get logout => 'Выйти';

  @override
  String helloUser(String name) {
    return 'Привет,\n$name!';
  }

  @override
  String get login => 'Вход';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Введите email';

  @override
  String get password => 'Пароль';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get noAccountRegister => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get register => 'Регистрация';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get displayNameOptional => 'Имя (необязательно)';

  @override
  String get displayName => 'Никнейм';

  @override
  String get enterName => 'Введите никнейм';

  @override
  String get usernameMinLength => 'Никнейм не менее 2 символов';

  @override
  String get passwordMinLength => 'Пароль не менее 8 символов';

  @override
  String get confirmPassword => 'Повторите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get haveAccountSignIn => 'Уже есть аккаунт? Войти';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'English';

  @override
  String get postButton => 'ПОСТ';

  @override
  String get createPostPlaceholder => 'О ЧЁМ ДУМАЕТЕ?';

  @override
  String createPostCharCount(String current, String max) {
    return 'СИМВ: $current/$max';
  }

  @override
  String get createPost => 'New Post';

  @override
  String get uploadMedia => 'Добавить фото';

  @override
  String get editPost => 'Редактировать';

  @override
  String get deletePost => 'Удалить';

  @override
  String get editPostTitle => 'Редактировать пост';

  @override
  String get saveChanges => 'Сохранить';

  @override
  String get deletePostConfirmTitle => 'Удалить пост?';

  @override
  String get deletePostConfirmMessage => 'Действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get noInternetConnection => 'Нет подключения к интернету';

  @override
  String get commentsTitle => 'Комментарии';

  @override
  String get sendComment => 'Отправить';

  @override
  String get commentHint => 'Написать комментарий…';

  @override
  String get commentUserShort => 'Пользователь';

  @override
  String get likeTooltip => 'Нравится';

  @override
  String get commentsTooltip => 'Комментарии';

  @override
  String get retry => 'Повторить';

  @override
  String get noCommentsYet => 'Пока нет комментариев.';
}
