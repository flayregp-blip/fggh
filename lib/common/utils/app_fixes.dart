/// App Fixes and Improvements
/// This file contains fixes and improvements for common issues in the app

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';

/// Fix 1: Ensure proper RTL support for Arabic language
class RTLFix {
  /// Apply RTL direction based on current language
  static TextDirection getTextDirection() {
    final currentLang = SessionManager.instance.getLang();
    return currentLang == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get alignment based on language direction
  static Alignment getAlignment({
    required Alignment arabicAlignment,
    required Alignment englishAlignment,
  }) {
    final currentLang = SessionManager.instance.getLang();
    return currentLang == 'ar' ? arabicAlignment : englishAlignment;
  }

  /// Get text alignment based on language direction
  static TextAlign getTextAlign({
    required TextAlign arabicAlign,
    required TextAlign englishAlign,
  }) {
    final currentLang = SessionManager.instance.getLang();
    return currentLang == 'ar' ? arabicAlign : englishAlign;
  }
}

/// Fix 2: Ensure all translations are properly loaded
class TranslationFix {
  /// Check if all required translations are loaded
  static bool isTranslationComplete() {
    final translations = Get.find<DynamicTranslations>();
    return translations.keys.isNotEmpty;
  }

  /// Get translated text with fallback
  static String getText(String key, {String fallback = ''}) {
    try {
      return key.tr;
    } catch (e) {
      return fallback.isNotEmpty ? fallback : key;
    }
  }
}

/// Fix 3: Handle language switching properly
class LanguageSwitchFix {
  /// Switch language and update app
  static Future<void> switchLanguage(String langCode) async {
    try {
      SessionManager.instance.setLang(langCode);
      Get.updateLocale(Locale(langCode));
      await SessionManager.instance.storage.save();
    } catch (e) {
      print('Error switching language: $e');
    }
  }

  /// Get current language
  static String getCurrentLanguage() {
    return SessionManager.instance.getLang();
  }

  /// Get language name
  static String getLanguageName(String langCode) {
    switch (langCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return langCode;
    }
  }
}

/// Fix 4: Ensure proper error handling
class ErrorHandlingFix {
  /// Handle API errors gracefully
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString();
    } else {
      return 'An unknown error occurred';
    }
  }

  /// Show error snackbar
  static void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}

/// Fix 5: Ensure proper null safety
class NullSafetyFix {
  /// Safely get value with default
  static T? safeGet<T>(T? value, T defaultValue) {
    return value ?? defaultValue;
  }

  /// Safely parse string to int
  static int safeParseInt(String? value, {int defaultValue = 0}) {
    try {
      return int.parse(value ?? '0');
    } catch (e) {
      return defaultValue;
    }
  }

  /// Safely parse string to double
  static double safeParseDouble(String? value, {double defaultValue = 0.0}) {
    try {
      return double.parse(value ?? '0.0');
    } catch (e) {
      return defaultValue;
    }
  }
}

/// Fix 6: Ensure proper async handling
class AsyncFix {
  /// Execute async function with timeout
  static Future<T?> executeWithTimeout<T>(
    Future<T> Function() function, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await function().timeout(timeout);
    } catch (e) {
      print('Async operation timed out or failed: $e');
      return null;
    }
  }

  /// Execute async function with retry
  static Future<T?> executeWithRetry<T>(
    Future<T> Function() function, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await function();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          print('Max retries reached: $e');
          return null;
        }
        await Future.delayed(delay);
      }
    }
    return null;
  }
}

/// Fix 7: Ensure proper widget disposal
class DisposalFix {
  /// Safely dispose resources
  static void safeDispose(Function? dispose) {
    try {
      dispose?.call();
    } catch (e) {
      print('Error during disposal: $e');
    }
  }
}

/// Fix 8: Ensure proper theme handling
class ThemeFix {
  /// Get theme based on language
  static ThemeData getTheme(BuildContext context, String langCode) {
    // You can customize theme based on language if needed
    return Theme.of(context);
  }
}

/// Import DynamicTranslations for the fix
import 'package:shortzz/languages/dynamic_translations.dart';
