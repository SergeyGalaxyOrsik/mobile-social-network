import 'package:mobile_social_network/features/posts/data/mappers/post_response_dto_mapper.dart';
import 'package:mobile_social_network/features/social_users/data/datasources/social_users_remote_datasource.dart';
import 'package:mobile_social_network/features/social_users/data/models/social_users_api_models.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/friend_list_item.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/friend_request_item.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/friends_list_sort.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/profile_relationship.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/profile_with_posts.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/send_friend_request_result.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/user_search_result.dart';
import 'package:mobile_social_network/features/social_users/domain/repositories/social_users_repository.dart';

class SocialUsersRepositoryImpl implements SocialUsersRepository {
  SocialUsersRepositoryImpl(this._remote);

  final SocialUsersRemoteDataSource _remote;

  @override
  Future<({List<FriendListItem> items, int total})> getFriends({
    String? q,
    FriendsListSort? sort,
    String? usernamePrefix,
    DateTime? friendshipCreatedAfter,
    DateTime? friendshipCreatedBefore,
    int? limit,
    int? offset,
  }) async {
    final dto = await _remote.getFriends(
      q: q,
      sort: sort,
      usernamePrefix: usernamePrefix,
      friendshipCreatedAfter: friendshipCreatedAfter,
      friendshipCreatedBefore: friendshipCreatedBefore,
      limit: limit,
      offset: offset,
    );
    return (
      items: dto.items
          .map(
            (e) => FriendListItem(
              userId: e.userId,
              username: e.username,
              bio: e.bio,
              avatarMediaId: e.avatar.mediaId,
              avatarUrl: e.avatar.url,
              friendshipCreatedAt: e.friendshipCreatedAt,
            ),
          )
          .toList(),
      total: dto.total,
    );
  }

  @override
  Future<List<UserSearchResult>> searchUsers({
    required String query,
    int? limit,
    int? offset,
  }) async {
    final dto = await _remote.searchUsers(q: query, limit: limit, offset: offset);
    return dto.items
        .map(
          (e) => UserSearchResult(
            userId: e.userId,
            username: e.username,
            bio: e.bio,
          ),
        )
        .toList();
  }

  @override
  Future<SendFriendRequestResult> sendFriendRequest(String targetUserId) async {
    final dto = await _remote.sendFriendRequest(targetUserId);
    final outcome = dto.outcome == FriendRequestOutcomeDto.friends
        ? SendFriendRequestOutcome.friends
        : SendFriendRequestOutcome.pending;
    return SendFriendRequestResult(outcome: outcome, requestId: dto.requestId);
  }

  @override
  Future<({List<FriendRequestItem> items, int total})> getIncomingFriendRequests({
    int? limit,
    int? offset,
  }) async {
    final dto = await _remote.getIncomingFriendRequests(limit: limit, offset: offset);
    return (
      items: dto.items
          .map(
            (e) => FriendRequestItem(
              requestId: e.requestId,
              peerUserId: e.peerUserId,
              peerUsername: e.peerUsername,
              createdAt: e.createdAt,
              incoming: true,
            ),
          )
          .toList(),
      total: dto.total,
    );
  }

  @override
  Future<({List<FriendRequestItem> items, int total})> getOutgoingFriendRequests({
    int? limit,
    int? offset,
  }) async {
    final dto = await _remote.getOutgoingFriendRequests(limit: limit, offset: offset);
    return (
      items: dto.items
          .map(
            (e) => FriendRequestItem(
              requestId: e.requestId,
              peerUserId: e.peerUserId,
              peerUsername: e.peerUsername,
              createdAt: e.createdAt,
              incoming: false,
            ),
          )
          .toList(),
      total: dto.total,
    );
  }

  @override
  Future<void> acceptFriendRequest(String requestId) {
    return _remote.acceptFriendRequest(requestId);
  }

  @override
  Future<void> declineFriendRequest(String requestId) {
    return _remote.declineFriendRequest(requestId);
  }

  @override
  Future<void> cancelOutgoingFriendRequest(String requestId) {
    return _remote.cancelOutgoingFriendRequest(requestId);
  }

  @override
  Future<ProfileWithPosts> getUserProfile(
    String profileUserId, {
    int? limit,
    int? offset,
  }) async {
    final dto = await _remote.getUserProfile(
      profileUserId,
      limit: limit,
      offset: offset,
    );
    return ProfileWithPosts(
      userId: dto.userId,
      username: dto.username,
      bio: dto.bio,
      birthDate: dto.birthDate,
      avatarMediaId: dto.avatar.mediaId,
      avatarUrl: dto.avatar.url,
      relationship: profileRelationshipFromApi(dto.relationship),
      posts: dto.posts.map((p) => p.toEntity()).toList(),
      postsTotal: dto.postsTotal,
    );
  }

  @override
  Future<String> reportUser({
    required String reportedUserId,
    required String reasonCode,
    String? details,
  }) async {
    final res = await _remote.reportUser(
      reportedUserId,
      ReportUserRequestDto(reasonCode: reasonCode, details: details),
    );
    return res.reportId;
  }

  @override
  Future<String?> findIncomingRequestIdForPeer(
    String peerUserId, {
    int scanLimit = 50,
  }) async {
    final page = await getIncomingFriendRequests(limit: scanLimit, offset: 0);
    for (final item in page.items) {
      if (item.peerUserId == peerUserId) {
        return item.requestId;
      }
    }
    return null;
  }

  @override
  Future<String?> findOutgoingRequestIdForPeer(
    String peerUserId, {
    int scanLimit = 50,
  }) async {
    final page = await getOutgoingFriendRequests(limit: scanLimit, offset: 0);
    for (final item in page.items) {
      if (item.peerUserId == peerUserId) {
        return item.requestId;
      }
    }
    return null;
  }
}
