import 'package:flutter/material.dart';

class ModernEngagementBar extends StatelessWidget {
  final int views;
  final int likes;
  final int comments;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onSaveTap;
  final VoidCallback onGiftTap;

  const ModernEngagementBar({
    super.key,
    required this.views,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onSaveTap,
    required this.onGiftTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Views
          _buildStatItem(
            icon: Icons.remove_red_eye_outlined,
            count: views,
            onTap: null,
          ),

          // Likes
          _buildStatItem(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            count: likes,
            color: isLiked ? Colors.red : Colors.grey[600],
            onTap: onLikeTap,
          ),

          // Comments
          _buildStatItem(
            icon: Icons.chat_bubble_outline,
            count: comments,
            onTap: onCommentTap,
          ),

          // Save
          _buildIconButton(
            icon: Icons.bookmark_border,
            onTap: onSaveTap,
          ),

          // Gift
          _buildIconButton(
            icon: Icons.card_giftcard_outlined,
            onTap: onGiftTap,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 13,
                color: color ?? Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
    );
  }
}
