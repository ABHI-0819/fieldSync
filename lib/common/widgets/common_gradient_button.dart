import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/config/constants/space.dart';
import '../../core/config/themes/app_color.dart';
import '../../core/config/themes/app_fonts.dart';

class CommonGradientButton extends StatelessWidget {
  const CommonGradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height,
    this.borderRadius,
    this.icon,
    this.textStyle,
    this.gradientColors,
    this.shadowColor,
  });

  final String text;
  final VoidCallback onTap;

  final double? height;
  final double? borderRadius;
  final IconData? icon;

  final TextStyle? textStyle;
  final List<Color>? gradientColors;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ??
              [AppColor.primary, AppColor.primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        boxShadow: [
          BoxShadow(
            color: (shadowColor ?? AppColor.primary).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: textStyle ??
                      AppFonts.regular.copyWith(
                        color: AppColor.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                if (icon != null) ...[
                  SizedBox(width: Spacing.small.w),
                  Icon(
                    icon,
                    color: AppColor.white,
                    size: 20.sp,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
