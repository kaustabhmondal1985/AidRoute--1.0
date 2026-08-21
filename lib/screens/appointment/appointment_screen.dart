import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/animations/micro_interactions.dart';
import '../../core/constants/route_constants.dart';
import '../../core/localization/localization_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/matching_provider.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '10:00 AM';
  AppointmentType _type = AppointmentType.virtual;

  final List<String> _slots = [
    '09:00 AM',
    '10:00 AM',
    '11:30 AM',
    '02:00 PM',
    '03:30 PM'
  ];

  @override
  Widget build(BuildContext context) {
    final matchingProvider = Provider.of<MatchingProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final langCode = languageProvider.currentLanguageCode;
    final selectedLawyer = matchingProvider.selectedMatch?.lawyer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.getText(langCode, 'scheduleConsultation')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Lawyer Summary Header
              if (selectedLawyer != null)
                AnimatedFadeSlide(
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(selectedLawyer.fullName[0],
                              style: AppTextStyles.label(Colors.white)),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedLawyer.fullName,
                              style: AppTextStyles.titleMedium(
                                isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              selectedLawyer.organization,
                              style: AppTextStyles.caption(
                                isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppDimensions.paddingL),

              // Consultation Type Switcher
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  LocalizationService.getText(langCode, 'selectConsultationMode'),
                  style: AppTextStyles.titleMedium(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                children: [
                  Expanded(
                    child: AnimatedPressScale(
                      onTap: () => setState(() => _type = AppointmentType.virtual),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: _type == AppointmentType.virtual
                              ? AppColors.primaryLight
                              : (isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.call,
                              color: _type == AppointmentType.virtual
                                  ? Colors.white
                                  : AppColors.primaryLight,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              LocalizationService.getText(langCode, 'scheduleCall'),
                              style: AppTextStyles.label(
                                _type == AppointmentType.virtual
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: AnimatedPressScale(
                      onTap: () => setState(() => _type = AppointmentType.inPerson),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: _type == AppointmentType.inPerson
                              ? AppColors.primaryLight
                              : (isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: _type == AppointmentType.inPerson
                                  ? Colors.white
                                  : AppColors.primaryLight,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              LocalizationService.getText(langCode, 'inPersonVisit'),
                              style: AppTextStyles.label(
                                _type == AppointmentType.inPerson
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Date Picker Selector
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 250),
                child: Text(
                  LocalizationService.getText(langCode, 'selectDate'),
                  style: AppTextStyles.titleMedium(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              AnimatedPressScale(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AppColors.primaryLight),
                          const SizedBox(width: AppDimensions.paddingM),
                          Text(
                            DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                            style: AppTextStyles.bodyLarge(
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Time Slots Grid
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 350),
                child: Text(
                  LocalizationService.getText(langCode, 'availableTimeSlots'),
                  style: AppTextStyles.titleMedium(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _slots.map((slot) {
                  final isSelected = slot == _selectedSlot;
                  return AnimatedPressScale(
                    onTap: () => setState(() => _selectedSlot = slot),
                    child: Chip(
                      backgroundColor: isSelected
                          ? AppColors.primaryLight
                          : (isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryLight
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                      ),
                      label: Text(
                        slot,
                        style: AppTextStyles.label(
                          isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Confirm Appointment Button
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 450),
                child: AppButton(
                  label: LocalizationService.getText(
                      langCode, 'confirmAppointmentSlot'),
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: selectedLawyer == null
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          await appointmentProvider.scheduleAppointment(
                            lawyer: selectedLawyer,
                            date: _selectedDate,
                            type: _type,
                          );
                          if (mounted) {
                            navigator.pushNamed(RouteConstants.confirmation);
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
