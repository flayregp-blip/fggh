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
import 'package:shortzz/common/service/api/notification_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/languages/dynamic_translations.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/user_model/user_model.dart' as user;
import 'package:shortzz/screen/dashboard_screen/dashboard_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthScreenController extends BaseController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController forgetEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void onInit() {
    CommonService.instance.fetchGlobalSettings();
    super.onInit();
  }

  // ==================== EMAIL LOGIN ====================
  Future<void> onLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) return showSnackBar(LKey.enterEmail.tr);
    if (password.isEmpty) return showSnackBar(LKey.enterAPassword.tr);

    showLoader();

    if (GetUtils.isEmail(email)) {
      final UserCredential? credential = await signInWithEmailAndPassword();
      if (credential == null) {
        stopLoader();
        return showSnackBar(LKey.userNotFound.tr);
      }
      if (credential.user?.emailVerified == false) {
        stopLoader();
        return showSnackBar(LKey.verifyEmailFirst.tr);
      }

      String fullname = credential.user?.displayName ?? email.split('@')[0];
      final user.User? data = await _logInUser(identity: email, loginMethod: LoginMethod.email, fullname: fullname);
      stopLoader();
      if (data != null) _navigateScreen(data);
    } else {
      final user.User? data = await _logInFakeUser(identity: email, loginMethod: LoginMethod.email, password: password);
      stopLoader();
      if (data != null) _navigateScreen(data);
    }
  }

  // ==================== NATIVE GOOGLE SIGN IN ====================
  Future<void> onGoogleTap() async {
    showLoader();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        stopLoader();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final email = userCredential.user?.email ?? '';
      final fullname = userCredential.user?.displayName ?? email.split('@')[0];

      final user.User? data = await _logInUser(
          identity: email, loginMethod: LoginMethod.google, fullname: fullname);

      stopLoader();
      if (data != null) _navigateScreen(data);
    } catch (e) {
      Loggers.error(e);
      stopLoader();
      showSnackBar('فشل تسجيل الدخول بـ Google');
    }
  }

  // ==================== APPLE SIGN IN ====================
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

      final user.User? data = await _logInUser(
          identity: email.isNotEmpty ? email : userCredential.user?.uid ?? '',
          loginMethod: LoginMethod.apple,
          fullname: fullname.isNotEmpty ? fullname : 'Apple User');

      stopLoader();
      if (data != null) _navigateScreen(data);
    } catch (e) {
      Loggers.error(e);
      stopLoader();
      showSnackBar('فشل تسجيل الدخول بـ Apple');
    }
  }

  // ==================== Helper Methods ====================
  Future<user.User?> _logInUser({
    required String identity,
    required LoginMethod loginMethod,
    String? fullname,
  }) async {
    String deviceToken = await FirebaseNotificationManager.instance.getNotificationToken() ?? '';
    return await UserService.instance.logInUser(
        identity: identity,
        loginMethod: loginMethod,
        deviceToken: deviceToken,
        fullName: fullname);
  }

  Future<user.User?> _logInFakeUser({
    required String identity,
    required LoginMethod loginMethod,
    String? password,
  }) async {
    String deviceToken = await FirebaseNotificationManager.instance.getNotificationToken() ?? '';
    return await UserService.instance.logInFakeUser(
        identity: identity,
        loginMethod: loginMethod,
        deviceToken: deviceToken,
        password: password);
  }

  Future<UserCredential?> createUserWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      SessionManager.instance.setPassword(passwordController.text.trim());
      return credential;
    } on FirebaseAuthException catch (e) {
      stopLoader();
      if (e.code == 'weak-password') showSnackBar(LKey.weakPassword.tr);
      else if (e.code == 'email-already-in-use') showSnackBar(LKey.accountExists.tr);
      else showSnackBar(e.message);
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword() async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      stopLoader();
      if (e.code == 'user-not-found') showSnackBar(LKey.noUserFound.tr);
      else if (e.code == 'wrong-password') showSnackBar(LKey.incorrectPassword.tr);
      return null;
    } catch (e) {
      return null;
    }
  }

  void forgetPassword() async {
    final email = forgetEmailController.text.trim();
    if (email.isEmpty) {
      showSnackBar(LKey.enterEmail.tr);
      return;
    }
    showLoader();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      stopLoader();
      Get.back();
      showSnackBar(LKey.resetPasswordLinkSent.tr);
    } on FirebaseAuthException catch (e) {
      stopLoader();
      showSnackBar(e.message ?? "An error occurred. Please try again.");
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
