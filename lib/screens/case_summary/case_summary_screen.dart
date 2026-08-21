import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/micro_interactions.dart';
import '../../core/constants/route_constants.dart';
import '../../core/localization/localization_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/document_provider.dart';
// import '../../providers/eligibility_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/triage_provider.dart';

class CaseSummaryScreen extends StatefulWidget {
  const CaseSummaryScreen({super.key});

  @override
  State<CaseSummaryScreen> createState() => _CaseSummaryScreenState();
}

class _CaseSummaryScreenState extends State<CaseSummaryScreen> {
  final int _selectedTab = 1; // 0: Start, 1: My case (active)

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final langCode = languageProvider.currentLanguageCode;
    final docProvider = Provider.of<DocumentProvider>(context);
    final triageProvider = Provider.of<TriageProvider>(context);
    // final eligibilityProvider = Provider.of<EligibilityProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasDocs = docProvider.documents.isNotEmpty;
    final docName = hasDocs ? docProvider.documents.first.fileName : null;

    // Use backend category from triage provider, or show "Not determined yet"
    final categoryName =
        triageProvider.category?.title ??
        (triageProvider.backendCategory != null
            ? _formatBackendCategory(triageProvider.backendCategory!)
            : LocalizationService.getText(langCode, 'notDeterminedYet'));

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF0F172A),
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationService.getText(langCode, 'reviewCaseTitle'),
          style: AppTextStyles.titleMedium(
            isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
          ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Title & Subtitle ──────────────────────────────────
              Text(
                LocalizationService.getText(langCode, 'reviewWhatYouShared'),
                style: AppTextStyles.titleLarge(
                  isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                ).copyWith(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                LocalizationService.getText(langCode, 'answersReadyForRouting'),
                style: AppTextStyles.bodyMedium(
                  isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF64748B),
                ).copyWith(fontSize: 13),
              ),

              const SizedBox(height: 12),

              // ── Progress Bar (6 of 7 sections complete) ────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '6 of 7 ${LocalizationService.getText(langCode, "allSectionsComplete")}',
                    style: AppTextStyles.caption(
                      isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF64748B),
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '85%',
                    style: AppTextStyles.caption(
                      const Color(0xFF2563EB),
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.85,
                  minHeight: 4,
                  backgroundColor: Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
              ),

              const SizedBox(height: 20),

              // ── Card 1: Intake Signals ─────────────────────────────────
              _buildIntakeSignalsCard(
                categoryName,
                isDark,
                langCode,
                triageProvider,
              ),

              const SizedBox(height: 14),

              // ── Card 2: From your document ─────────────────────────────
              if (hasDocs) _buildFromDocumentCard(docName!, isDark, langCode),

              const SizedBox(height: 14),

              // ── Card 3: Before you send ─────────────────────────────────
              _buildBeforeYouSendCard(
                languageProvider.currentLanguageName,
                isDark,
                langCode,
              ),

              const SizedBox(height: 14),

              // ── Eligibility Pre-Screening Section (Bypassed) ─────────────
              // _buildEligibilitySection(eligibilityProvider, isDark, langCode),
              const SizedBox(height: 24),

              // ── Primary Action: Proceed to Volunteer Lawyer Matching ───
              AnimatedPressScale(
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.matching);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      LocalizationService.getText(langCode, 'sendForReview'),
                      style: AppTextStyles.label(
                        Colors.white,
                      ).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark, langCode),
    );
  }

  // ── Card 1: Intake Signals ──────────────────────────────────────────────
  Widget _buildIntakeSignalsCard(
    String categoryName,
    bool isDark,
    String langCode,
    TriageProvider triageProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.getText(langCode, 'intakeSignals'),
            style: AppTextStyles.caption(
              isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
            ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Likely category
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                color: Color(0xFF2563EB),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                LocalizationService.getText(langCode, 'likelyCategory'),
                style: AppTextStyles.bodyMedium(
                  isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                categoryName,
                style: AppTextStyles.label(
                  const Color(0xFF2563EB),
                ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Urgency - always show, green if not urgent
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: Color(0xFFD97706),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                LocalizationService.getText(langCode, 'urgency'),
                style: AppTextStyles.bodyMedium(
                  isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (triageProvider.urgency != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    triageProvider.urgency!.title,
                    style: AppTextStyles.caption(
                      const Color(0xFFB45309),
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Not urgent',
                    style: AppTextStyles.caption(
                      const Color(0xFFFFFFFF),
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Info footer
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF2563EB),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                LocalizationService.getText(langCode, 'usedToRoute'),
                style: AppTextStyles.caption(
                  isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF64748B),
                ).copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card 2: From your document ─────────────────────────────────────────
  Widget _buildFromDocumentCard(String docName, bool isDark, String langCode) {
    final docProvider = Provider.of<DocumentProvider>(context);
    final extractedDates = docProvider.documents.isNotEmpty
        ? docProvider.documents.first.extractedDates
        : [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.getText(langCode, 'fromYourDocument'),
            style: AppTextStyles.caption(
              isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
            ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Document tile
          InkWell(
            onTap: () =>
                Navigator.pushNamed(context, RouteConstants.documentReview),
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    docName,
                    style: AppTextStyles.bodyMedium(
                      isDark
                          ? AppColors.textPrimaryDark
                          : const Color(0xFF0F172A),
                    ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Response date found (only show if dates were extracted)
          if (extractedDates.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  LocalizationService.getText(langCode, 'responseDateFound'),
                  style: AppTextStyles.bodyMedium(
                    isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF0F172A),
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  extractedDates.first.date,
                  style: AppTextStyles.label(
                    const Color(0xFF2563EB),
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
          ],

          // Info footer
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF2563EB),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                extractedDates.isNotEmpty
                    ? LocalizationService.getText(
                        langCode,
                        'checkDateBeforeSending',
                      )
                    : 'No dates extracted from document',
                style: AppTextStyles.caption(
                  isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF64748B),
                ).copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card 3: Before you send ────────────────────────────────────────────
  Widget _buildBeforeYouSendCard(
    String langName,
    bool isDark,
    String langCode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.getText(langCode, 'beforeYouSend'),
            style: AppTextStyles.caption(
              isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
            ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Your situation Edit
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  LocalizationService.getText(langCode, 'yourSituationTitle'),
                  style: AppTextStyles.bodyMedium(
                    isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF0F172A),
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      LocalizationService.getText(langCode, 'edit'),
                      style: AppTextStyles.caption(
                        const Color(0xFF2563EB),
                      ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Preferred language
          InkWell(
            onTap: () => Navigator.pushNamed(context, RouteConstants.language),
            child: Row(
              children: [
                const Icon(
                  Icons.language_rounded,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  LocalizationService.getText(langCode, 'preferredLanguage'),
                  style: AppTextStyles.bodyMedium(
                    isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF0F172A),
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      langName,
                      style: AppTextStyles.caption(
                        const Color(0xFF2563EB),
                      ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section: Eligibility Pre-Screening ─────────────────────────────────
  /*
  Widget _buildEligibilitySection(
      EligibilityProvider provider, bool isDark, String langCode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizationService.getText(langCode, 'eligibilityPreScreening'),
                style: AppTextStyles.caption(
                  isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '3 of 4 checks complete',
                style: AppTextStyles.caption(const Color(0xFF2563EB))
                    .copyWith(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _checkRow(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF16A34A),
            text: LocalizationService.getText(langCode, 'housingIssueIdentified'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _checkRow(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF16A34A),
            text: LocalizationService.getText(langCode, 'incomeInfoReceived'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _checkRow(
            icon: Icons.help_outline_rounded,
            color: const Color(0xFFD97706),
            text: LocalizationService.getText(
                langCode, 'residencyNeedsConfirmation'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
  */

  /*
  Widget _checkRow({
    required IconData icon,
    required Color color,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodyMedium(
            isDark ? AppColors.textPrimaryDark : const Color(0xFF334155),
          ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
  */

  String _formatBackendCategory(String backendCategory) {
    // Convert backend category to display title
    switch (backendCategory.toUpperCase()) {
      case 'HOUSING_EVICTION':
        return 'Housing & Eviction';
      case 'EMPLOYMENT':
        return 'Employment & Labor Rights';
      case 'FAMILY':
        return 'Family Law';
      case 'CRIMINAL':
        return 'Criminal Law';
      case 'CONSUMER':
        return 'Consumer Protection';
      default:
        return backendCategory
            .split('_')
            .map(
              (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  // ── Bottom Navigation Bar ──────────────────────────────────────────────
  Widget _buildBottomNavBar(bool isDark, String langCode) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: LocalizationService.getText(langCode, 'start'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_rounded),
            label: LocalizationService.getText(langCode, 'myCase'),
          ),
        ],
      ),
    );
  }
}
