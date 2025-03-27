import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/post_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/post_provider.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/user_avatar.dart';
import '../../../widgets/tag_chip.dart';
import '../post_detail_screen.dart';
import 'media_preview.dart';
import 'poll_widget.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.isOwner;
    final isAuthor = authProvider.user?.id == post.authorId;
    final canEdit = isOwner || isAuthor;

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(post: post),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              UserAvatar(
                imageUrl: post.authorImageUrl,
                name: post.authorName,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: AppTextStyles.subtitle2,
                    ),
                    Text(
                      timeago.format(post.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (post.isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.priority_high,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Important',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (post.isPinned)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.push_pin,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              if (canEdit)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // Handle menu actions
                  },
                  itemBuilder: (context) => [
                    if (isOwner && !post.isPinned)
                      const PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(Icons.push_pin),
                            SizedBox(width: 8),
                            Text('Pin Post'),
                          ],
                        ),
                      ),
                    if (isOwner && post.isPinned)
                      const PopupMenuItem(
                        value: 'unpin',
                        child: Row(
                          children: [
                            Icon(Icons.push_pin_outlined),
                            SizedBox(width: 8),
                            Text('Unpin Post'),
                          ],
                        ),
                      ),
                    if (canEdit)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit Post'),
                          ],
                        ),
                      ),
                    if (canEdit)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete Post'),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Content
          Text(
            post.content,
            style: AppTextStyles.bodyText1,
          ),
          
          // Media (if any)
          if (post.mediaUrls != null && post.mediaUrls!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: MediaPreview(mediaUrls: post.mediaUrls!),
            ),
          
          // Poll (if any)
          if (post.type == 'poll' && post.pollData != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: PollWidget(
                pollData: post.pollData!,
                postId: post.id,
                feedType: post.feedType,
              ),
            ),
          
          // Tags (if any)
          if (post.tags != null && post.tags!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.tags!.map((tag) => TagChip(tag: tag)).toList(),
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_outlined),
                    onPressed: () {
                      // Add like reaction
                      Provider.of<PostProvider>(context, listen: false)
                          .addReactionToPost(
                        post.id,
                        post.feedType,
                        authProvider.user!.id,
                        'like',
                      );
                    },
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.reactions != null && post.reactions!['like'] != null
                        ? post.reactions!['like']!.length.toString()
                        : '0',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(post: post),
                        ),
                      );
                    },
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '0', // Replace with actual comment count
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  // Share post
                },
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

