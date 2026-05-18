import 'dart:async';
import 'dart:convert';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/blocked_user_screen/block_user_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/common_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/chat/message_data.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/post_story/story/story_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/blocked_user_screen/block_user_controller.dart';
import 'package:shortzz/screen/blocked_user_screen/block_user_controller.dart';
import 'package:shortzz/screen/chat_screen/widget/select_media_sheet.dart';
import 'package:shortzz/screen/chat_screen/widget/send_media_sheet.dart';
import 'package:shortzz/screen/gif_sheet/gif_sheet.dart';
import 'package:shortzz/screen/gift_sheet/send_gift_sheet_controller.dart';
import 'package:shortzz/screen/post_screen/post_screen_controller.dart';
import 'package:shortzz/screen/post_screen/single_post_screen.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/screen/reels_screen/widget/reel_page_type.dart';
import 'package:shortzz/screen/report_sheet/report_sheet.dart';
import 'package:shortzz/screen/story_view_screen/story_view_screen.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class ChatScreenController extends BlockUserController with GetTickerProviderStateMixin {
  List<UserRequestAction> requestType = UserRequestAction.values;
  User? myUser = SessionManager.instance.getUser();
  User? otherUser;
  final Setting? setting = SessionManager.instance.getSettings();
  RxBool isTextEmpty = true.obs;
  RxBool hasMore = true.obs;
  RxBool isExpanded = false.obs;
  bool isPostAPiCalling = false;
  TextEditingController textController = TextEditingController();
  TextEditingController mediaTextController = TextEditingController();
  Rx<ChatThread> conversationUser;
  ChatThread? myConversationUser;
  late AnimationController audioAnimationController;
  Animation<double>? audioWidthAnimation;
  final supabase = Supabase.instance.client;
  double get wavesWidth => Get.width - 100;
  MessageType chatType = MessageType.text;
  RxList<MessageData> chatList = <MessageData>[].obs;
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _threadChannel;
  int? _lastId;
  RecorderController recorderController = RecorderController();
  PlayerController playerController = PlayerController();
  Rx<PlayerValue> playerValue = PlayerValue(state: PlayerState.stopped, id: 0).obs;
  StreamSubscription<PlayerState>? playerControllerListen;
  ChatScreenController(this.conversationUser);
  static String chatId = '';

  @override
  void onInit() {
    super.onInit();
    chatId = conversationUser.value.conversationId ?? 'No CONVERSATION';
    _fetchOtherUser();
    _initAudioAnimationController();
    _initializePlayerStateListener();
  }

  @override
  void onReady() {
    super.onReady();
    _getChat();
    _listenToChatThread();
    _markAsRead();
  }

  @override
  void onClose() {
    chatId = '';
    _messagesChannel?.unsubscribe();
    _threadChannel?.unsubscribe();
    playerControllerListen?.cancel();
    audioAnimationController.dispose();
    recorderController.dispose();
    playerController.dispose();
    textController.dispose();
    mediaTextController.dispose();
    _markAsRead();
    super.onClose();
  }

  void _initAudioAnimationController() {
    audioAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    final double maxWidth = Get.width - 30;
    audioWidthAnimation = Tween<double>(begin: 0, end: maxWidth)
        .animate(CurvedAnimation(parent: audioAnimationController, curve: Curves.easeInOut));
  }

  void _initializePlayerStateListener() {
    playerControllerListen = playerController.onPlayerStateChanged.listen((event) {
      playerValue.update((val) => val?.state = event);
    });
  }

  void _fetchOtherUser() async {
    int userId = conversationUser.value.userId ?? -1;
    if (userId != -1) {
      otherUser = await UserService.instance.fetchUserDetails(userId: userId);
    }
  }

  void _listenToChatThread() {
    final convId = conversationUser.value.conversationId;
    final myId = myUser?.id.toString();
    if (convId == null || myId == null) return;

    _threadChannel = supabase
        .channel('thread_${convId}_$myId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_threads',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: convId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              final updated = ChatThread.fromJson(payload.newRecord);
              if (updated.userId == conversationUser.value.userId) {
                conversationUser.value = updated;
              }
            }
          },
        )
        .subscribe();
  }

  Future<void> _getChat() async {
    final convId = conversationUser.value.conversationId;
    if (convId == null) return;
    chatList.clear();

    final data = await supabase
        .from('messages')
        .select()
        .eq('conversation_id', convId)
        .contains('no_delete_ids', [myUser?.id])
        .gt('id', conversationUser.value.deletedId ?? 0)
        .order('id', ascending: false)
        .limit(AppRes.chatPaginationLimit);

    for (var row in data) {
      chatList.add(MessageData.fromJson(row));
    }
    if (data.isNotEmpty) _lastId = data.last['id'];

    _messagesChannel = supabase
        .channel('messages_$convId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: convId,
          ),
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.insert) {
              final msg = MessageData.fromJson(payload.newRecord);
              if (!chatList.any((e) => e.id == msg.id)) {
                chatList.add(msg);
                chatList.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
                if (msg.userId != myUser?.id) _markAsRead();
              }
            } else if (payload.eventType == PostgresChangeEvent.update) {
              final msg = MessageData.fromJson(payload.newRecord);
              final idx = chatList.indexWhere((e) => e.id == msg.id);
              if (idx != -1) chatList[idx] = msg;
              else chatList.add(msg);
              chatList.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
            } else if (payload.eventType == PostgresChangeEvent.delete) {
              chatList.removeWhere((e) => e.id == payload.oldRecord['id']);
            }
            chatList.refresh();
          },
        )
        .subscribe();
  }

  Future<void> fetchMoreChatList() async {
    if (!hasMore.value || isLoading.value || _lastId == null) return;
    isLoading.value = true;
    try {
      final convId = conversationUser.value.conversationId;
      final data = await supabase
          .from('messages')
          .select()
          .eq('conversation_id', convId!)
          .contains('no_delete_ids', [myUser?.id])
          .gt('id', conversationUser.value.deletedId ?? 0)
          .lt('id', _lastId!)
          .order('id', ascending: false)
          .limit(AppRes.chatPaginationLimit);

      if (data.isEmpty) { hasMore.value = false; return; }
      _lastId = data.last['id'];
      for (var row in data) {
        final msg = MessageData.fromJson(row);
        if (!chatList.any((e) => e.id == msg.id)) chatList.add(msg);
      }
      chatList.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    } catch (e) {
      Loggers.error('fetchMoreChatList error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSendTextMessage() async {
    String text = textController.text.trim();
    textController.clear();
    isTextEmpty.value = true;
    if (conversationUser.value.iAmBlocked ?? false) {
      return showSnackBar('You cannot message ${conversationUser.value.chatUser?.username} because you are blocked by them.');
    }
    sendMessage(type: MessageType.text, textMessage: text);
  }

  Future<void> sendMessage({
    required MessageType type,
    String? textMessage,
    String? imageMessage,
    String? videoMessage,
    String? audioMessage,
    String? postMessage,
    String? storyReplyMessage,
    List<double>? waveData,
  }) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    final myId = myUser?.id ?? -1;
    final otherId = conversationUser.value.chatUser?.userId ?? -1;

    MessageData message = MessageData(
      userId: myId,
      conversationId: conversationUser.value.conversationId,
      textMessage: textMessage,
      iAmBlocked: false,
      iBlocked: false,
      imageMessage: imageMessage,
      videoMessage: videoMessage,
      postMessage: postMessage,
      storyReplyMessage: storyReplyMessage,
      messageType: type,
      id: time,
      noDeleteIds: [myId, otherId],
      audioMessage: audioMessage,
      waveData: waveData?.join(','),
    );

    await supabase.from('messages').insert(message.toJson());

    String senderLastMsg = getLastMessage(type, message, isSender: true);
    String receiverLastMsg = getLastMessage(type, message, isSender: false);

    // Update sender thread
    final senderExists = await supabase.from('chat_threads')
        .select('id').eq('owner_id', myId).eq('conversation_id', conversationUser.value.conversationId ?? '').maybeSingle();

    if (senderExists != null) {
      await supabase.from('chat_threads').update({
        'id': time.toString(), 'last_msg': senderLastMsg, 'msg_count': 0, 'is_deleted': false,
      }).eq('owner_id', myId).eq('conversation_id', conversationUser.value.conversationId ?? '');
    } else {
      final t = conversationUser.value.toJson();
      t['owner_id'] = myId;
      t['id'] = time.toString();
      t['last_msg'] = senderLastMsg;
      t['msg_count'] = 0;
      t['is_deleted'] = false;
      await supabase.from('chat_threads').insert(t);
    }

    // Update receiver thread
    final receiverExists = await supabase.from('chat_threads')
        .select('id').eq('owner_id', otherId).eq('conversation_id', conversationUser.value.conversationId ?? '').maybeSingle();

    if (receiverExists != null) {
      await supabase.from('chat_threads').update({
        'id': time.toString(), 'last_msg': receiverLastMsg, 'is_deleted': false,
        'msg_count': (receiverExists['msg_count'] ?? 0) + 1,
      }).eq('owner_id', otherId).eq('conversation_id', conversationUser.value.conversationId ?? '');
    } else {
      ChatType status = ChatType.approved;
      String? reqType = UserRequestAction.accept.title;
      if (otherUser != null) {
        status = otherUser?.followStatus == 2 || otherUser?.followStatus == 3 ? ChatType.approved : ChatType.request;
        reqType = otherUser?.followStatus == 2 || otherUser?.followStatus == 3 ? UserRequestAction.accept.title : null;
      }
      await supabase.from('chat_threads').insert({
        'owner_id': otherId,
        'user_id': myId,
        'conversation_id': conversationUser.value.conversationId,
        'id': time.toString(),
        'last_msg': receiverLastMsg,
        'msg_count': 1,
        'chat_type': status.value,
        'request_type': reqType,
        'is_deleted': false,
        'deleted_id': 0,
        'i_blocked': false,
        'i_am_blocked': false,
      });
    }

    pushNotificationToUser(message);
  }

  void pushNotificationToUser(MessageData message) {
    if (otherUser?.notifyChat == 0) return;
    String bodyMessage = '';
    switch (message.messageType) {
      case MessageType.image: bodyMessage = 'Shared a Photo'; break;
      case MessageType.video: bodyMessage = 'Shared a Video'; break;
      case MessageType.post: bodyMessage = 'Shared a Post'; break;
      case MessageType.audio: bodyMessage = '🎙️ Sent a voice message'; break;
      case MessageType.text: bodyMessage = message.textMessage ?? ''; break;
      case MessageType.gift: bodyMessage = 'Sent a Gift'; break;
      case MessageType.gif: bodyMessage = 'Sent a GIF'; break;
      case MessageType.storyReply: bodyMessage = 'Sent a Story Reply'; break;
      case null: bodyMessage = ''; break;
    }
    NotificationService.instance.pushNotification(
        title: myUser?.fullname ?? '',
        body: bodyMessage,
        token: otherUser?.deviceToken,
        deviceType: otherUser?.device,
        type: NotificationType.chat,
        data: myConversationUser?.toJson());
  }

  String getLastMessage(MessageType type, MessageData message, {bool isSender = true}) {
    String prefix = isSender ? "You: " : "";
    String sentPrefix = isSender ? "You sent " : "Sent you ";
    switch (type) {
      case MessageType.text: return "$prefix${message.textMessage ?? ''}";
      case MessageType.image: return '${sentPrefix}an Image';
      case MessageType.video: return '${sentPrefix}a Video';
      case MessageType.gift: return '${sentPrefix}a Gift';
      case MessageType.audio: return '${sentPrefix}a voice message';
      case MessageType.gif: return '${sentPrefix}a GIF';
      case MessageType.post:
        Post post = Post.fromJson(jsonDecode(message.postMessage ?? ''));
        return '$sentPrefix@${post.user?.username ?? ''}\'s post';
      case MessageType.storyReply: return '${sentPrefix}a Story Reply';
    }
  }

  void onTextFieldChanged(String value) {
    isTextEmpty.value = value.trim().isEmpty;
  }

  void _markAsRead() async {
    try {
      conversationUser.update((val) => val?.msgCount = 0);
      await supabase.from('chat_threads').update({'msg_count': 0})
          .eq('owner_id', myUser?.id ?? -1)
          .eq('conversation_id', conversationUser.value.conversationId ?? '');
    } catch (e) {
      Loggers.error('Mark as read error: $e');
    }
  }

  onChatActionTap(ChatAction action) {
    if (conversationUser.value.iAmBlocked ?? false) {
      return showSnackBar('You cannot message ${conversationUser.value.chatUser?.username} because you are blocked by them.');
    }
    FocusManager.instance.primaryFocus?.unfocus();
    switch (action) {
      case ChatAction.gift: pickGift(); break;
      case ChatAction.audio: _pickAudio(); break;
      case ChatAction.sticker: pickSticker(); break;
      case ChatAction.media: pickAndSendMedia(); break;
    }
  }

  void onCameraTap() {
    if (conversationUser.value.iAmBlocked ?? false) {
      return showSnackBar('You cannot message ${conversationUser.value.chatUser?.username} because you are blocked by them.');
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Get.bottomSheet(SelectMediaSheet(onSelectMedia: (mediaFile) { Get.back(); _showSendMediaSheet(mediaFile); }), isScrollControlled: true);
  }

  void pickGift() {
    GiftManager.openGiftSheet(userId: conversationUser.value.chatUser?.userId ?? -1, onCompletion: (giftManager) {
      sendMessage(type: MessageType.gift, textMessage: giftManager.gift.coinPrice.toString(), imageMessage: giftManager.gift.image);
    });
  }

  void pickSticker() {
    Get.bottomSheet<String?>(const GifSheet(), isScrollControlled: true).then((value) {
      if (value != null) sendMessage(type: MessageType.gif, imageMessage: value);
    });
  }

  void pickAndSendMedia() async {
    MediaFile? mediaFile = await MediaPickerHelper.shared.pickMedia();
    if (mediaFile == null) return;
    mediaTextController.clear();
    _showSendMediaSheet(mediaFile);
  }

  void _showSendMediaSheet(MediaFile mediaFile) {
    Get.bottomSheet(SendMediaSheet(controller: this, image: mediaFile.thumbNail.path, onSendBtnClick: () { Get.back(); _uploadAndSendMessage(mediaFile); }), isScrollControlled: true);
  }

  Future<void> _uploadAndSendMessage(MediaFile mediaFile) async {
    showLoader();
    String filePath = await _uploadFile(mediaFile.file);
    String thumbnailPath = mediaFile.type == MediaType.video ? await _uploadFile(mediaFile.thumbNail) : '';
    stopLoader();
    bool isImage = mediaFile.type == MediaType.image;
    if (filePath.isEmpty) return;
    sendMessage(type: isImage ? MessageType.image : MessageType.video, imageMessage: isImage ? filePath : thumbnailPath, videoMessage: !isImage ? filePath : thumbnailPath, textMessage: mediaTextController.text.trim());
  }

  Future<String> _uploadFile(XFile file) async {
    return (await CommonService.instance.uploadFileGivePath(file)).data ?? '';
  }

  void toggleAnimation() {
    if (isExpanded.value) audioAnimationController.reverse();
    else audioAnimationController.forward();
    isExpanded.value = !isExpanded.value;
  }

  void _pickAudio() async {
    recorderController = RecorderController();
    bool isGranted = await recorderController.checkPermission();
    if (isGranted) {
      audioAnimationController.forward();
      recorderController.record(recorderSettings: const RecorderSettings());
    } else {
      Get.bottomSheet(ConfirmationSheet(title: LKey.enableMicrophoneAccessTitle.tr, description: LKey.enableMicrophoneAccessDescription.tr, onTap: openAppSettings, positiveText: LKey.settings.tr), isScrollControlled: true);
    }
  }

  void deleteRecordedAudio() async {
    audioAnimationController.reverse();
    recorderController.reset();
    recorderController.dispose();
  }

  void sendRecordedAudio() async {
    audioAnimationController.reverse();
    showLoader();
    try {
      String? recordedFilePath = await recorderController.stop();
      if (recordedFilePath != null) {
        List<double> waveData = await playerController.waveformExtraction.extractWaveformData(path: recordedFilePath, noOfSamples: playerWaveStyle.getSamplesForWidth(wavesWidth));
        String audioUrl = await _uploadFile(XFile(recordedFilePath));
        sendMessage(type: MessageType.audio, audioMessage: audioUrl, waveData: waveData);
      }
    } catch (e) {
      Loggers.error('Audio recording error: $e');
    } finally {
      stopLoader();
      recorderController.dispose();
    }
  }

  void startAudioPlayback() async => await playerController.startPlayer();
  void pauseAudioPlayback() async => await playerController.pausePlayer();

  void toggleAudioPlayback(MessageData message) {
    if (playerValue.value.id == message.id) {
      switch (playerValue.value.state) {
        case PlayerState.playing: pauseAudioPlayback(); break;
        case PlayerState.paused: startAudioPlayback(); break;
        default: break;
      }
    } else {
      playAudioMessage(message);
    }
  }

  void playAudioMessage(MessageData message) async {
    String audioUrl = message.audioMessage?.addBaseURL() ?? '';
    if (audioUrl.isEmpty) return;
    DefaultCacheManager().getSingleFile(audioUrl).then((file) async {
      playerController.release();
      await playerController.preparePlayer(path: file.path, noOfSamples: playerWaveStyle.getSamplesForWidth(wavesWidth));
      playerValue.value = PlayerValue(state: PlayerState.initialized, id: message.id ?? 0);
      startAudioPlayback();
    });
  }

  void onDeleteForYou(MessageData message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final data = await supabase.from('messages').select().eq('id', message.id ?? 0).maybeSingle();
      if (data != null) {
        List<int> ids = List<int>.from(data['no_delete_ids'] ?? []);
        if (ids.length < 2) {
          await supabase.from('messages').delete().eq('id', message.id ?? 0);
          await _deleteAssociatedFiles(message);
        } else {
          ids.remove(myUser?.id);
          await supabase.from('messages').update({'no_delete_ids': ids}).eq('id', message.id ?? 0);
          chatList.removeWhere((e) => e.id == message.id);
        }
      }
    } catch (e) {
      Loggers.error('onDeleteForYou error: $e');
    }
  }

  void onUnSend(MessageData message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      await supabase.from('messages').delete().eq('id', message.id ?? 0);
      await _deleteAssociatedFiles(message);
    } catch (e) {
      Loggers.error('onUnSend error: $e');
    }
  }

  Future<void> _deleteAssociatedFiles(MessageData message) async {
    switch (message.messageType) {
      case MessageType.image: await deleteFile(message.imageMessage ?? ''); break;
      case MessageType.video: await deleteFile(message.videoMessage ?? ''); await deleteFile(message.imageMessage ?? ''); break;
      case MessageType.audio: await deleteFile(message.audioMessage ?? ''); break;
      default: break;
    }
  }

  Future<bool> deleteFile(String file) async {
    StatusModel response = await CommonService.instance.deleteFile(file);
    return response.status == true;
  }

  void onChatRequestTap(UserRequestAction requestType, ChatThread conversation) async {
    switch (requestType) {
      case UserRequestAction.block:
        AppUser? user = conversation.chatUser;
        blockUser(User(id: user?.userId, profilePhoto: user?.profile, username: user?.username, fullname: user?.fullname, isVerify: user?.isVerify), () {});
        break;
      case UserRequestAction.reject:
        await supabase.from('chat_threads').update({'request_type': UserRequestAction.reject.title, 'deleted_id': DateTime.now().millisecondsSinceEpoch, 'is_deleted': true})
            .eq('owner_id', myUser?.id ?? -1).eq('conversation_id', conversation.conversationId ?? '');
        Get.back();
        break;
      case UserRequestAction.accept:
        await supabase.from('chat_threads').update({'chat_type': ChatType.approved.value, 'request_type': UserRequestAction.accept.title})
            .eq('owner_id', myUser?.id ?? -1).eq('conversation_id', conversation.conversationId ?? '');
        break;
    }
  }

  void onPostTap(Post post) async {
    PostType type = post.postType;
    playerController.pausePlayer();
    fetchPost(postType: post.postType, post: post);
    switch (type) {
      case PostType.reel:
      case PostType.video:
        Get.to(() => ReelsScreen(reels: [post].obs, position: 0, pageType: ReelPageType.single));
        break;
      case PostType.image:
      case PostType.text:
        Get.to(() => SinglePostScreen(post: post, isFromNotification: false));
        break;
      case PostType.none: break;
    }
  }

  void fetchPost({required PostType postType, Post? post}) async {
    Post? _post = (await PostService.instance.fetchPostById(postId: post?.id ?? -1)).data?.post;
    if (_post == null) return;
    switch (postType) {
      case PostType.image:
      case PostType.text:
        Get.find<PostScreenController>(tag: _post.id.toString()).updatePost(_post);
        break;
      case PostType.reel:
      case PostType.video:
        Get.find<ReelController>(tag: _post.id.toString()).updateReelData(reel: _post);
        break;
      case PostType.none: break;
    }
  }

  void onReportUser(ChatThread chatThread) {
    Get.bottomSheet(ReportSheet(reportType: ReportType.user, id: chatThread.chatUser?.userId), isScrollControlled: true);
  }

  void toggleBlockUnblock(ChatThread chatThread) {
    if (chatThread.iBlocked ?? false) unblockUser(otherUser, () {});
    else blockUser(otherUser, () {});
  }

  void sendStoryReply({required Story story, required String textReply, String? imageReply}) {
    sendMessage(type: MessageType.storyReply, imageMessage: imageReply, textMessage: textReply, storyReplyMessage: jsonEncode(story.toJsonWithUser()));
  }

  void removeStoryFromChat(MessageData message) async {
    await supabase.from('messages').update({'story_reply_message': jsonEncode(Story())}).eq('id', message.id ?? 0);
  }

  void onStoryTap(MessageData message, Story story) {
    final createdAtStr = story.createdAt;
    if (createdAtStr == null || createdAtStr.isEmpty) { removeStoryFromChat(message); return; }
    DateTime? storyDate;
    try { storyDate = DateTime.parse(createdAtStr); } catch (e) { removeStoryFromChat(message); return; }
    if (DateTime.now().difference(storyDate).inHours >= 24) { removeStoryFromChat(message); return; }
    if (story.id == null) { removeStoryFromChat(message); return; }
    final user = User(id: story.userId, username: story.user?.username ?? '', fullname: story.user?.fullname ?? '', profilePhoto: story.user?.profilePhoto ?? '', isVerify: story.user?.isVerify, bio: story.user?.bio ?? '', stories: [story]);
    Get.bottomSheet(StoryViewSheet(stories: [user], userIndex: 0, onUpdateDeleteStory: (_) {}), isScrollControlled: true, ignoreSafeArea: false, useRootNavigator: true);
  }
}

final playerWaveStyle = PlayerWaveStyle(fixedWaveColor: ColorRes.bgGrey, spacing: 3, waveThickness: 1.5, scaleFactor: 50, liveWaveGradient: StyleRes.wavesGradient);

class PlayerValue {
  PlayerState state;
  int id;
  PlayerValue({required this.state, required this.id});
}
