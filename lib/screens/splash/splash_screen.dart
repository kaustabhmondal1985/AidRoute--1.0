import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

import '../../core/widgets/app_loader.dart';
import '../../providers/app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.initializeApp();
    if (mounted) {
      Navigator.pushReplacementNamed(context, RouteConstants.language);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [AppColors.backgroundDark, AppColors.primaryDark]
                    : [AppColors.backgroundLight, AppColors.primaryContainer],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScaleIn(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.balance_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      AppConstants.appName,
                      style: AppTextStyles.display(
                        isDark ? AppColors.textPrimaryDark : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 450),
                    child: Text(
                      AppConstants.appTagline,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium(
                        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),
                  const AnimatedFadeSlide(
                    delay: Duration(milliseconds: 600),
                    child: AppLoader(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
