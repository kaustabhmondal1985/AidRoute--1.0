import 'lawyer_model.dart';

class LawyerMatchModel {
  final LawyerModel lawyer;
  final String matchReason;
  final String specialtyMatchLabel;
  final String languageMatchLabel;

  const LawyerMatchModel({
    required this.lawyer,
    required this.matchReason,
    required this.specialtyMatchLabel,
    required this.languageMatchLabel,
  });
}
