Future<void> handleShare() async {
  Post _post = postData.value;
  if (_post.id == null) {
    return Loggers.error('Invalid Post ID : ${_post.id}');
  }

  // Show confirmation dialog
  Get.bottomSheet(
    ConfirmationSheet(
      title: 'إعادة النشر',
      description: 'هل تريد إعادة نشر هذا المنشور على حسابك؟',
      positiveText: 'إعادة النشر',
      onTap: () async {
        Get.back();
        showLoader();
        StatusModel model = await PostService.instance.increaseShareCount(postId: _post.id ?? -1);
        stopLoader();
        if (model.status == true) {
          postData.update((val) => val?.increaseShares(1));
          showSnackBar('تمت إعادة النشر بنجاح ✓');
        }
      },
    ),
  );
}      val?.saveToggle(post.isSaved == true ? false : true);
    });
    try {
      DebounceAction.shared.call(() async {
        await ((post.isSaved ?? false) ? _savePostApi(post) : _unSavePostApi(post));
      });
    } finally {
      _isSavedLoading = false;
    }
  }

  Future<void> _savePostApi(Post? post) async {
    await PostService.instance.savePost(postId: post?.id?.convertInt ?? -1);
  }

  Future<void> _unSavePostApi(Post? post) async {
    await PostService.instance.unSavePost(postId: post?.id?.convertInt ?? -1);
  }

  void handlePinUnpinPost(int isPinned) {
    if (Get.isRegistered<ProfileScreenController>(tag: ProfileScreenController.tag)) {
      final controller = Get.find<ProfileScreenController>(tag: ProfileScreenController.tag);

      if (isPinned == 0) {
        controller.updatePinPost(postData.value);
      } else {
        controller.updateUnPinPost(postData.value);
      }
    }
  }

  Future<void> handleShare() async {
    Post _post = postData.value;
    if (_post.id == null) {
      return Loggers.error('Invalid Post ID : ${_post.id}');
    }

    ShareManager.shared.showCustomShareSheet(
        post: _post,
        keys: ShareKeys.post,
        onShareSuccess: () {
          postData.update((val) => val?.increaseShares(1));
        });
  }

  void handleDelete(Post post, {required bool isModerator}) async {
    Get.bottomSheet(
      ConfirmationSheet(
          title: LKey.deletePostTitle.tr,
          onTap: () => _deletePost(post, isModerator: isModerator),
          description: LKey.deletePostMessage.tr),
    );
  }

  void _deletePost(Post post, {required bool isModerator}) async {
    showLoader();
    StatusModel model;
    if (isModerator) {
      model = await ModeratorService.instance.moderatorDeletePost(postId: post.id);
    } else {
      model = await PostService.instance.deletePost(postId: post.id);
    }
    stopLoader();
    if (model.status == true) {
      if (Get.isRegistered<ProfileScreenController>(tag: ProfileScreenController.tag)) {
        final controller = Get.find<ProfileScreenController>(tag: ProfileScreenController.tag);
        controller.posts.removeWhere((element) => element.id == post.id);
        postData.value = Post();
        Get.delete<PostScreenController>(tag: '${post.id}');
      }
    }
  }

  void handleReport(Post? post) {
    if (post == null) return;
    Get.bottomSheet(ReportSheet(id: post.id, reportType: ReportType.post), isScrollControlled: true);
  }

  void notifyCommentSheet(PostByIdData? data) {
    if (data != null && (data.comment != null || data.reply != null)) {
      DebounceAction.shared.call(() {
        onComment(postByIdData: data, isFromNotification: true);
      }, milliseconds: 1000);
    }
  }

  void onGiftTap(Post? post) {
    GiftManager.openGiftSheet(
      userId: post?.userId ?? -1,
      onCompletion: (giftManager) {
        GiftManager.showAnimationDialog(giftManager.gift);
        GiftManager.sendNotification(post);
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
    _debounce?.cancel();
  }
}
