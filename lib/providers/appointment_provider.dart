import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../models/lawyer_model.dart';
import '../services/appointment_service.dart';
import 'conversation_provider.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  AppointmentModel? _appointment;
  ProviderState _state = ProviderState.initial;

  AppointmentModel? get appointment => _appointment;
  ProviderState get state => _state;

  Future<void> scheduleAppointment({
    required LawyerModel lawyer,
    required DateTime date,
    required AppointmentType type,
    String userName = 'User',
    String userPhone = '0000000000',
  }) async {
    _state = ProviderState.loading;
    notifyListeners();

    try {
      final result = await _service.confirmAppointment(
        lawyerId: lawyer.id,
        lawyerName: lawyer.fullName,
        category: 'GENERAL', // TODO: Get from triage provider
        appointmentDate: date,
        notes: 'Type: ${type.name}, User: $userName, Phone: $userPhone',
      );

      // Create appointment model from result
      _appointment = AppointmentModel(
        id:
            result['appointment_id'] ??
            'apt_${DateTime.now().millisecondsSinceEpoch}',
        lawyer: lawyer,
        scheduledTime: date,
        type: type,
        status: AppointmentStatus.confirmed,
        locationOrLink: type == AppointmentType.virtual
            ? 'https://aidroute.org/virtual-room/meet-${lawyer.id}'
            : 'Metro Legal Aid Office, Room 304, 100 Legal Way',
      );

      _state = ProviderState.success;
    } catch (e) {
      _state = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }
}
