enum RoutingStatus {
  intakeCompleted,
  triageAssessed,
  summaryPrepared,
  waitingStaffReview,
  priorityEscalated,
  assignedToLawyer,
}

class RoutingModel {
  final String caseId;
  final RoutingStatus status;
  final String statusDescription;
  final bool isPriorityEscalated;
  final String destinationClinicName;
  final DateTime lastUpdated;

  const RoutingModel({
    required this.caseId,
    required this.status,
    required this.statusDescription,
    required this.isPriorityEscalated,
    required this.destinationClinicName,
    required this.lastUpdated,
  });
}
