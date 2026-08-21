class LawyerModel {
  final String id;
  final String fullName;
  final String organization;
  final List<String> specialties;
  final List<String> languages;
  final bool isAvailable;
  final String nextAvailableSlot;
  final String bio;

  const LawyerModel({
    required this.id,
    required this.fullName,
    required this.organization,
    required this.specialties,
    required this.languages,
    required this.isAvailable,
    required this.nextAvailableSlot,
    required this.bio,
  });
}

