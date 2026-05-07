import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/gradient_text.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SendGiftDialog extends StatefulWidget {
  final Gift gift;

  const SendGiftDialog({super.key, required this.gift});

  @override
  State<SendGiftDialog> createState() => _SendGiftDialogState();
}

class _SendGiftDialogState extends State<SendGiftDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: AppRes.giftDialogDismissTime), () {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      alignment: const Alignment(0, 0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.network(
            widget.gift.image?.addBaseURL() ?? '',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return CustomImage(
                  image: widget.gift.image?.addBaseURL(),
                  size: const Size(150, 150),
                  radius: 0);
            },
          ),
          Text(LKey.yourGiftHasBeenSent.tr,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 15, color: whitePure(context))),
          GradientText(LKey.successfully.tr,
              gradient: StyleRes.themeGradient,
              style: TextStyleCustom.unboundedSemiBold600(fontSize: 15)),
        ],
      ),
    );
  }
}
