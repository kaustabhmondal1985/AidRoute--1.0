import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../models/case_summary_model.dart';

import '../../providers/appointment_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/document_provider.dart';
import '../../providers/eligibility_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/matching_provider.dart';
import '../../providers/routing_provider.dart';
import '../../providers/submission_provider.dart';
import '../../providers/triage_provider.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({super.key});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Alex Morgan');
  final TextEditingController _phoneController =
      TextEditingController(text: '(555) 234-5678');
  final TextEditingController _emailController =
      TextEditingController(text: 'alex.morgan@example.com');

  Future<void> _handleSubmit() async {
    final langCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final convProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    final triageProvider =
        Provider.of<TriageProvider>(context, listen: false);
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);
    final eligibilityProvider =
        Provider.of<EligibilityProvider>(context, listen: false);
    final matchingProvider =
        Provider.of<MatchingProvider>(context, listen: false);
    final aptProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final routingProvider =
        Provider.of<RoutingProvider>(context, listen: false);
    final submissionProvider =
        Provider.of<SubmissionProvider>(context, listen: false);

    final summary = CaseSummaryModel(
      id: 'CS-${DateTime.now().millisecondsSinceEpoch}',
      userName: _nameController.text,
      contactPhone: _phoneController.text,
      contactEmail: _emailController.text,
      languageCode: langCode,
      situationDescription: convProvider.answers.isNotEmpty
          ? convProvider.answers.first.responseText
          : 'Civil intake',
      answers: convProvider.answers,
      category: triageProvider.category,
      urgency: triageProvider.urgency,
      documents: docProvider.documents,
      extractedDates: docProvider.allExtractedDates,
      eligibility: eligibilityProvider.eligibility,
      lawyerMatch: matchingProvider.selectedMatch,
      appointment: aptProvider.appointment,
      routing: routingProvider.routing,
    );

    await submissionProvider.submitCase(summary);

    if (mounted && submissionProvider.state == ProviderState.success) {
      Navigator.pushNamed(context, RouteConstants.confirmation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionProvider = Provider.of<SubmissionProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Intake Review'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DisclaimerBanner(compact: true),
              const SizedBox(height: AppDimensions.paddingL),
              AnimatedFadeSlide(
                child: Text(
                  'Final Intake Review & Submission',
                  style: AppTextStyles.titleLarge(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Please confirm your contact details before sending your intake to legal-aid triage staff:',
                  style: AppTextStyles.bodyMedium(
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Contact Information Form Fields
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 200),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 250),
                child: TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 300),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              if (submissionProvider.state == ProviderState.error)
                AppErrorView(
                  message: submissionProvider.errorMessage ?? 'Submission failed.',
                  onRetry: _handleSubmit,
                ),

              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 350),
                child: AppButton(
                  label: 'Submit Intake to Legal-Aid Staff',
                  isLoading: submissionProvider.state == ProviderState.loading,
                  icon: Icons.send_rounded,
                  onPressed: _handleSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
