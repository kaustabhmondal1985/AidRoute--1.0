import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/animations/micro_interactions.dart';
import '../../core/constants/route_constants.dart';
import '../../core/localization/localization_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/language_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final conversationProvider = Provider.of<ConversationProvider>(context);
    final langCode = languageProvider.currentLanguageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pushReplacementNamed(context, RouteConstants.language);
          },
        ),
        title: Text(
          LocalizationService.getText(langCode, 'welcomeTitle'),
          style: AppTextStyles.titleMedium(
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Emblem Card Graphic
              AnimatedFadeSlide(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.balance_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        LocalizationService.getText(langCode, 'welcomeTitle'),
                        style: AppTextStyles.titleLarge(
                          isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          LocalizationService.getText(langCode, 'welcomeSub'),
                          style: AppTextStyles.bodyMedium(
                            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ).copyWith(fontSize: 13, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Interactive Summary Cards List
              _buildStepCard(
                context: context,
                icon: Icons.chat_bubble_outline_rounded,
                title: LocalizationService.getText(langCode, 'explainSituation'),
                onTap: () {
                  conversationProvider.startConversation(langCode);
                  Navigator.pushNamed(context, RouteConstants.conversation);
                },
              ),
              const SizedBox(height: 10),
              _buildStepCard(
                context: context,
                icon: Icons.article_outlined,
                title: LocalizationService.getText(langCode, 'addDocsDates'),
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.documents);
                },
              ),
              const SizedBox(height: 10),
              _buildStepCard(
                context: context,
                icon: Icons.person_outline_rounded,
                title: LocalizationService.getText(langCode, 'submitReview'),
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.caseSummary);
                },
              ),

              const Spacer(),

              // Primary Action Button
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 300),
                child: AppButton(
                  label: LocalizationService.getText(langCode, 'startNewCase'),
                  onPressed: () {
                    conversationProvider.startConversation(langCode);
                    Navigator.pushNamed(context, RouteConstants.conversation);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Footer Progress Note
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 350),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bookmark_border_rounded,
                      size: 16,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      LocalizationService.getText(langCode, 'saveProgressNote'),
                      style: AppTextStyles.caption(
                        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium(
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.borderDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
