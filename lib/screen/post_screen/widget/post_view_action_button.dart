import 'package:flutter/material.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/post_screen/post_screen_controller.dart';

class PostViewActionButton extends StatelessWidget {
  final Post post;
  final PostScreenController controller;
  final GlobalKey likeKey;
  final void Function(Function trigger)? onTriggerReady;

  const PostViewActionButton(
      {super.key,
      required this.post,
      required this.controller,
      required this.likeKey,
      this.onTriggerReady});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Views
          _buildActionItem(
            icon: Icons.remove_red_eye_outlined,
            count: post.views ?? 0,
            onTap: null,
          ),

          // Likes
          _buildActionItem(
            icon: (post.isLiked ?? false) ? Icons.favorite : Icons.favorite_border,
            count: post.likes ?? 0,
            color: (post.isLiked ?? false) ? Colors.red : null,
            onTap: () => controller.onLike(post),
          ),

          // Comments
          if (post.canComment == 1)
            _buildActionItem(
              icon: Icons.chat_bubble_outline,
              count: post.comments ?? 0,
              onTap: controller.onComment,
            ),

          // Save
          _buildActionItem(
            icon: (post.isSaved ?? false) ? Icons.bookmark : Icons.bookmark_border,
            count: post.saves ?? 0,
            onTap: () => controller.onSaved(post),
          ),

          // Gift
          if (post.userId != SessionManager.instance.getUserID())
            _buildActionItem(
              icon: Icons.card_giftcard_outlined,
              count: null,
              onTap: () => controller.onGiftTap(post),
              showCount: false,
            ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    int? count,
    Color? color,
    required VoidCallback? onTap,
    bool showCount = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: color ?? Colors.grey[700],
            ),
            if (showCount && count != null) ...[
              const SizedBox(width: 5),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
