import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/micro_interactions.dart';
import '../../core/constants/route_constants.dart';
import '../../core/localization/localization_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/language_provider.dart';
import '../../providers/matching_provider.dart';
import '../../providers/triage_provider.dart';

class LawyerMatchingScreen extends StatefulWidget {
  const LawyerMatchingScreen({super.key});

  @override
  State<LawyerMatchingScreen> createState() => _LawyerMatchingScreenState();
}

class _LawyerMatchingScreenState extends State<LawyerMatchingScreen> {
  int _selectedBottomTab = 1; // 0: Cases, 1: Lawyers (active), 2: Schedule

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final triageProvider = Provider.of<TriageProvider>(
        context,
        listen: false,
      );
      final langCode = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).currentLanguageCode;
      final matchingProvider = Provider.of<MatchingProvider>(
        context,
        listen: false,
      );

      matchingProvider.fetchMatches(
        triageProvider.category?.id ?? 'cat_housing',
        langCode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchingProvider = Provider.of<MatchingProvider>(context);
    final selectedMatch = matchingProvider.selectedMatch;
    final langProvider = Provider.of<LanguageProvider>(context);
    final langCode = langProvider.currentLanguageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF0F172A),
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Screen Title ────────────────────────────────────────────
              Text(
                LocalizationService.getText(langCode, 'volunteerLawyers'),
                style: AppTextStyles.titleLarge(
                  isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                ).copyWith(fontSize: 24, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 16),

              // ── Filter Card Component ──────────────────────────────────
              _buildFilterCard(isDark, langCode),

              const SizedBox(height: 20),

              // ── Section: Best Matches ──────────────────────────────────
              Text(
                LocalizationService.getText(langCode, 'bestMatches'),
                style: AppTextStyles.caption(
                  isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF64748B),
                ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              // ── Attorney Match List ─────────────────────────────────────
              if (matchingProvider.matches.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : const Color(0xFFF1F5F9),
                    ),
                  ),
                  child: Column(
                    children: List.generate(matchingProvider.matches.length, (
                      i,
                    ) {
                      final match = matchingProvider.matches[i];
                      final isSelected =
                          selectedMatch?.lawyer.id == match.lawyer.id;
                      final isLast = i == matchingProvider.matches.length - 1;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => matchingProvider.selectMatch(match),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // Initials Circle Avatar
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFDBEAFE)
                                          : const Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getInitials(match.lawyer.fullName),
                                        style:
                                            AppTextStyles.label(
                                              const Color(0xFF2563EB),
                                            ).copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Lawyer Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          match.lawyer.fullName,
                                          style:
                                              AppTextStyles.titleMedium(
                                                isDark
                                                    ? AppColors.textPrimaryDark
                                                    : const Color(0xFF0F172A),
                                              ).copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${match.lawyer.organization} • ${match.lawyer.languages.join(", ")}',
                                          style: AppTextStyles.caption(
                                            isDark
                                                ? AppColors.textSecondaryDark
                                                : const Color(0xFF64748B),
                                          ).copyWith(fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF16A34A),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                match.lawyer.nextAvailableSlot,
                                                style: AppTextStyles.caption(
                                                  const Color(0xFF475569),
                                                ).copyWith(fontSize: 11),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast)
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ],
                      );
                    }),
                  ),
                ),

              const SizedBox(height: 20),

              // ── Section: Why these matches ─────────────────────────────
              Text(
                LocalizationService.getText(langCode, 'whyTheseMatches'),
                style: AppTextStyles.caption(
                  isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF64748B),
                ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Housing specialty, language support, and availability',
                        style: AppTextStyles.bodyMedium(
                          isDark
                              ? AppColors.textPrimaryDark
                              : const Color(0xFF334155),
                        ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Action Button: Request a volunteer / Assign Lawyer ─────
              AnimatedPressScale(
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.appointment);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      LocalizationService.getText(
                        langCode,
                        'requestAVolunteer',
                      ),
                      style: AppTextStyles.label(
                        const Color(0xFF2563EB),
                      ).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark, langCode),
    );
  }

  // ── Filter Card Component matching Image 2 ─────────────────────────────────
  Widget _buildFilterCard(bool isDark, String langCode) {
    final triageProvider = Provider.of<TriageProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    final category =
        triageProvider.category?.title ??
        (triageProvider.backendCategory != null
            ? _formatBackendCategory(triageProvider.backendCategory!)
            : 'Not determined');

    final language = languageProvider.currentLanguageName;

    // Get case summary from triage provider (will be populated from backend)
    final caseSummary = triageProvider.caseSummary ?? '';

    return Container(
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
        children: [
          // Case Summary section (replaces Match For)
          _buildCaseSummarySection(caseSummary, isDark, langCode),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _filterRow(
            icon: Icons.business_center_outlined,
            label: LocalizationService.getText(langCode, 'specialty'),
            value: category,
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _filterRow(
            icon: Icons.language_rounded,
            label: LocalizationService.getText(langCode, 'language'),
            value: language,
            isDark: isDark,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _filterRow(
            icon: Icons.calendar_today_outlined,
            label: LocalizationService.getText(langCode, 'available'),
            value: LocalizationService.getText(langCode, 'thisWeek'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCaseSummarySection(
    String summary,
    bool isDark,
    String langCode,
  ) {
    if (summary.isEmpty) {
      // Loading state
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: Color(0xFF2563EB),
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              LocalizationService.getText(langCode, 'caseSummary') ??
                  'Case Summary',
              style: AppTextStyles.bodyMedium(
                isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
              ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 6),
            const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
            const SizedBox(width: 6),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
      );
    }

    // Show summary
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: Color(0xFF2563EB),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                LocalizationService.getText(langCode, 'caseSummary') ??
                    'Case Summary',
                style: AppTextStyles.bodyMedium(
                  isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF64748B),
                ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: AppTextStyles.bodyMedium(
              isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
            ).copyWith(fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _filterRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.bodyMedium(
              isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
            ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium(
                isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
              ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation Bar (Cases, Lawyers, Schedule) ────────────────────
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
        currentIndex: _selectedBottomTab,
        onTap: (index) {
          setState(() => _selectedBottomTab = index);
          if (index == 2) {
            Navigator.pushNamed(context, RouteConstants.appointment);
          } else if (index == 0) {
            Navigator.pushNamed(context, RouteConstants.caseSummary);
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
            icon: const Icon(Icons.folder_open_rounded),
            label: LocalizationService.getText(langCode, 'cases'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_alt_rounded),
            label: LocalizationService.getText(langCode, 'lawyers'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_rounded),
            label: LocalizationService.getText(langCode, 'schedule'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    } else if (name.isNotEmpty) {
      return name.substring(0, 2).toUpperCase();
    }
    return 'AT';
  }

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
}
