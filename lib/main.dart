import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/languages/dynamic_translations.dart';
import 'package:shortzz/screen/splash_screen/splash_screen.dart';
import 'package:shortzz/utilities/theme_res.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage first
  await GetStorage.init('shortzz');

  // Set initial locale from storage
  String langCode = SessionManager.instance.getLang();
  Get.updateLocale(Locale(langCode));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: DynamicTranslations(),
      locale: Get.locale ?? Locale(SessionManager.instance.getLang()),
      fallbackLocale: const Locale('ar'),
      themeMode: ThemeMode.light,
      darkTheme: ThemeRes.darkTheme(context),
      theme: ThemeRes.lightTheme(context),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
