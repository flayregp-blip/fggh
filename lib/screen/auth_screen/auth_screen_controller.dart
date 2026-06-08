import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/functions/debounce_action.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/common_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/user_model.dart' as user;
import 'package:shortzz/screen/dashboard_screen/dashboard_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthScreenController extends BaseController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController forgetEmailController = TextEditingController();

  @override
  void onInit() {
    CommonService.instance.fetchGlobalSettings();
    super.onInit();
  }

  Future<void> onLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) return showSnackBar(LKey.enterEmail.tr);
    if (password.isEmpty) return showSnackBar(LKey.enterAPassword.tr);

    showLoader();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      
      if (credential.user?.emailVerified == false) {
        stopLoader();
        return showSnackBar(LKey.verifyEmailFirst.tr);
      }

      final fullname = credential.user?.displayName ?? email.split('@')[0];
      final data = await _loginUser(identity: email, loginMethod: LoginMethod.email, fullname: fullname);
      stopLoader();
      if (data != null) _navigateScreen(data);
    } catch (e) {
      stopLoader();
      showSnackBar(LKey.userNotFound.tr);
    }
  }

  Future<void> onGoogleTap() async {
    showLoader();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        stopLoader();
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final email = userCredential.user?.email ?? '';
      final fullname = userCredential.user?.displayName ?? email.split('@')[0];

      final data = await _loginUser(identity: email, loginMethod: LoginMethod.google, fullname: fullname);
      stopLoader();
      if (data != null) _navigateScreen(data);
    } catch (e) {
      Loggers.error(e);
      stopLoader();
      showSnackBar('فشل تسجيل الدخول ب‌ Google');
    }
  }

  Future<void> onAppleTap() async {
    showLoader();
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final email = userCredential.user?.email ?? appleCredential.email ?? '';
      final fullname = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();

      final data = await _loginUser(
        identity: email.isNotEmpty ? email : userCredential.user?.uid ?? '',
        loginMethod: LoginMethod.apple,
        fullname: fullname.isNotEmpty ? fullname : 'Apple User',
      );
      stopLoader();
      if (data != null) _navigateScreen(data);
    } catch (e) {
      Loggers.error(e);
      stopLoader();
      showSnackBar('فشل تسجيل الدخول ب‌ Apple');
    }
  }

  Future<user.User?> _loginUser({
    required String identity,
    required LoginMethod loginMethod,
    String? fullname,
  }) async {
    String deviceToken = await FirebaseNotificationManager.instance.getNotificationToken() ?? '';
    return await UserService.instance.logInUser(
      identity: identity,
      loginMethod: loginMethod,
      deviceToken: deviceToken,
      fullName: fullname,
    );
  }

  Future<UserCredential?> signInWithEmailAndPassword() async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      return null;
    }
  }

  void _navigateScreen(user.User? data) {
    DebounceAction.shared.call(() async {
      SessionManager.instance.setLogin(true);
      SessionManager.instance.setUser(data);
      Get.offAll(() => DashboardScreen(myUser: data));
    }, milliseconds: 250);
  }
}

enum LoginMethod { email, google, apple }