import 'package:flutter/material.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/post_screen/post_screen_controller.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

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
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Wrap(
        children: [
          PostViewIconWithCount(
              key: likeKey,
              onTap: () => controller.onLike(post),
              color: post.isLiked ?? false ? ColorRes.likeRed : null,
              icon: post.isLiked ?? false
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              count: post.likes),
          if (post.canComment == 1)
            PostViewIconWithCount(
                onTap: controller.onComment,
                icon: Icons.chat_bubble_outline_rounded,
                count: post.comments),
          PostViewIconWithCount(
              onTap: () {},
              icon: Icons.visibility_outlined,
              count: post.views),
          PostViewIconWithCount(
              onTap: () => controller.onSaved(post),
              icon: post.isSaved ?? false
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              count: post.saves),
          if (post.userId != SessionManager.instance.getUserID())
            PostViewIconWithCount(
              onTap: () => controller.onGiftTap(post),
              icon: Icons.card_giftcard_rounded,
              isCountVisible: false,
            ),
        ],
      ),
    );
  }
}

class PostViewIconWithCount extends StatelessWidget {
  final IconData icon;
  final num? count;
  final VoidCallback onTap;
  final Color? color;
  final bool isCountVisible;
  final Key? likeKey;

  const PostViewIconWithCount(
      {super.key,
      required this.icon,
      this.count,
      required this.onTap,
      this.color,
      this.isCountVisible = true,
      this.likeKey});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? textDarkGrey(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              icon,
              key: likeKey,
              color: iconColor,
              size: 25,
            ),
          ),
        ),
        if (isCountVisible)
          SizedBox(
            width: 35,
            child: Text(
              (count ?? 0).numberFormat,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 12.5, color: textDarkGrey(context)),
            ),
          )
      ],
    );
  }
}
