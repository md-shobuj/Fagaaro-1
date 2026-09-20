import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/dimensions.dart';

class AppFormCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double minHeight;

  const AppFormCard({
    super.key,
    required this.child,
    this.width,
    this.minHeight = 740,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final outerColor = AppColors.outerCard(isDark);
    final borderColor = AppColors.cardBorder(isDark);
    final shadowColor = AppColors.shadow(isDark);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minHeight,
      ),
      child: Container(
        width: width ?? (isTablet ? screenWidth * 1 : screenWidth * 1),
        padding: EdgeInsets.all(AppDimensions.radiusM),
        decoration: ShapeDecoration(
          color: outerColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusPhoneOuter),
          ),
          shadows: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 30.r,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight - 20),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: outerColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusContainer),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
