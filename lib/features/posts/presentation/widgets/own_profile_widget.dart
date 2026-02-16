import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';

class OwnProfileWidget extends StatelessWidget {
  const OwnProfileWidget({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;
    final hasAvatar = avatarUrl != null && File(avatarUrl).existsSync();

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
              child: hasAvatar
                  ? Image.file(
                      File(avatarUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, size: 52),
                    )
                  : const Icon(Icons.person, size: 52),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
