import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Social Network'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @mainNavFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get mainNavFriends;

  /// No description provided for @mainNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get mainNavProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello,\n{name}!'**
  String helloUser(String name);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccountRegister;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @displayNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get displayNameOptional;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get displayName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname'**
  String get enterName;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be at least 2 characters'**
  String get usernameMinLength;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountSignIn;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageRu.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRu;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @postButton.
  ///
  /// In en, this message translates to:
  /// **'POST'**
  String get postButton;

  /// No description provided for @createPostPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'WHAT\'S ON YOUR MIND?'**
  String get createPostPlaceholder;

  /// No description provided for @createPostCharCount.
  ///
  /// In en, this message translates to:
  /// **'CHR_COUNT: {current}/{max}'**
  String createPostCharCount(String current, String max);

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get createPost;

  /// No description provided for @uploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get uploadMedia;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editPost;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePost;

  /// No description provided for @editPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get editPostTitle;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveChanges;

  /// No description provided for @deletePostConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete post?'**
  String get deletePostConfirmTitle;

  /// No description provided for @deletePostConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deletePostConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @sendComment.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendComment;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment…'**
  String get commentHint;

  /// No description provided for @commentUserShort.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get commentUserShort;

  /// No description provided for @likeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeTooltip;

  /// No description provided for @commentsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTooltip;

  /// No description provided for @postShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get postShareTooltip;

  /// No description provided for @postShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share this post'**
  String get postShareFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get noCommentsYet;

  /// No description provided for @userSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Find people'**
  String get userSearchTitle;

  /// No description provided for @userSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by username'**
  String get userSearchHint;

  /// No description provided for @userSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get userSearchTooltip;

  /// No description provided for @friendRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend requests'**
  String get friendRequestsTitle;

  /// No description provided for @friendRequestsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Friend requests'**
  String get friendRequestsTooltip;

  /// No description provided for @friendRequestsSearchTab.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get friendRequestsSearchTab;

  /// No description provided for @friendRequestsIncomingTab.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get friendRequestsIncomingTab;

  /// No description provided for @friendRequestsOutgoingTab.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get friendRequestsOutgoingTab;

  /// No description provided for @friendRequestsEmptyIncoming.
  ///
  /// In en, this message translates to:
  /// **'No incoming requests'**
  String get friendRequestsEmptyIncoming;

  /// No description provided for @friendRequestsEmptyOutgoing.
  ///
  /// In en, this message translates to:
  /// **'No outgoing requests'**
  String get friendRequestsEmptyOutgoing;

  /// No description provided for @friendRequestsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friendRequestsAccept;

  /// No description provided for @friendRequestsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get friendRequestsDecline;

  /// No description provided for @friendRequestsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get friendRequestsCancel;

  /// No description provided for @profileBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBio;

  /// No description provided for @profileBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get profileBirthDate;

  /// No description provided for @relationshipSelf.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get relationshipSelf;

  /// No description provided for @relationshipFriend.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get relationshipFriend;

  /// No description provided for @relationshipOutgoingFR.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get relationshipOutgoingFR;

  /// No description provided for @relationshipIncomingFR.
  ///
  /// In en, this message translates to:
  /// **'Wants to be friends'**
  String get relationshipIncomingFR;

  /// No description provided for @relationshipFollowing.
  ///
  /// In en, this message translates to:
  /// **'You follow'**
  String get relationshipFollowing;

  /// No description provided for @relationshipNone.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get relationshipNone;

  /// No description provided for @profileAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get profileAddFriend;

  /// No description provided for @profileCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get profileCancelRequest;

  /// No description provided for @profileAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get profileAccept;

  /// No description provided for @profileDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get profileDecline;

  /// No description provided for @profilePosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profilePosts;

  /// No description provided for @profileNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts to show'**
  String get profileNoPosts;

  /// No description provided for @profileLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get profileLoadMore;

  /// No description provided for @reportUserAction.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportUserAction;

  /// No description provided for @reportUserSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get reportUserSheetTitle;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonHate.
  ///
  /// In en, this message translates to:
  /// **'Hate'**
  String get reportReasonHate;

  /// No description provided for @reportReasonImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Impersonation'**
  String get reportReasonImpersonation;

  /// No description provided for @reportReasonNudity.
  ///
  /// In en, this message translates to:
  /// **'Nudity'**
  String get reportReasonNudity;

  /// No description provided for @reportReasonScam.
  ///
  /// In en, this message translates to:
  /// **'Scam'**
  String get reportReasonScam;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @reportDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get reportDetailsLabel;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// No description provided for @snackBecameFriends.
  ///
  /// In en, this message translates to:
  /// **'You are now friends'**
  String get snackBecameFriends;

  /// No description provided for @snackRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get snackRequestSent;

  /// No description provided for @snackRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get snackRequestCancelled;

  /// No description provided for @snackRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request accepted'**
  String get snackRequestAccepted;

  /// No description provided for @snackRequestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get snackRequestDeclined;

  /// No description provided for @snackReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get snackReportSubmitted;

  /// No description provided for @errorIncomingRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find this request. Open the requests list.'**
  String get errorIncomingRequestNotFound;

  /// No description provided for @errorOutgoingRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find your outgoing request.'**
  String get errorOutgoingRequestNotFound;

  /// No description provided for @pushNotificationOpenAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pushNotificationOpenAction;

  /// No description provided for @pushNotificationFriendRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend request'**
  String get pushNotificationFriendRequestTitle;

  /// No description provided for @pushNotificationFriendRequestBody.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a friend request'**
  String pushNotificationFriendRequestBody(String name);

  /// No description provided for @pushNotificationFriendAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'New friend'**
  String get pushNotificationFriendAddedTitle;

  /// No description provided for @pushNotificationFriendAddedBody.
  ///
  /// In en, this message translates to:
  /// **'You are now friends with {name}'**
  String pushNotificationFriendAddedBody(String name);

  /// No description provided for @pushNotificationFriendPostTitle.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get pushNotificationFriendPostTitle;

  /// No description provided for @pushNotificationFriendPostBody.
  ///
  /// In en, this message translates to:
  /// **'{name} published a post'**
  String pushNotificationFriendPostBody(String name);

  /// No description provided for @friendListTab.
  ///
  /// In en, this message translates to:
  /// **'My friends'**
  String get friendListTab;

  /// No description provided for @friendsListQueryHint.
  ///
  /// In en, this message translates to:
  /// **'Search friends by username or bio'**
  String get friendsListQueryHint;

  /// No description provided for @friendsListUsernamePrefixHint.
  ///
  /// In en, this message translates to:
  /// **'Username starts with (optional)'**
  String get friendsListUsernamePrefixHint;

  /// No description provided for @friendsListFriendshipAfter.
  ///
  /// In en, this message translates to:
  /// **'Friends since (from)'**
  String get friendsListFriendshipAfter;

  /// No description provided for @friendsListFriendshipBefore.
  ///
  /// In en, this message translates to:
  /// **'Friends until (before)'**
  String get friendsListFriendshipBefore;

  /// No description provided for @friendsListSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get friendsListSortLabel;

  /// No description provided for @friendsListSortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance (fuzzy)'**
  String get friendsListSortRelevance;

  /// No description provided for @friendsListSortUsernameAsc.
  ///
  /// In en, this message translates to:
  /// **'Username A–Z'**
  String get friendsListSortUsernameAsc;

  /// No description provided for @friendsListSortUsernameDesc.
  ///
  /// In en, this message translates to:
  /// **'Username Z–A'**
  String get friendsListSortUsernameDesc;

  /// No description provided for @friendsListSortFriendshipCreatedAsc.
  ///
  /// In en, this message translates to:
  /// **'Friendship: oldest first'**
  String get friendsListSortFriendshipCreatedAsc;

  /// No description provided for @friendsListSortFriendshipCreatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Friendship: newest first'**
  String get friendsListSortFriendshipCreatedDesc;

  /// No description provided for @friendsListApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get friendsListApply;

  /// No description provided for @friendsListClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get friendsListClearFilters;

  /// No description provided for @friendsListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No friends match the filters'**
  String get friendsListEmpty;

  /// No description provided for @friendsListLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get friendsListLoadMore;

  /// No description provided for @postSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search posts'**
  String get postSearchTitle;

  /// No description provided for @postSearchQueryHint.
  ///
  /// In en, this message translates to:
  /// **'Search in post text'**
  String get postSearchQueryHint;

  /// No description provided for @postSearchAuthorIdHint.
  ///
  /// In en, this message translates to:
  /// **'Author user ID (optional)'**
  String get postSearchAuthorIdHint;

  /// No description provided for @postSearchSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get postSearchSortLabel;

  /// No description provided for @postSearchSortDefault.
  ///
  /// In en, this message translates to:
  /// **'Default (by query)'**
  String get postSearchSortDefault;

  /// No description provided for @postSearchSortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance (fuzzy)'**
  String get postSearchSortRelevance;

  /// No description provided for @postSearchSortCreatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get postSearchSortCreatedDesc;

  /// No description provided for @postSearchSortCreatedAsc.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get postSearchSortCreatedAsc;

  /// No description provided for @postSearchSortLikesDesc.
  ///
  /// In en, this message translates to:
  /// **'Most likes'**
  String get postSearchSortLikesDesc;

  /// No description provided for @postSearchSortCommentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Most comments'**
  String get postSearchSortCommentsDesc;

  /// No description provided for @postSearchVisibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get postSearchVisibilityLabel;

  /// No description provided for @postSearchVisibilityAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get postSearchVisibilityAny;

  /// No description provided for @postSearchVisibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get postSearchVisibilityPublic;

  /// No description provided for @postSearchVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get postSearchVisibilityPrivate;

  /// No description provided for @postSearchVisibilityFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get postSearchVisibilityFollowers;

  /// No description provided for @postSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get postSearchEmpty;

  /// No description provided for @feedSearchPostsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search posts'**
  String get feedSearchPostsTooltip;

  /// No description provided for @chatConversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatConversationsTitle;

  /// No description provided for @chatConversationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatConversationsEmpty;

  /// No description provided for @chatOpenThread.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get chatOpenThread;

  /// No description provided for @chatPeerFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get chatPeerFallback;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessageHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatLoadOlder.
  ///
  /// In en, this message translates to:
  /// **'Load older'**
  String get chatLoadOlder;

  /// No description provided for @chatDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get chatDeleteMessage;

  /// No description provided for @chatBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get chatBlockUser;

  /// No description provided for @chatBlockedUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get chatBlockedUsersTitle;

  /// No description provided for @chatUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get chatUnblock;

  /// No description provided for @chatBlocksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No blocked users'**
  String get chatBlocksEmpty;

  /// No description provided for @chatBlockConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Block this user?'**
  String get chatBlockConfirmTitle;

  /// No description provided for @chatBlockConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will not be able to chat until you unblock them in settings.'**
  String get chatBlockConfirmBody;

  /// No description provided for @chatBlockConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get chatBlockConfirmAction;

  /// No description provided for @chatMediaAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach photo or video'**
  String get chatMediaAttach;

  /// No description provided for @chatAttachSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get chatAttachSheetTitle;

  /// No description provided for @chatAttachCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get chatAttachCamera;

  /// No description provided for @chatAttachGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get chatAttachGallery;

  /// No description provided for @chatAttachLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to 10 files'**
  String get chatAttachLimitReached;

  /// No description provided for @chatErrorFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is too large'**
  String get chatErrorFileTooLarge;

  /// No description provided for @chatErrorMediaType.
  ///
  /// In en, this message translates to:
  /// **'Only images and videos are allowed'**
  String get chatErrorMediaType;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
