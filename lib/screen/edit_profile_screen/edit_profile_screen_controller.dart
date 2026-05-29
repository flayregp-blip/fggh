import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/functions/media_picker_helper.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/user_model/links_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/edit_profile_screen/widget/add_edit_link_sheet.dart';
import 'package:shortzz/screen/edit_profile_screen/widget/phone_codes_screen_controller.dart';
import 'package:shortzz/screen/feed_screen/feed_screen_controller.dart';

class EditProfileScreenController extends BaseController {
  final phoneController = Get.put(PhoneCodesScreenController());
  RxList<Link> links = <Link>[].obs;
  Rx<User?> userData = Rx(null);
  Rx<XFile?> fileProfileImage = Rx(null);
  Map<String, bool> usernameCache = {};
  Timer? _debounce;
  RxBool isValidUserName = true.obs;
  RxBool canChangeUsername = true.obs;
  RxInt daysUntilCanChange = 0.obs;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  Setting? get setting => SessionManager.instance.getSettings();

  Function(User? user)? onUpdateUser;

  EditProfileScreenController(this.onUpdateUser);

  @override
  void onInit() {
    super.onInit();
    initUserData();
  }

  @override
  void onClose() {
    super.onClose();
    _debounce?.cancel();
  }

  void initUserData() async {
    userData.value = SessionManager.instance.getUser();
    fullNameController =
        TextEditingController(text: userData.value?.fullname ?? '');
    usernameController =
        TextEditingController(text: userData.value?.username ?? '');
    bioController = TextEditingController(text: userData.value?.bio ?? '');
    emailController =
        TextEditingController(text: userData.value?.userEmail ?? '');
    phoneNumberController =
        TextEditingController(text: userData.value?.userMobileNo);
    links.value = userData.value?.links ?? [];
    _checkCanChangeUsername();
  }

  void _checkCanChangeUsername() {
    final updatedAt = userData.value?.updatedAt;
    if (updatedAt == null) {
      canChangeUsername.value = true;
      return;
    }
    try {
      final lastDate = DateTime.parse(updatedAt.toString());
      final daysSince = DateTime.now().difference(lastDate).inDays;
      if (daysSince < 30) {
        canChangeUsername.value = false;
        daysUntilCanChange.value = 30 - daysSince;
      } else {
        canChangeUsername.value = true;
        daysUntilCanChange.value = 0;
      }
    } catch (_) {
      canChangeUsername.value = true;
    }
  }

  void onChangeProfileImage() async {
    try {
      final XFile? image =
          await MediaPickerHelper.shared.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      if (fileProfileImage.value != null) {
        File(fileProfileImage.value?.path ?? '').delete();
      }
      XFile? compressed =
          await MediaPickerHelper.shared.compressProfileImage(image.path);
      if (compressed != null) {
        Loggers.info(
            "Compressed size: ${(await compressed.length()) / 1024} KB");
        fileProfileImage.value = compressed;
      }
    } on PlatformException catch (e) {
      Loggers.error(e.message);
    }
  }

  void onSaveTap() async {
    if (fullNameController.text.trim().isEmpty) {
      return showSnackBar(LKey.fullNameEmpty.tr);
    }
    if (usernameController.text.trim().isEmpty) {
      return showSnackBar(LKey.usernameEmpty.tr);
    }
    if (!isValidUserName.value) {
      return showSnackBar(LKey.validUsernameEmpty.tr);
    }

    final currentUsername = SessionManager.instance.getUser()?.username ?? '';
    final newUsername = usernameController.text.trim();
    final bool usernameChanged = currentUsername.toLowerCase() != newUsername.toLowerCase();

    // فحص 30 يوم لو حاول يغير الـ username
    if (usernameChanged) {
      final lastChanged = SessionManager.instance.getUser()?.updatedAt;
      if (lastChanged != null) {
        try {
          final lastDate = DateTime.parse(lastChanged);
          final daysSince = DateTime.now().difference(lastDate).inDays;
          if (daysSince < 30) {
            final daysLeft = 30 - daysSince;
            return showSnackBar('يمكنك تغيير اسم المستخدم بعد $daysLeft يوم');
          }
        } catch (_) {}
      }
    }

    showLoader();
    User? userData = await UserService.instance.updateUserDetails(
        fullname: fullNameController.text.trim(),
        userName: newUsername,
        bio: bioController.text.trim(),
        email: emailController.text.trim(),
        profilePhoto: fileProfileImage.value,
        phoneNumber: phoneNumberController.text.trim(),
        mobileCountryCode: int.parse(
            phoneController.selectedCode.value!.phoneCode.replaceAll('+', '')),
        country: phoneController.selectedCode.value?.countryName,
        countryCode: phoneController.selectedCode.value?.countryCode);
    stopLoader();
    if (userData == null) return;

    // شيل التوثيق لو غير الـ username
    if (usernameChanged && (userData.isVerify ?? 0) == 1) {
      userData = userData.copyWith(isVerify: 0, verifyType: 1);
      await UserService.instance.updateUserDetails(
        fullname: userData.fullname ?? '',
        userName: newUsername,
        isVerify: 0,
      );
    }

    onUpdateUser?.call(userData);
    if (Get.isRegistered<FeedScreenController>()) {
      final controller = Get.find<FeedScreenController>();
      controller.myUser.value = userData;
    }
    if (fileProfileImage.value != null) {
      File(fileProfileImage.value?.path ?? '').delete();
    }
    Get.back();
  }

  void checkUsernameAvailability(String value) {
    final username = value.trim();

    // ✅ منع الحروف العربية
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(username)) {
      isValidUserName.value = false;
      return;
    }

    // منع المسافات
    if (username.contains(' ')) {
      isValidUserName.value = false;
      return;
    }

    if (usernameCache.containsKey(username)) {
      isValidUserName.value = usernameCache[username]!;
      return;
    }

    final currentUser = SessionManager.instance.getUser()?.username;
    if (username.isNotEmpty &&
        currentUser?.toLowerCase() == username.toLowerCase()) {
      isValidUserName.value = true;
      usernameCache[username] = true;
      return;
    }
    if (!GetUtils.isUsername(username)) {
      isValidUserName.value = false;
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final model = await UserService.instance
          .checkUsernameAvailability(userName: username);
      final isAvailable = model.status ?? true;
      isValidUserName.value = isAvailable;
      usernameCache[username] = isAvailable;
    });
  }

  onLinkAddEditDelete(Link link, LinkType type) {
    switch (type) {
      case LinkType.add:
        links.add(link);
      case LinkType.edit:
        links[links.indexWhere((element) => element.id == link.id)] = link;
      case LinkType.delete:
        links.removeWhere((element) => element.id == link.id);
    }
    userData.value?.links = links;
    onUpdateUser?.call(userData.value);
  }

  void handleLinkAction(LinkType value, Link link) {
    switch (value) {
      case LinkType.edit:
        Get.bottomSheet(
            AddEditLinksSheet(
                onLinksUpdate: (link) {
                  onLinkAddEditDelete(link, LinkType.edit);
                },
                type: LinkType.edit,
                link: link),
            isScrollControlled: true);
      case LinkType.delete:
        Get.bottomSheet(
            ConfirmationSheet(
              title: LKey.deleteLinkTitle.tr,
              description: LKey.deleteLinkDescription.tr,
              onTap: () async {
                showLoader();
                LinksModel value = await UserService.instance
                    .addEditDeleteUserLink(
                        linkType: LinkType.delete, linkId: link.id?.toInt());
                stopLoader();
                if (value.status ?? false) {
                  onLinkAddEditDelete(link, LinkType.delete);
                }
              },
            ),
            isScrollControlled: true);
      case LinkType.add:
    }
  }

  void openAddEditLinkSheet() {
    int limit = setting?.maxUserLinks ?? 0;
    if (links.length >= limit) {
      return showSnackBar(
          LKey.maxUserLinkAddDescription.trParams({'limit': limit.toString()}));
    }
    Get.bottomSheet(
        AddEditLinksSheet(
            onLinksUpdate: (link) => onLinkAddEditDelete(link, LinkType.add),
            type: LinkType.add),
        isScrollControlled: true);
  }
}
