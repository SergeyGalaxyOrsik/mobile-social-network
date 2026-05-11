import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/utils/user_avatar.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/profile_relationship.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/profile_with_posts.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/report_reason_code.dart';
import 'package:mobile_social_network/features/social_users/domain/repositories/social_users_repository.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friend_requests_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/user_profile_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/user_profile_state.dart';
import 'package:mobile_social_network/features/social_users/presentation/widgets/profile_post_tile.dart';
import 'package:mobile_social_network/features/chat/presentation/chat_navigation.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

void pushUserProfilePage(BuildContext context, String profileUserId) {
  final repo = context.read<SocialUsersRepository>();
  Navigator.of(context)
      .push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider<UserProfileCubit>(
            create: (_) => UserProfileCubit(repo, profileUserId),
            child: UserProfilePage(profileUserId: profileUserId),
          ),
        ),
      )
      .then((_) {
        if (!context.mounted) return;
        try {
          context.read<FriendRequestsCubit>().load();
        } catch (_) {}
      });
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.profileUserId});

  final String profileUserId;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserProfileCubit>().load();
      }
    });
  }

  String _relationshipLabel(AppLocalizations l10n, ProfileRelationship r) {
    return switch (r) {
      ProfileRelationship.self => l10n.relationshipSelf,
      ProfileRelationship.friend => l10n.relationshipFriend,
      ProfileRelationship.outgoingFriendRequest => l10n.relationshipOutgoingFR,
      ProfileRelationship.incomingFriendRequest => l10n.relationshipIncomingFR,
      ProfileRelationship.following => l10n.relationshipFollowing,
      ProfileRelationship.none => l10n.relationshipNone,
      ProfileRelationship.unknown => l10n.relationshipNone,
    };
  }

  String _mapError(AppLocalizations l10n, String? message) {
    if (message == null || message.isEmpty) {
      return l10n.retry;
    }
    if (message == 'incoming_request_not_found') {
      return l10n.errorIncomingRequestNotFound;
    }
    if (message == 'outgoing_request_not_found') {
      return l10n.errorOutgoingRequestNotFound;
    }
    return message;
  }

  String _feedbackText(AppLocalizations l10n, ProfileFeedback f) {
    return switch (f) {
      ProfileFeedback.becameFriends => l10n.snackBecameFriends,
      ProfileFeedback.requestSent => l10n.snackRequestSent,
      ProfileFeedback.requestCancelled => l10n.snackRequestCancelled,
      ProfileFeedback.requestAccepted => l10n.snackRequestAccepted,
      ProfileFeedback.requestDeclined => l10n.snackRequestDeclined,
      ProfileFeedback.reportSubmitted => l10n.snackReportSubmitted,
    };
  }

  void _openReportSheet(BuildContext context, UserProfileCubit cubit) {
    final l10n = AppLocalizations.of(context)!;
    ReportReasonCode selected = ReportReasonCode.other;
    final detailsController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              String reasonLabel(ReportReasonCode c) {
                return switch (c) {
                  ReportReasonCode.spam => l10n.reportReasonSpam,
                  ReportReasonCode.harassment => l10n.reportReasonHarassment,
                  ReportReasonCode.hate => l10n.reportReasonHate,
                  ReportReasonCode.impersonation =>
                    l10n.reportReasonImpersonation,
                  ReportReasonCode.nudity => l10n.reportReasonNudity,
                  ReportReasonCode.scam => l10n.reportReasonScam,
                  ReportReasonCode.other => l10n.reportReasonOther,
                };
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.reportUserSheetTitle,
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<ReportReasonCode>(
                    value: selected,
                    isExpanded: true,
                    items: ReportReasonCode.values
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(reasonLabel(c)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => selected = v);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailsController,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      labelText: l10n.reportDetailsLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      final details = detailsController.text.trim();
                      Navigator.of(ctx).pop();
                      await cubit.submitReport(
                        reasonCode: selected.apiValue,
                        details: details.isEmpty ? null : details,
                      );
                    },
                    child: Text(l10n.reportSubmit),
                  ),
                ],
              );
            },
          ),
        );
      },
    ).whenComplete(detailsController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listenWhen: (prev, curr) =>
          curr.feedback != prev.feedback ||
          (curr.errorMessage != prev.errorMessage &&
              curr.errorMessage != null &&
              curr.profile != null),
      listener: (context, state) {
        if (!context.mounted) return;
        final cubit = context.read<UserProfileCubit>();
        final fb = state.feedback;
        if (fb != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_feedbackText(l10n, fb))));
          cubit.clearFeedback();
          return;
        }
        final err = state.errorMessage;
        if (err != null && err.isNotEmpty && state.profile != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_mapError(l10n, err))));
          cubit.clearError();
        }
      },
      builder: (context, state) {
        final cubit = context.read<UserProfileCubit>();
        final profile = state.profile;
        return Scaffold(
          appBar: AppBar(
            title: Text(profile?.username ?? ''),
            actions: [
              if (profile != null &&
                  profile.relationship != ProfileRelationship.self)
                IconButton(
                  icon: const Icon(Icons.flag_outlined),
                  tooltip: l10n.reportUserAction,
                  onPressed: state.actionBusy
                      ? null
                      : () => _openReportSheet(context, cubit),
                ),
            ],
          ),
          body: state.loading && profile == null
              ? const Center(child: CircularProgressIndicator())
              : profile == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _mapError(l10n, state.errorMessage),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => cubit.load(reset: true),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => cubit.load(reset: true),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: SizedBox(
                              width: 88,
                              height: 88,
                              child: buildUserAvatarImage(
                                avatarUrl: profile.avatarUrl,
                                size: 88,
                                mediaRewriteContext: context,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.username,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _relationshipLabel(
                                    l10n,
                                    profile.relationship,
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.profileBio,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(profile.bio!),
                      ],
                      if (profile.birthDate != null &&
                          profile.birthDate!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n.profileBirthDate,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(profile.birthDate!),
                      ],
                      const SizedBox(height: 20),
                      if (state.actionBusy) const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      _buildActions(context, l10n, profile, state.actionBusy),
                      const SizedBox(height: 24),
                      Text(
                        l10n.profilePosts,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (profile.posts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text(l10n.profileNoPosts)),
                        )
                      else
                        ...profile.posts.map((p) => ProfilePostTile(post: p)),
                      if (profile.posts.length < profile.postsTotal) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: state.loadingMore
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                )
                              : TextButton(
                                  onPressed: () => cubit.loadMore(),
                                  child: Text(l10n.profileLoadMore),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildActions(
    BuildContext context,
    AppLocalizations l10n,
    ProfileWithPosts profile,
    bool busy,
  ) {
    final cubit = context.read<UserProfileCubit>();
    final r = profile.relationship;
    if (r == ProfileRelationship.self) {
      return const SizedBox.shrink();
    }
    if (busy) {
      return const SizedBox.shrink();
    }
    switch (r) {
      case ProfileRelationship.none:
        return FilledButton(
          onPressed: () => cubit.sendFriendRequest(),
          child: Text(l10n.profileAddFriend),
        );
      case ProfileRelationship.outgoingFriendRequest:
        return OutlinedButton(
          onPressed: () => cubit.cancelOutgoingRequest(),
          child: Text(l10n.profileCancelRequest),
        );
      case ProfileRelationship.incomingFriendRequest:
        return Row(
          children: [
            FilledButton(
              onPressed: () => cubit.acceptIncomingRequest(),
              child: Text(l10n.profileAccept),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => cubit.declineIncomingRequest(),
              child: Text(l10n.profileDecline),
            ),
          ],
        );
      case ProfileRelationship.friend:
        return FilledButton.icon(
          onPressed: () => pushDirectChatPage(
            context,
            peerUserId: profile.userId,
            peerDisplayName: profile.username,
          ),
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text(l10n.chatOpenThread),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
