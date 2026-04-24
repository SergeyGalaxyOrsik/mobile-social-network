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
  String get mainNavFriends => 'Друзья';

  @override
  String get mainNavProfile => 'Профиль';

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
  String get postShareTooltip => 'Поделиться';

  @override
  String get postShareFailed => 'Не удалось поделиться';

  @override
  String get retry => 'Повторить';

  @override
  String get noCommentsYet => 'Пока нет комментариев.';

  @override
  String get userSearchTitle => 'Люди';

  @override
  String get userSearchHint => 'Поиск по нику';

  @override
  String get userSearchTooltip => 'Поиск пользователей';

  @override
  String get friendRequestsTitle => 'Заявки в друзья';

  @override
  String get friendRequestsTooltip => 'Заявки в друзья';

  @override
  String get friendRequestsSearchTab => 'Поиск';

  @override
  String get friendRequestsIncomingTab => 'Входящие';

  @override
  String get friendRequestsOutgoingTab => 'Исходящие';

  @override
  String get friendRequestsEmptyIncoming => 'Нет входящих заявок';

  @override
  String get friendRequestsEmptyOutgoing => 'Нет исходящих заявок';

  @override
  String get friendRequestsAccept => 'Принять';

  @override
  String get friendRequestsDecline => 'Отклонить';

  @override
  String get friendRequestsCancel => 'Отменить заявку';

  @override
  String get profileBio => 'О себе';

  @override
  String get profileBirthDate => 'Дата рождения';

  @override
  String get relationshipSelf => 'Ваш профиль';

  @override
  String get relationshipFriend => 'Друзья';

  @override
  String get relationshipOutgoingFR => 'Заявка отправлена';

  @override
  String get relationshipIncomingFR => 'Хочет дружить';

  @override
  String get relationshipFollowing => 'Вы подписаны';

  @override
  String get relationshipNone => 'Нет связи';

  @override
  String get profileAddFriend => 'В друзья';

  @override
  String get profileCancelRequest => 'Отменить заявку';

  @override
  String get profileAccept => 'Принять';

  @override
  String get profileDecline => 'Отклонить';

  @override
  String get profilePosts => 'Посты';

  @override
  String get profileNoPosts => 'Нет постов для отображения';

  @override
  String get profileLoadMore => 'Ещё';

  @override
  String get reportUserAction => 'Пожаловаться';

  @override
  String get reportUserSheetTitle => 'Жалоба на пользователя';

  @override
  String get reportReasonSpam => 'Спам';

  @override
  String get reportReasonHarassment => 'Домогательство';

  @override
  String get reportReasonHate => 'Ненависть';

  @override
  String get reportReasonImpersonation => 'Выдача себя за другого';

  @override
  String get reportReasonNudity => 'Нагота';

  @override
  String get reportReasonScam => 'Мошенничество';

  @override
  String get reportReasonOther => 'Другое';

  @override
  String get reportDetailsLabel => 'Пояснение (необязательно)';

  @override
  String get reportSubmit => 'Отправить жалобу';

  @override
  String get snackBecameFriends => 'Вы теперь друзья';

  @override
  String get snackRequestSent => 'Заявка отправлена';

  @override
  String get snackRequestCancelled => 'Заявка отменена';

  @override
  String get snackRequestAccepted => 'Заявка принята';

  @override
  String get snackRequestDeclined => 'Заявка отклонена';

  @override
  String get snackReportSubmitted => 'Жалоба отправлена';

  @override
  String get errorIncomingRequestNotFound =>
      'Заявка не найдена. Откройте список заявок.';

  @override
  String get errorOutgoingRequestNotFound => 'Исходящая заявка не найдена.';

  @override
  String get pushNotificationOpenAction => 'Открыть';

  @override
  String get pushNotificationFriendRequestTitle => 'Заявка в друзья';

  @override
  String pushNotificationFriendRequestBody(String name) {
    return '$name отправил(а) вам заявку в друзья';
  }

  @override
  String get pushNotificationFriendAddedTitle => 'Новый друг';

  @override
  String pushNotificationFriendAddedBody(String name) {
    return 'Вы теперь друзья с $name';
  }

  @override
  String get pushNotificationFriendPostTitle => 'Новый пост';

  @override
  String pushNotificationFriendPostBody(String name) {
    return '$name опубликовал(а) пост';
  }

  @override
  String get friendListTab => 'Мои друзья';

  @override
  String get friendsListQueryHint => 'Поиск среди друзей по нику и био';

  @override
  String get friendsListUsernamePrefixHint =>
      'Ник начинается с (необязательно)';

  @override
  String get friendsListFriendshipAfter => 'Дружба с (дата)';

  @override
  String get friendsListFriendshipBefore => 'Дружба до (не включая)';

  @override
  String get friendsListSortLabel => 'Сортировка';

  @override
  String get friendsListSortRelevance => 'Релевантность (нечёткий поиск)';

  @override
  String get friendsListSortUsernameAsc => 'Ник А–Я';

  @override
  String get friendsListSortUsernameDesc => 'Ник Я–А';

  @override
  String get friendsListSortFriendshipCreatedAsc => 'Дружба: сначала старые';

  @override
  String get friendsListSortFriendshipCreatedDesc => 'Дружба: сначала новые';

  @override
  String get friendsListApply => 'Применить';

  @override
  String get friendsListClearFilters => 'Сбросить';

  @override
  String get friendsListEmpty => 'Нет друзей по заданным фильтрам';

  @override
  String get friendsListLoadMore => 'Ещё';

  @override
  String get postSearchTitle => 'Поиск постов';

  @override
  String get postSearchQueryHint => 'Текст в посте';

  @override
  String get postSearchAuthorIdHint => 'ID автора (необязательно)';

  @override
  String get postSearchSortLabel => 'Сортировка';

  @override
  String get postSearchSortDefault => 'По умолчанию (от запроса)';

  @override
  String get postSearchSortRelevance => 'Релевантность (нечёткий поиск)';

  @override
  String get postSearchSortCreatedDesc => 'Сначала новые';

  @override
  String get postSearchSortCreatedAsc => 'Сначала старые';

  @override
  String get postSearchSortLikesDesc => 'Больше лайков';

  @override
  String get postSearchSortCommentsDesc => 'Больше комментариев';

  @override
  String get postSearchVisibilityLabel => 'Видимость';

  @override
  String get postSearchVisibilityAny => 'Любая';

  @override
  String get postSearchVisibilityPublic => 'Публичные';

  @override
  String get postSearchVisibilityPrivate => 'Приватные';

  @override
  String get postSearchVisibilityFollowers => 'Подписчики';

  @override
  String get postSearchEmpty => 'Посты не найдены';

  @override
  String get feedSearchPostsTooltip => 'Поиск постов';

  @override
  String get chatConversationsTitle => 'Сообщения';

  @override
  String get chatConversationsEmpty => 'Пока нет диалогов';

  @override
  String get chatOpenThread => 'Открыть чат';

  @override
  String get chatPeerFallback => 'Пользователь';

  @override
  String get chatMessageHint => 'Сообщение';

  @override
  String get chatSend => 'Отправить';

  @override
  String get chatLoadOlder => 'Раньше';

  @override
  String get chatDeleteMessage => 'Удалить сообщение';

  @override
  String get chatBlockUser => 'Заблокировать';

  @override
  String get chatBlockedUsersTitle => 'Заблокированные';

  @override
  String get chatUnblock => 'Разблокировать';

  @override
  String get chatBlocksEmpty => 'Никого не блокировали';

  @override
  String get chatBlockConfirmTitle => 'Заблокировать пользователя?';

  @override
  String get chatBlockConfirmBody =>
      'Чат будет недоступен, пока вы не снимете блокировку в настройках.';

  @override
  String get chatBlockConfirmAction => 'Заблокировать';

  @override
  String get chatMediaAttach => 'Фото или видео';

  @override
  String get chatAttachSheetTitle => 'Вложение';

  @override
  String get chatAttachCamera => 'Снять фото';

  @override
  String get chatAttachGallery => 'Галерея';

  @override
  String get chatAttachLimitReached => 'Не больше 10 вложений';

  @override
  String get chatErrorFileTooLarge => 'Файл слишком большой';

  @override
  String get chatErrorMediaType => 'Допустимы только изображения и видео';
}
