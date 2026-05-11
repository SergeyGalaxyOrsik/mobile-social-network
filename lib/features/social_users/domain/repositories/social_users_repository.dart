import 'package:mobile_social_network/features/social_users/domain/entities/friend_list_item.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/friend_request_item.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/friends_list_sort.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/profile_with_posts.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/send_friend_request_result.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/user_search_result.dart';

abstract class SocialUsersRepository {
  /// Принятые друзья: поиск (trgm + ILIKE), фильтры, сортировка.
  Future<({List<FriendListItem> items, int total})> getFriends({
    String? q,
    FriendsListSort? sort,
    String? usernamePrefix,
    DateTime? friendshipCreatedAfter,
    DateTime? friendshipCreatedBefore,
    int? limit,
    int? offset,
  });

  Future<List<UserSearchResult>> searchUsers({
    required String query,
    int? limit,
    int? offset,
  });

  Future<SendFriendRequestResult> sendFriendRequest(String targetUserId);

  Future<({List<FriendRequestItem> items, int total})>
  getIncomingFriendRequests({int? limit, int? offset});

  Future<({List<FriendRequestItem> items, int total})>
  getOutgoingFriendRequests({int? limit, int? offset});

  Future<void> acceptFriendRequest(String requestId);

  Future<void> declineFriendRequest(String requestId);

  Future<void> cancelOutgoingFriendRequest(String requestId);

  Future<ProfileWithPosts> getUserProfile(
    String profileUserId, {
    int? limit,
    int? offset,
  });

  Future<String> reportUser({
    required String reportedUserId,
    required String reasonCode,
    String? details,
  });

  /// Найти `request_id` входящей pending-заявки от [peerUserId] (до [scanLimit] записей).
  Future<String?> findIncomingRequestIdForPeer(
    String peerUserId, {
    int scanLimit = 50,
  });

  /// Найти `request_id` исходящей pending-заявки к [peerUserId].
  Future<String?> findOutgoingRequestIdForPeer(
    String peerUserId, {
    int scanLimit = 50,
  });
}
