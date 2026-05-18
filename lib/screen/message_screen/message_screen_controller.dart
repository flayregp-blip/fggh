import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class MessageScreenController extends BaseController {
  List<String> chatCategories = [LKey.chats.tr, LKey.requests.tr];
  RxInt selectedChatCategory = 0.obs;
  PageController pageController = PageController();
  User? myUser = SessionManager.instance.getUser();
  RxList<ChatThread> chatsUsers = <ChatThread>[].obs;
  RxList<ChatThread> requestsUsers = <ChatThread>[].obs;
  final dashboardController = Get.find<DashboardScreenController>();
  final supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: selectedChatCategory.value);
    _listenToUserChatsAndRequests();
  }

  @override
  void onClose() {
    _channel?.unsubscribe();
    super.onClose();
  }

  void onPageChanged(int index) {
    selectedChatCategory.value = index;
  }

  Future<void> _listenToUserChatsAndRequests() async {
    isLoading.value = true;
    final userId = myUser?.id.toString();
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    // Initial fetch
    final data = await supabase
        .from('chat_threads')
        .select()
        .eq('owner_id', userId)
        .eq('is_deleted', false)
        .order('id', ascending: false);

    isLoading.value = false;
    for (var row in data) {
      final thread = ChatThread.fromJson(row);
      thread.bindChatUser();
      if (thread.chatType == ChatType.approved) {
        chatsUsers.add(thread);
      } else {
        requestsUsers.add(thread);
      }
    }

    // Real-time listener
    _channel = supabase
        .channel('chat_threads_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_threads',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'owner_id',
            value: userId,
          ),
          callback: (payload) {
            _handleRealtimeChange(payload);
          },
        )
        .subscribe();
  }

  void _handleRealtimeChange(PostgresChangePayload payload) {
    if (payload.eventType == PostgresChangeEvent.insert) {
      final thread = ChatThread.fromJson(payload.newRecord);
      if (thread.isDeleted == true) return;
      thread.bindChatUser();
      if (thread.chatType == ChatType.approved) {
        chatsUsers.add(thread);
      } else {
        requestsUsers.add(thread);
      }
    } else if (payload.eventType == PostgresChangeEvent.update) {
      final thread = ChatThread.fromJson(payload.newRecord);
      final uid = thread.userId;
      chatsUsers.removeWhere((u) => u.userId == uid);
      requestsUsers.removeWhere((u) => u.userId == uid);
      if (thread.isDeleted == false) {
        thread.bindChatUser();
        if (thread.chatType == ChatType.approved) {
          chatsUsers.add(thread);
        } else {
          requestsUsers.add(thread);
        }
      }
    } else if (payload.eventType == PostgresChangeEvent.delete) {
      final uid = payload.oldRecord['user_id'];
      chatsUsers.removeWhere((u) => u.userId == uid);
      requestsUsers.removeWhere((u) => u.userId == uid);
    }

    chatsUsers.sort((a, b) => (b.id ?? '0').compareTo(a.id ?? '0'));
    requestsUsers.sort((a, b) => (b.id ?? '0').compareTo(a.id ?? '0'));
  }

  void onLongPress(ChatThread chatConversation) {
    Get.bottomSheet(ConfirmationSheet(
      title: LKey.deleteChatUserTitle.trParams({'user_name': chatConversation.chatUser?.username ?? ''}),
      description: LKey.deleteChatUserDescription.tr,
      onTap: () async {
        showLoader();
        await supabase
            .from('chat_threads')
            .update({
              'deleted_id': DateTime.now().millisecondsSinceEpoch,
              'is_deleted': true,
            })
            .eq('owner_id', myUser?.id.toString() ?? '')
            .eq('user_id', chatConversation.userId ?? 0);
        stopLoader();
      },
    ));
  }
}
