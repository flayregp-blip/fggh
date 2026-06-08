import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/auth_screen/auth_screen_controller.dart';
import 'package:shortzz/screen/auth_screen/forget_password_sheet.dart';
import 'package:shortzz/screen/auth_screen/registration_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthScreenController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LKey.signIn.tr.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                LKey.toContinue.tr.toUpperCase(),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),

              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: controller.emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  decoration: InputDecoration(
                    hintText: LKey.enterYourEmail.tr,
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
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
                ),
                child: TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  decoration: InputDecoration(
                    hintText: LKey.enterPassword.tr,
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
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
                  child: Text(LKey.forgetPassword.tr, style: const TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 30),

              TextButtonCustom(
                onTap: controller.onLogin,
                title: LKey.logIn.tr,
                btnHeight: 52,
                horizontalMargin: 0,
              ),
              const SizedBox(height: 40),

              InkWell(
                onTap: () {
                  Get.to(() => const RegistrationScreen());
                },
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(LKey.createAccountHere.tr, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}