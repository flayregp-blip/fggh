import 'package:flutter/material.dart';
import 'dart:io';

import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/ads_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/eula_sheet.dart';
import 'package:shortzz/common/widget/restart_widget.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/screen/select_language_screen/select_language_screen.dart';

class SelectLanguageScreenController extends BaseController {
  Rx<Language?> selectedLanguage = Rx(null);
  RxList<Language> languages = <Language>[].obs;
  LanguageNavigationType languageNavigationType;

  Setting? get setting => SessionManager.instance.getSettings();
  SelectLanguageScreenController(this.languageNavigationType);

  @override
  void onInit() {
    super.onInit();
    initLanguage();
  }

  @override
  void onReady() {
    super.onReady();
    if (languageNavigationType == LanguageNavigationType.fromStart) {
      openEULASheet();
    }
    AdsManager.instance.requestConsentInfoUpdate();
  }

  Future<void> openEULASheet() async {
    if (Platform.isIOS) {
      bool shouldOpen = SessionManager.instance.shouldOpenEULASheet;

      await Future.delayed(const Duration(milliseconds: 250));
      Loggers.info('message  $shouldOpen');
      if (shouldOpen) {
        Get.bottomSheet(const EulaSheet(),
            isScrollControlled: true, enableDrag: false);
      }
    }
  }

  void initLanguage() {
    List<Language> items =
        SessionManager.instance.getSettings()?.languages ?? [];
    items.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
    for (Language element in items) {
      if (element.status == 1) {
        languages.add(element);
      }
    }
    selectedLanguage.value = languages.firstWhereOrNull((element) {
      return element.code == SessionManager.instance.getLang();
    }) ?? (languages.isNotEmpty ? languages.first : null);
  }

  void onLanguageChange(Language? value) {
    selectedLanguage.value = value;
    final langCode = value?.code ?? 'ar';
    SessionManager.instance.setLang(langCode);
    
    // Update locale and text direction
    Get.updateLocale(Locale(langCode));
    
    // Update text direction based on language
    if (Get.context != null) {
      final isArabic = langCode == 'ar';
      final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
      // This will be applied when the app restarts
    }
    
    SessionManager.instance.storage.save().then((_) { 
      RestartWidget.restartApp(Get.context!); 
    });
  }
}
