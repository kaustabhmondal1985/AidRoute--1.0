import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../models/lawyer_match_model.dart';
import '../models/lawyer_model.dart';
import 'api_client.dart';

class MatchingService {
  Future<List<LawyerMatchModel>> findMatches({
    required String categoryId,
    required String languageCode,
    String? city,
  }) async {
    try {
      // Check if category is already in backend format (uppercase with underscores)
      // If it contains underscores and is uppercase, assume it's already backend format
      final backendCategory = _isBackendFormat(categoryId)
          ? categoryId
          : _convertToBackendCategory(categoryId);

      print(
        '[DEBUG] MatchingService: categoryId=$categoryId, backendCategory=$backendCategory',
      );

      // Build query parameters, only include non-null values
      final queryParams = <String, dynamic>{
        'category': backendCategory,
        'limit': '5',
      };
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }

      // Call backend lawyers match API
      final response = await ApiClient.get(
        AppConstants.lawyerMatchEndpoint,
        queryParams: queryParams,
      );

      if (!ApiClient.isSuccess(response.statusCode)) {
        throw Exception(ApiClient.handleError(response));
      }

      final responseData = jsonDecode(response.body);

      // Parse backend response and convert to frontend models
      return _parseBackendResponse(responseData);
    } catch (e) {
      print('[WARNING] Lawyer matching failed: $e. Returning empty list.');
      return [];
    }
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

  List<LawyerMatchModel> _parseBackendResponse(
    Map<String, dynamic> responseData,
  ) {
    final lawyersData = responseData['lawyers'] as List?;
    if (lawyersData == null) {
      return [];
    }

    return lawyersData.map((lawyerData) {
      final lawyer = LawyerModel(
        id: lawyerData['id'] ?? '',
        fullName: lawyerData['name'] ?? 'Unknown',
        organization: lawyerData['city'] != null
            ? '${lawyerData['city']}${lawyerData['state'] != null ? ', ${lawyerData['state']}' : ''}'
            : 'Legal Aid Services',
        specialties: List<String>.from(lawyerData['specializations'] ?? []),
        languages: [
          'English',
        ], // Default language since backend doesn't provide it
        isAvailable: lawyerData['available'] ?? false,
        nextAvailableSlot: lawyerData['experience_years'] != null
            ? '${lawyerData['experience_years']} years experience'
            : 'Available',
        bio:
            'Legal aid professional specializing in ${lawyerData['category'] ?? 'general law'}',
      );

      return LawyerMatchModel(
        lawyer: lawyer,
        matchReason: 'Specialty and availability match',
        specialtyMatchLabel: 'Specialty Match',
        languageMatchLabel: 'Language Match',
      );
    }).toList();
  }
}
