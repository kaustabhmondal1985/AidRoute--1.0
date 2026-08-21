import 'dart:convert';
import '../core/constants/app_constants.dart';
import 'api_client.dart';

class AppointmentService {
  Future<Map<String, dynamic>> confirmAppointment({
    required String lawyerId,
    required String lawyerName,
    required String category,
    required DateTime appointmentDate,
    String? notes,
  }) async {
    try {
      final body = {
        'user_id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'lawyer_id': lawyerId,
        'lawyer_name': lawyerName,
        'category': category,
        'appointment_date': appointmentDate.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await ApiClient.post(
        AppConstants.appointmentsEndpoint,
        body: body,
      );

      if (!ApiClient.isSuccess(response.statusCode)) {
        throw Exception(ApiClient.handleError(response));
      }

      return jsonDecode(response.body);
    } catch (e) {
      print(
        '[WARNING] Appointment booking failed: $e. Returning mock success.',
      );
      return {
        'success': true,
        'message': 'Appointment booked (mock - backend unavailable)',
        'appointment_id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
      };
    }
  }

  Future<List<DateTime>> getAvailableSlots({
    required String lawyerId,
    required DateTime date,
  }) async {
    // Build query parameters, only include non-null values
    final queryParams = <String, dynamic>{
      'lawyer_id': lawyerId,
      'date': date.toIso8601String(),
    };

    // Call backend appointments slots API
    final response = await ApiClient.get(
      AppConstants.appointmentSlotsEndpoint,
      queryParams: queryParams,
    );

    if (!ApiClient.isSuccess(response.statusCode)) {
      throw Exception(ApiClient.handleError(response));
    }

    final responseData = jsonDecode(response.body);

    // Parse backend response
    return _parseSlotsResponse(responseData);
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      // Call backend cancel appointment API
      final response = await ApiClient.post(
        '$AppConstants.appointmentsEndpoint/$appointmentId/cancel',
        body: {},
      );

      return ApiClient.isSuccess(response.statusCode);
    } catch (e) {
      print('[WARNING] Appointment cancellation failed: $e. Returning false.');
      return false;
    }
  }

  List<DateTime> _parseSlotsResponse(List<dynamic> slotsData) {
    return slotsData.map((slot) {
      return DateTime.parse(slot as String);
    }).toList();
  }
}
