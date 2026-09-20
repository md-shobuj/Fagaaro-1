import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/dimensions.dart';

class AppBrandHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AppBrandHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.accent(isDark);
    final titleColor = AppColors.title(isDark);
    final subtitleColor = AppColors.subtitle(isDark);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: AppDimensions.sizeLogo,
          height: AppDimensions.sizeLogo,
          decoration: ShapeDecoration(
            color: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLogo),
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        // SizedBox(height: AppDimensions.spaceXL),
        // Text.rich(
        //   TextSpan(
        //     children: [
        //       TextSpan(
        //         text: 'Field',
        //         style: TextStyle(
        //           color: titleColor,
        //           fontSize: AppDimensions.fontTitleL,
        //           fontFamily: 'Inter',
        //           fontWeight: FontWeight.w800,
        //           letterSpacing: -0.44,
        //         ),
        //       ),
        //       TextSpan(
        //         text: 'Track',
        //         style: TextStyle(
        //           color: primaryColor,
        //           fontSize: AppDimensions.fontTitleL,
        //           fontFamily: 'Inter',
        //           fontWeight: FontWeight.w800,
        //           letterSpacing: -0.44,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        SizedBox(height: AppDimensions.space6XL),
        Text(
          title,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: titleColor,
            fontSize: AppDimensions.fontDisplayS,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.48,
          ),
        ),
        SizedBox(height: AppDimensions.spaceS),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: subtitleColor,
            fontSize: AppDimensions.fontL,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
