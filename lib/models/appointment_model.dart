import 'lawyer_model.dart';

enum AppointmentType { virtual, inPerson }

enum AppointmentStatus { pending, confirmed, cancelled, completed }

class AppointmentModel {
  final String id;
  final LawyerModel lawyer;
  final DateTime scheduledTime;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? locationOrLink;

  const AppointmentModel({
    required this.id,
    required this.lawyer,
    required this.scheduledTime,
    required this.type,
    required this.status,
    this.locationOrLink,
  });
}
