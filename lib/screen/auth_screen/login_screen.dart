import 'dart:io';

import 'package:figma_squircle_updated/figma_squircle.dart';
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
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: LKey.signIn.tr.toUpperCase(),
                                style: TextStyleCustom.unboundedBlack900(
                                  fontSize: 25,
                                  color: whitePure(context),
                                ).copyWith(letterSpacing: -.2),
                                children: [
                                  TextSpan(
                                    text: '\n${LKey.toContinue.tr}'.toUpperCase(),
                                    style: TextStyleCustom.unboundedBlack900(
                                      fontSize: 25,
                                      color: whitePure(context).withValues(alpha: .5),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          // ===== الحقول بتصميم أقوى =====
                          LoginSheetTextField(
                            hintText: LKey.enterYourEmail.tr,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          LoginSheetTextField(
                            isPasswordField: true,
                            hintText: LKey.enterPassword.tr,
                            controller: controller.passwordController,
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: InkWell(
                              onTap: () {
                                Get.bottomSheet(const ForgetPasswordSheet(), isScrollControlled: true)
                                    .then((value) => controller.forgetEmailController.clear());
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                child: Text(
                                  LKey.forgetPassword.tr,
                                  style: TextStyleCustom.outFitRegular400(
                                    fontSize: 16,
                                    color: whitePure(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextButtonCustom(
                            onTap: controller.onLogin,
                            title: LKey.logIn.tr,
                            btnHeight: 50,
                            horizontalMargin: 0,
                          ),
                        ],
                      ),
                    ),
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
                        margin: const EdgeInsets.symmetric(vertical: 25),
                        alignment: Alignment.center,
                        color: whitePure(context).withValues(alpha: .12),
                        child: Text(
                          LKey.createAccountHere.tr,
                          style: TextStyleCustom.outFitRegular400(
                            color: whitePure(context),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomDivider(color: whitePure(context), height: .5, width: 100),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            LKey.continueWith.tr,
                            style: TextStyleCustom.outFitRegular400(
                              fontSize: 16,
                              color: whitePure(context),
                            ),
                          ),
                        ),
                        CustomDivider(color: whitePure(context), height: .5, width: 100),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (Platform.isIOS)
                            SocialBtn(onTap: controller.onAppleTap, icon: AssetRes.icApple),
                          if (Platform.isIOS) const SizedBox(width: 10),
                          SocialBtn(onTap: controller.onGoogleTap, icon: AssetRes.icGoogle),
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
          ],
        ),
      ),
    );
  }
}

class LoginSheetTextField extends StatefulWidget {
  final bool isPasswordField;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const LoginSheetTextField({
    super.key,
    this.isPasswordField = false,
    required this.hintText,
    required this.controller,
    this.keyboardType,
  });

  @override
  State<LoginSheetTextField> createState() => _LoginSheetTextFieldState();
}

class _LoginSheetTextFieldState extends State<LoginSheetTextField> {
  bool isHide = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          side: BorderSide(color: whitePure(context).withValues(alpha: .6), width: 1.5),
        ),
        color: Colors.white.withValues(alpha: 0.12), // ← خليناها أقوى
      ),
      child: TextField(
        controller: widget.controller,
        style: TextStyleCustom.outFitRegular400(color: whitePure(context), fontSize: 17),
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        obscureText: widget.isPasswordField && isHide,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: TextStyleCustom.outFitRegular400(
            color: whitePure(context).withValues(alpha: .55),
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          suffixIcon: widget.isPasswordField
              ? InkWell(
                  onTap: () {
                    isHide = !isHide;
                    setState(() {});
                  },
                  child: Icon(
                    isHide ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: whitePure(context).withValues(alpha: .75),
                    size: 24,
                  ),
                )
              : null,
        ),
        cursorColor: whitePure(context),
      ),
    );
  }
}

class SocialBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const SocialBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 58,
        width: 58,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: Image.asset(icon, height: 30, width: 30),
      ),
    );
  }
}
