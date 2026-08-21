import '../core/widgets/app_status_badge.dart';
import 'urgency_factor_model.dart';

class UrgencyModel {
  final UrgencyLevel level;
  final String title;
  final String description;
  final List<UrgencyFactorModel> factors;
  final DateTime? relevantDeadline;

  const UrgencyModel({
    required this.level,
    required this.title,
    required this.description,
    required this.factors,
    this.relevantDeadline,
  });
}
