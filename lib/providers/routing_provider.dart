import 'package:flutter/material.dart';

import '../models/routing_model.dart';

class RoutingProvider extends ChangeNotifier {
  RoutingModel? _routing;

  RoutingModel? get routing => _routing;

  void initializeRouting({
    required bool isUrgent,
    required String categoryTitle,
  }) {
    _routing = RoutingModel(
      caseId: 'CASE-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      status: isUrgent ? RoutingStatus.priorityEscalated : RoutingStatus.waitingStaffReview,
      statusDescription: isUrgent
          ? 'Priority review active. Intake contains urgent deadlines flagged for immediate staff review.'
          : 'Normal intake queue. Intake is waiting for legal-aid staff review.',
      isPriorityEscalated: isUrgent,
      destinationClinicName: 'Metro Legal-Aid Central Office',
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }
}
