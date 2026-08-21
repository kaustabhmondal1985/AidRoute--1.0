import '../models/case_summary_model.dart';

class SubmissionService {
  Future<SubmissionResultModel> submitCase(CaseSummaryModel caseSummary) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final isUrgent = caseSummary.urgency?.level.name == 'urgent';
    final refId = 'AR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    return SubmissionResultModel(
      trackingReferenceId: refId,
      submissionTimestamp: DateTime.now(),
      isUrgentEscalated: isUrgent,
      confirmationMessage: isUrgent
          ? 'Your intake has been transmitted to legal-aid triage staff and flagged for priority review.'
          : 'Your intake has been successfully received and placed in the standard review queue.',
    );
  }
}
