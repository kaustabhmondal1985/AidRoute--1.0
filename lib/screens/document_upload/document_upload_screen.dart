import 'package:file_picker/file_picker.dart';
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
import '../../core/widgets/app_loader.dart';
import '../../models/document_model.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/document_provider.dart';
import '../../providers/language_provider.dart';

class DocumentUploadScreen extends StatelessWidget {
  const DocumentUploadScreen({super.key});

  Future<void> _pickFile(BuildContext context) async {
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        await docProvider.addAndProcessDocument(
          file.name,
          file.size,
          file.path!,
        );
      } else {
        await docProvider.addAndProcessDocument(
          'Rent_notice.pdf',
          1258291,
          '/mock/path/Rent_notice.pdf',
        );
      }
    } catch (_) {
      await docProvider.addAndProcessDocument(
        'Rent_notice.pdf',
        1258291,
        '/mock/path/Rent_notice.pdf',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocumentProvider>(context);
    final langCode = Provider.of<LanguageProvider>(context).currentLanguageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationService.getText(langCode, 'addDocument'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedFadeSlide(
                child: Text(
                  LocalizationService.getText(langCode, 'addDocument'),
                  style: AppTextStyles.titleLarge(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'Attach notices, rental agreements, or summons for review.',
                  style: AppTextStyles.bodyMedium(
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ).copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Upload Dropzone
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 140),
                child: AnimatedPressScale(
                  onTap: () => _pickFile(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(
                        color: AppColors.primaryLight,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.primaryLight,
                          size: 40,
                        ),
                        const SizedBox(height: AppDimensions.paddingM),
                        Text(
                          'Tap to select document (PDF, PNG, JPG)',
                          style: AppTextStyles.titleMedium(
                            isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              Text(
                'Attached Files (${docProvider.documents.length})',
                style: AppTextStyles.titleMedium(
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.paddingM),

              Expanded(
                child: docProvider.state == ProviderState.loading
                    ? const AppLoader(message: 'Scanning document...')
                    : docProvider.documents.isEmpty
                        ? Center(
                            child: Text(
                              'No documents attached yet.',
                              style: AppTextStyles.caption(
                                isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: docProvider.documents.length,
                            itemBuilder: (context, index) {
                              final doc = docProvider.documents[index];
                              return _buildDocumentCard(context, doc, isDark);
                            },
                          ),
              ),

              AnimatedFadeSlide(
                child: AppButton(
                  label: LocalizationService.getText(langCode, 'reviewCaseTitle'),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.pushNamed(context, RouteConstants.caseSummary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
      BuildContext context, DocumentModel doc, bool isDark) {
    final sizeMb = (doc.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1);

    return AnimatedFadeSlide(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.urgentBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.urgent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.fileName,
                      style: AppTextStyles.label(
                        isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$sizeMb MB • PDF',
                      style: AppTextStyles.caption(
                        isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  Provider.of<DocumentProvider>(context, listen: false)
                      .removeDocument(doc.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
