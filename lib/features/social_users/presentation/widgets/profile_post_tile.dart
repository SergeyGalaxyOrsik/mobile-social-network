import 'package:flutter/material.dart';

import 'package:mobile_social_network/core/config/media_url_rewrite_config.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';

/// Компактное отображение поста на экране профиля (без лайков/комментариев).
class ProfilePostTile extends StatelessWidget {
  const ProfilePostTile({super.key, required this.post});

  final PostEntity post;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = BorderSide(color: scheme.outline, width: 1);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.fromBorderSide(border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.createdAt,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          if (post.media != null && post.media!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.media!.map((m) {
                if (m.type.startsWith('image/') && m.url.isNotEmpty) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      context.resolveMediaDisplayUrl(m.url),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 120,
                        height: 120,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
