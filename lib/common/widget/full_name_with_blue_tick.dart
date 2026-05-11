import 'package:flutter/material.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FullNameWithBlueTick extends StatelessWidget {
  final Widget? child;
  final double? iconSize;
  final double? fontSize;
  final Color? fontColor;
  final String? icon;
  final String? username;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final TextStyle? style;
  final int? isVerify;
  final int? verifyType;
  final VoidCallback? onTap;
  final double opacity;

  const FullNameWithBlueTick({
    super.key,
    required this.username,
    this.child,
    this.iconSize,
    this.fontSize,
    this.fontColor,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.icon,
    this.style,
    this.isVerify = 0,
    this.verifyType = 1,
    this.onTap,
    this.opacity = 1,
  });

  // ✅ العلامة كلها أصبحت زرقاء
  Color _getVerifyColor() {
    return Colors.blue;
  }

  String _getVerifyTitle() {
    return 'مستخدم موثق';
  }

  String _getVerifyDescription() {
    return 'هذا الحساب تم التحقق من هويته';
  }

  void _showVerifyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified,
              color: _getVerifyColor(),
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              _getVerifyTitle(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getVerifyDescription(),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment:
            mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment:
            crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              username ?? '',
              style: style ??
                  TextStyleCustom.unboundedMedium500(
                    color: fontColor ?? textDarkGrey(context),
                    fontSize: fontSize ?? 11,
                    opacity: opacity,
                  ).copyWith(height: 2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (isVerify == 1)
            const SizedBox(width: 3),

          if (isVerify == 1)
            GestureDetector(
              onTap: () => _showVerifyDialog(context),
              child: Icon(
                Icons.verified,
                size: iconSize ?? 15,
                color: _getVerifyColor(),
              ),
            ),

          const SizedBox(width: 6),

          if (child != null)
            child!,
        ],
      ),
    );
  }
}
