import 'package:get/get.dart';

class DynamicTranslations extends Translations {
  final Map<String, Map<String, String>> _keys = {};

  @override
  Map<String, Map<String, String>> get keys => _keys;

  void addTranslations(Map<String, Map<String, String>> map) {
    map.forEach((lang, translations) {
      if (_keys.containsKey(lang)) {
        _keys[lang]?.addAll(translations);
      } else {
        _keys[lang] = translations;
      }
    });
  }

  /// تحميل الترجمات الأساسية
  void loadInitialTranslations() {
    final arabic = <String, String>{};
    final english = <String, String>{};

    // أضف الترجمات الأساسية هنا
    arabic['Language'] = 'اللغة';
    arabic['Settings'] = 'الإعدادات';
    arabic['Posts'] = 'المنشورات';
    arabic['Reels'] = 'الريلز';
    arabic['Following'] = 'المتابعون';
    arabic['Followers'] = 'المتابعين';

    english['Language'] = 'Language';
    english['Settings'] = 'Settings';
    english['Posts'] = 'Posts';
    english['Reels'] = 'Reels';
    english['Following'] = 'Following';
    english['Followers'] = 'Followers';

    addTranslations({
      'ar': arabic,
      'en': english,
    });
  }
}
