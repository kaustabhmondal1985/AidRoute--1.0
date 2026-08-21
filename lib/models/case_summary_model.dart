import 'answer_model.dart';
import 'appointment_model.dart';
import 'document_model.dart';
import 'eligibility_model.dart';
import 'extracted_date_model.dart';
import 'legal_category_model.dart';

import 'lawyer_match_model.dart';
import 'routing_model.dart';
import 'urgency_model.dart';

class CaseSummaryModel {
  final String id;
  final String userName;
  final String contactPhone;
  final String contactEmail;
  final String languageCode;
  final String situationDescription;
  final List<AnswerModel> answers;
  final LegalCategoryModel? category;
  final UrgencyModel? urgency;
  final List<DocumentModel> documents;
  final List<ExtractedDateModel> extractedDates;
  final EligibilityModel? eligibility;
  final LawyerMatchModel? lawyerMatch;
  final AppointmentModel? appointment;
  final RoutingModel? routing;

  const CaseSummaryModel({
    required this.id,
    required this.userName,
    required this.contactPhone,
    required this.contactEmail,
    required this.languageCode,
    required this.situationDescription,
    required this.answers,
    this.category,
    this.urgency,
    this.documents = const [],
    this.extractedDates = const [],
    this.eligibility,
    this.lawyerMatch,
    this.appointment,
    this.routing,
  });
}

class SubmissionResultModel {
  final String trackingReferenceId;
  final DateTime submissionTimestamp;
  final bool isUrgentEscalated;
  final String confirmationMessage;

  const SubmissionResultModel({
    required this.trackingReferenceId,
    required this.submissionTimestamp,
    required this.isUrgentEscalated,
    required this.confirmationMessage,
  });
}
