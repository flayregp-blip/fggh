import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_divider.dart';
import 'package:shortzz/common/widget/privacy_policy_text.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/auth_screen/auth_screen_controller.dart';
import 'package:shortzz/screen/auth_screen/forget_password_sheet.dart';
import 'package:shortzz/screen/auth_screen/registration_screen.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthScreenController());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: Get.height,
        color: Colors.black,
        child: SingleChildScrollView(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 45),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: LKey.signIn.tr.toUpperCase(),
                          style: TextStyleCustom.unboundedBlack900(
                            fontSize: 26,
                            color: whitePure(context),
                          ).copyWith(letterSpacing: -.2),
                          children: [
                            TextSpan(
                              text: '\n${LKey.toContinue.tr}'.toUpperCase(),
                              style: TextStyleCustom.unboundedBlack900(
                                fontSize: 26,
                                color: whitePure(context).withValues(alpha: .5),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 55),
                      _buildField(
                        context: context,
                        hint: LKey.enterYourEmail.tr,
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        context: context,
                        hint: LKey.enterPassword.tr,
                        controller: controller.passwordController,
                        isPassword: true,
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: InkWell(
                          onTap: () {
                            Get.bottomSheet(const ForgetPasswordSheet(), isScrollControlled: true)
                                .then((value) => controller.forgetEmailController.clear());
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(LKey.forgetPassword.tr,
                                style: TextStyleCustom.outFitRegular400(
                                    fontSize: 16, color: whitePure(context))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButtonCustom(
                        onTap: controller.onLogin,
                        title: LKey.logIn.tr,
                        btnHeight: 52,
                        horizontalMargin: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                InkWell(
                  onTap: () {
                    controller.fullNameController.clear();
                    controller.emailController.clear();
                    controller.passwordController.clear();
                    controller.confirmPassController.clear();
                    Get.to(() => const RegistrationScreen());
                  },
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    color: whitePure(context).withValues(alpha: .1),
                    child: Text(LKey.createAccountHere.tr,
                        style: TextStyleCustom.outFitRegular400(
                            color: whitePure(context), fontSize: 16)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomDivider(color: whitePure(context), height: .5, width: 100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(LKey.continueWith.tr,
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 16, color: whitePure(context))),
                    ),
                    CustomDivider(color: whitePure(context), height: .5, width: 100),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (Platform.isIOS)
                        _buildSocial(AssetRes.icApple, controller.onAppleTap),
                      if (Platform.isIOS) const SizedBox(width: 12),
                      _buildSocial(AssetRes.icGoogle, controller.onGoogleTap),
                    ],
                  ),
                ),
                PrivacyPolicyText(
                  boldTextColor: whitePure(context),
                  regularTextColor: whitePure(context).withValues(alpha: .8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1.3,
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyleCustom.outFitRegular400(color: whitePure(context), fontSize: 17),
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyleCustom.outFitRegular400(
            color: whitePure(context).withValues(alpha: .5),
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
        cursorColor: whitePure(context),
      ),
    );
  }

  Widget _buildSocial(String icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 58,
        width: 58,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Image.asset(icon, height: 30, width: 30),
      ),
    );
  }
}
