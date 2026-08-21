import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../core/widgets/app_status_badge.dart';
import '../models/answer_model.dart';
import '../models/legal_category_model.dart';
import '../models/urgency_factor_model.dart';
import '../models/urgency_model.dart';
import 'api_client.dart';

class TriageService {
  Future<Map<String, dynamic>> evaluateTriage({
    required List<AnswerModel> answers,
    required String category,
    required String userMessage,
    String? languageCode,
  }) async {
    try {
      // Convert frontend category to backend format if needed
      final backendCategory = _isBackendFormat(category)
          ? category
          : _convertToBackendCategory(category);

      // Call backend cases analyze API
      final response = await ApiClient.post(
        AppConstants.caseAnalyzeEndpoint,
        body: {
          'user_message': userMessage,
          'category': backendCategory,
          'city': null,
          'max_lawyers': 3,
          'max_chunks': 5,
          'language': languageCode ?? 'en',
        },
      );

      if (!ApiClient.isSuccess(response.statusCode)) {
        throw Exception(ApiClient.handleError(response));
      }

      final responseData = jsonDecode(response.body);

      // Parse backend response and convert to frontend models
      return _parseBackendResponse(responseData);
    } catch (e) {
      // Fallback to mock triage if backend fails
      print('[WARNING] Backend triage failed: $e. Using fallback.');
      return _getFallbackTriage(category);
    }
  }

  Map<String, dynamic> _getFallbackTriage(String category) {
    // Fallback triage when backend is unavailable
    final categoryModel = LegalCategoryModel(
      id: 'cat_${category.toLowerCase().replaceAll(' ', '_')}',
      title: _formatCategoryTitle(category),
      description: 'Legal category determined by fallback analysis.',
      confidenceScore: 0.5,
      commonKeywords: [category.toLowerCase()],
    );

    final urgency = UrgencyModel(
      level: UrgencyLevel.moderate,
      title: 'Moderate Priority',
      description: 'Backend unavailable. Standard review timeline applies.',
      relevantDeadline: null,
      factors: [],
    );

    return {
      'category': categoryModel,
      'urgency': urgency,
      'backendCategory': _convertToBackendCategory(category),
    };
  }

  bool _isBackendFormat(String category) {
    // Backend format is like "HOUSING_EVICTION" - uppercase with underscores
    return category.contains('_') && category == category.toUpperCase();
  }

  String _convertToBackendCategory(String categoryId) {
    // Convert frontend category ID to backend category format
    switch (categoryId.toLowerCase()) {
      case 'cat_housing':
        return 'HOUSING_EVICTION';
      case 'cat_employment':
        return 'EMPLOYMENT';
      case 'cat_family':
        return 'FAMILY';
      case 'cat_criminal':
        return 'CRIMINAL';
      case 'cat_consumer':
        return 'CONSUMER';
      default:
        // Try to extract from the ID
        if (categoryId.startsWith('cat_')) {
          final category = categoryId.substring(4).toUpperCase();
          return category;
        }
        return 'HOUSING_EVICTION'; // Default fallback
    }
  }

  Map<String, dynamic> _parseBackendResponse(
    Map<String, dynamic> responseData,
  ) {
    // Parse category from backend response
    final categoryString = responseData['category'] as String? ?? 'GENERAL';
    final categoryConfidence =
        (responseData['category_confidence'] as num?)?.toDouble() ?? 0.82;

    final category = LegalCategoryModel(
      id: 'cat_${categoryString.toLowerCase().replaceAll(' ', '_')}',
      title: _formatCategoryTitle(categoryString),
      description:
          'Legal category determined by AI analysis based on your case details.',
      confidenceScore: categoryConfidence,
      commonKeywords: [categoryString.toLowerCase()],
    );

    // Parse urgency from backend response
    final urgencyString = responseData['urgency'] as String? ?? 'MEDIUM';
    final urgencyReason = responseData['urgency_reason'] as String? ?? '';
    final humanReviewRequired =
        responseData['human_review_required'] as bool? ?? false;

    final urgency = _parseUrgencyFromBackend(
      urgencyString,
      urgencyReason,
      humanReviewRequired,
    );

    // Store the backend category for use in lawyer matching
    return {
      'category': category,
      'urgency': urgency,
      'backendCategory': categoryString,
      'caseSummary': responseData['case_summary'] as String?,
    };
  }

  String _formatCategoryTitle(String category) {
    // Convert backend category to display title
    switch (category.toUpperCase()) {
      case 'HOUSING_EVICTION':
        return 'Housing & Eviction';
      case 'EMPLOYMENT_LABOR':
        return 'Employment & Labor Rights';
      case 'FAMILY_LAW':
        return 'Family Law';
      case 'CONSUMER_PROTECTION':
        return 'Consumer Protection';
      default:
        return category
            .split('_')
            .map(
              (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  UrgencyModel _parseUrgencyFromBackend(
    String urgencyLevel,
    String reason,
    bool humanReviewRequired,
  ) {
    final level = _parseUrgencyLevel(urgencyLevel);

    String title;
    String description;
    DateTime? relevantDeadline;
    List<UrgencyFactorModel> factors;

    switch (level) {
      case UrgencyLevel.urgent:
        title = 'Priority Review Flagged';
        description = reason.isNotEmpty
            ? reason
            : 'This case contains time-sensitive details and has been flagged for faster staff review.';
        relevantDeadline = DateTime.now().add(const Duration(days: 3));
        factors = [
          UrgencyFactorModel(
            id: 'f1',
            userProvidedFact: reason.isNotEmpty
                ? reason
                : 'Time-sensitive case detected',
            urgencyFactor: 'High Priority',
            impactExplanation: 'Immediate staff review recommended.',
          ),
        ];
        break;
      case UrgencyLevel.moderate:
        title = 'Moderate Priority';
        description = reason.isNotEmpty
            ? reason
            : 'This case has pending deadlines and will be reviewed in standard priority queue.';
        factors = [
          UrgencyFactorModel(
            id: 'f1',
            userProvidedFact: reason.isNotEmpty
                ? reason
                : 'Moderate urgency detected',
            urgencyFactor: 'Standard Priority',
            impactExplanation: 'Standard review timeline applies.',
          ),
        ];
        break;
      case UrgencyLevel.routine:
        title = 'Routine Review';
        description = reason.isNotEmpty
            ? reason
            : 'No immediate deadlines reported. Case placed in standard legal-aid queue.';
        factors = [
          UrgencyFactorModel(
            id: 'f1',
            userProvidedFact: reason.isNotEmpty
                ? reason
                : 'Routine case detected',
            urgencyFactor: 'Standard Schedule',
            impactExplanation:
                'Case proceeds through regular intake scheduling.',
          ),
        ];
        break;
    }

    return UrgencyModel(
      level: level,
      title: title,
      description: description,
      relevantDeadline: relevantDeadline,
      factors: factors,
    );
  }

  UrgencyLevel _parseUrgencyLevel(String urgencyLevel) {
    switch (urgencyLevel.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return UrgencyLevel.urgent;
      case 'MEDIUM':
        return UrgencyLevel.moderate;
      case 'LOW':
        return UrgencyLevel.routine;
      default:
        return UrgencyLevel.moderate;
    }
  }
}
