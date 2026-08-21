import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/animations/micro_interactions.dart';
import '../../core/constants/route_constants.dart';
import '../../core/localization/localization_service.dart';
import '../../core/localization/supported_languages.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/language_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final selectedCode = languageProvider.currentLanguageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Brand Logo & Header Shield
              AnimatedFadeSlide(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primaryLight,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'AidRoute',
                  style: AppTextStyles.titleLarge(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  LocalizationService.getText(selectedCode, 'appSubtitle'),
                  style: AppTextStyles.bodyMedium(
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Staff Review Sharing Notice Banner
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 160),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.15)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.primaryLight : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          LocalizationService.getText(selectedCode, 'sharingNotice'),
                          style: AppTextStyles.caption(
                            isDark ? AppColors.textPrimaryDark : const Color(0xFF1E40AF),
                          ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Sub-header
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFadeSlide(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    LocalizationService.getText(selectedCode, 'chooseLanguageHeader'),
                    style: AppTextStyles.caption(
                      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ).copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Language Cards List
              Expanded(
                child: ListView.builder(
                  itemCount: SupportedLanguages.languages.length,
                  itemBuilder: (context, index) {
                    final lang = SupportedLanguages.languages[index];
                    final isSelected = lang.code == selectedCode;

                    return AnimatedFadeSlide(
                      delay: Duration(milliseconds: 240 + (index * 50)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                        child: AnimatedPressScale(
                          onTap: () => languageProvider.selectLanguage(lang),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? (isSelected
                                      ? AppColors.primaryLight.withValues(alpha: 0.2)
                                      : AppColors.surfaceDark)
                                  : (isSelected ? Colors.white : AppColors.surfaceLight),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryLight.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    lang.flagEmoji,
                                    style: TextStyle(
                                      fontSize: lang.flagEmoji.length == 1 ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.paddingM),
                                Text(
                                  lang.nativeName,
                                  style: AppTextStyles.titleMedium(
                                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ).copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                                if (lang.name != lang.nativeName) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${lang.name})',
                                    style: AppTextStyles.caption(
                                      isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.borderDark),
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Primary Button
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 450),
                child: AppButton(
                  label: LocalizationService.getText(selectedCode, 'continueText'),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, RouteConstants.home);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
