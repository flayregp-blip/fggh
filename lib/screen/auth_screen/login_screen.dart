import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/auth_screen/auth_screen_controller.dart';
import 'package:shortzz/screen/auth_screen/forget_password_sheet.dart';
import 'package:shortzz/screen/auth_screen/registration_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthScreenController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                Text(
                  LKey.signIn.tr.toUpperCase(),
                  style: TextStyleCustom.unboundedBlack900(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LKey.toContinue.tr.toUpperCase(),
                  style: TextStyleCustom.unboundedBlack900(
                    fontSize: 28,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 70),

                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
                  ),
                  child: TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                    decoration: InputDecoration(
                      hintText: LKey.enterYourEmail.tr,
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
                  ),
                  child: TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                    decoration: InputDecoration(
                      hintText: LKey.enterPassword.tr,
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Get.bottomSheet(const ForgetPasswordSheet(), isScrollControlled: true);
                    },
                    child: Text(
                      LKey.forgetPassword.tr,
                      style: TextStyleCustom.outFitRegular400(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                TextButtonCustom(
                  onTap: controller.onLogin,
                  title: LKey.logIn.tr,
                  btnHeight: 52,
                  horizontalMargin: 0,
                ),

                const SizedBox(height: 40),

                InkWell(
                  onTap: () => Get.to(() => const RegistrationScreen()),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      LKey.createAccountHere.tr,
                      style: TextStyleCustom.outFitRegular400(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
