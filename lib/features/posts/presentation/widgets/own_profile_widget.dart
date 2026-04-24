import 'package:flutter/material.dart';

import 'package:mobile_social_network/core/utils/user_avatar.dart';
import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';

class OwnProfileWidget extends StatelessWidget {
  const OwnProfileWidget({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: SizedBox(
              width: 52,
              height: 52,
              child: buildUserAvatarImage(
                avatarUrl: avatarUrl,
                size: 52,
                mediaRewriteContext: context,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
