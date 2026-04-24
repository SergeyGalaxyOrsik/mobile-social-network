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
  String get mainNavFriends => 'Friends';

  @override
  String get mainNavProfile => 'Profile';

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
  String get usernameMinLength => 'Nickname must be at least 2 characters';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

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

  @override
  String get postButton => 'POST';

  @override
  String get createPostPlaceholder => 'WHAT\'S ON YOUR MIND?';

  @override
  String createPostCharCount(String current, String max) {
    return 'CHR_COUNT: $current/$max';
  }

  @override
  String get createPost => 'New Post';

  @override
  String get uploadMedia => 'Add photo';

  @override
  String get editPost => 'Edit';

  @override
  String get deletePost => 'Delete';

  @override
  String get editPostTitle => 'Edit post';

  @override
  String get saveChanges => 'Save';

  @override
  String get deletePostConfirmTitle => 'Delete post?';

  @override
  String get deletePostConfirmMessage => 'This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get sendComment => 'Send';

  @override
  String get commentHint => 'Write a comment…';

  @override
  String get commentUserShort => 'User';

  @override
  String get likeTooltip => 'Like';

  @override
  String get commentsTooltip => 'Comments';

  @override
  String get postShareTooltip => 'Share';

  @override
  String get postShareFailed => 'Could not share this post';

  @override
  String get retry => 'Retry';

  @override
  String get noCommentsYet => 'No comments yet.';

  @override
  String get userSearchTitle => 'Find people';

  @override
  String get userSearchHint => 'Search by username';

  @override
  String get userSearchTooltip => 'Search users';

  @override
  String get friendRequestsTitle => 'Friend requests';

  @override
  String get friendRequestsTooltip => 'Friend requests';

  @override
  String get friendRequestsSearchTab => 'Search';

  @override
  String get friendRequestsIncomingTab => 'Incoming';

  @override
  String get friendRequestsOutgoingTab => 'Outgoing';

  @override
  String get friendRequestsEmptyIncoming => 'No incoming requests';

  @override
  String get friendRequestsEmptyOutgoing => 'No outgoing requests';

  @override
  String get friendRequestsAccept => 'Accept';

  @override
  String get friendRequestsDecline => 'Decline';

  @override
  String get friendRequestsCancel => 'Cancel request';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileBirthDate => 'Birth date';

  @override
  String get relationshipSelf => 'Your profile';

  @override
  String get relationshipFriend => 'Friends';

  @override
  String get relationshipOutgoingFR => 'Request sent';

  @override
  String get relationshipIncomingFR => 'Wants to be friends';

  @override
  String get relationshipFollowing => 'You follow';

  @override
  String get relationshipNone => 'No connection';

  @override
  String get profileAddFriend => 'Add friend';

  @override
  String get profileCancelRequest => 'Cancel request';

  @override
  String get profileAccept => 'Accept';

  @override
  String get profileDecline => 'Decline';

  @override
  String get profilePosts => 'Posts';

  @override
  String get profileNoPosts => 'No posts to show';

  @override
  String get profileLoadMore => 'Load more';

  @override
  String get reportUserAction => 'Report';

  @override
  String get reportUserSheetTitle => 'Report user';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Harassment';

  @override
  String get reportReasonHate => 'Hate';

  @override
  String get reportReasonImpersonation => 'Impersonation';

  @override
  String get reportReasonNudity => 'Nudity';

  @override
  String get reportReasonScam => 'Scam';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportDetailsLabel => 'Details (optional)';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get snackBecameFriends => 'You are now friends';

  @override
  String get snackRequestSent => 'Friend request sent';

  @override
  String get snackRequestCancelled => 'Request cancelled';

  @override
  String get snackRequestAccepted => 'Request accepted';

  @override
  String get snackRequestDeclined => 'Request declined';

  @override
  String get snackReportSubmitted => 'Report submitted';

  @override
  String get errorIncomingRequestNotFound =>
      'Could not find this request. Open the requests list.';

  @override
  String get errorOutgoingRequestNotFound =>
      'Could not find your outgoing request.';

  @override
  String get pushNotificationOpenAction => 'Open';

  @override
  String get pushNotificationFriendRequestTitle => 'Friend request';

  @override
  String pushNotificationFriendRequestBody(String name) {
    return '$name sent you a friend request';
  }

  @override
  String get pushNotificationFriendAddedTitle => 'New friend';

  @override
  String pushNotificationFriendAddedBody(String name) {
    return 'You are now friends with $name';
  }

  @override
  String get pushNotificationFriendPostTitle => 'New post';

  @override
  String pushNotificationFriendPostBody(String name) {
    return '$name published a post';
  }

  @override
  String get friendListTab => 'My friends';

  @override
  String get friendsListQueryHint => 'Search friends by username or bio';

  @override
  String get friendsListUsernamePrefixHint => 'Username starts with (optional)';

  @override
  String get friendsListFriendshipAfter => 'Friends since (from)';

  @override
  String get friendsListFriendshipBefore => 'Friends until (before)';

  @override
  String get friendsListSortLabel => 'Sort';

  @override
  String get friendsListSortRelevance => 'Relevance (fuzzy)';

  @override
  String get friendsListSortUsernameAsc => 'Username A–Z';

  @override
  String get friendsListSortUsernameDesc => 'Username Z–A';

  @override
  String get friendsListSortFriendshipCreatedAsc => 'Friendship: oldest first';

  @override
  String get friendsListSortFriendshipCreatedDesc => 'Friendship: newest first';

  @override
  String get friendsListApply => 'Apply';

  @override
  String get friendsListClearFilters => 'Reset';

  @override
  String get friendsListEmpty => 'No friends match the filters';

  @override
  String get friendsListLoadMore => 'Load more';

  @override
  String get postSearchTitle => 'Search posts';

  @override
  String get postSearchQueryHint => 'Search in post text';

  @override
  String get postSearchAuthorIdHint => 'Author user ID (optional)';

  @override
  String get postSearchSortLabel => 'Sort';

  @override
  String get postSearchSortDefault => 'Default (by query)';

  @override
  String get postSearchSortRelevance => 'Relevance (fuzzy)';

  @override
  String get postSearchSortCreatedDesc => 'Newest first';

  @override
  String get postSearchSortCreatedAsc => 'Oldest first';

  @override
  String get postSearchSortLikesDesc => 'Most likes';

  @override
  String get postSearchSortCommentsDesc => 'Most comments';

  @override
  String get postSearchVisibilityLabel => 'Visibility';

  @override
  String get postSearchVisibilityAny => 'Any';

  @override
  String get postSearchVisibilityPublic => 'Public';

  @override
  String get postSearchVisibilityPrivate => 'Private';

  @override
  String get postSearchVisibilityFollowers => 'Followers';

  @override
  String get postSearchEmpty => 'No posts found';

  @override
  String get feedSearchPostsTooltip => 'Search posts';

  @override
  String get chatConversationsTitle => 'Messages';

  @override
  String get chatConversationsEmpty => 'No conversations yet';

  @override
  String get chatOpenThread => 'Open chat';

  @override
  String get chatPeerFallback => 'User';

  @override
  String get chatMessageHint => 'Message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatLoadOlder => 'Load older';

  @override
  String get chatDeleteMessage => 'Delete message';

  @override
  String get chatBlockUser => 'Block user';

  @override
  String get chatBlockedUsersTitle => 'Blocked users';

  @override
  String get chatUnblock => 'Unblock';

  @override
  String get chatBlocksEmpty => 'No blocked users';

  @override
  String get chatBlockConfirmTitle => 'Block this user?';

  @override
  String get chatBlockConfirmBody =>
      'You will not be able to chat until you unblock them in settings.';

  @override
  String get chatBlockConfirmAction => 'Block';

  @override
  String get chatMediaAttach => 'Attach photo or video';

  @override
  String get chatAttachSheetTitle => 'Attachment';

  @override
  String get chatAttachCamera => 'Take photo';

  @override
  String get chatAttachGallery => 'Gallery';

  @override
  String get chatAttachLimitReached => 'You can attach up to 10 files';

  @override
  String get chatErrorFileTooLarge => 'File is too large';

  @override
  String get chatErrorMediaType => 'Only images and videos are allowed';
}
