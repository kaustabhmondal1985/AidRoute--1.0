import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitThreeBounce(
              color: AppColors.primaryLight,
              size: 32.0,
            ),
            if (message != null) ...[
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
