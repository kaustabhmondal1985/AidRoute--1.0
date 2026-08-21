class AppConstants {
  static const String appName = 'AidRoute';
  static const String appTagline = 'Smart Legal-Aid Intake & Triage Companion';
  static const String appVersion = '1.0.0';

  static const String disclaimerText =
      'AidRoute is strictly an intake and triage routing companion. '
      'It helps collect your information and prioritize your case for legal-aid staff. '
      'AidRoute NEVER provides legal advice or legal representation.';

  static const String urgentNoticeHeadline = 'Priority Review Flagged';
  static const String urgentNoticeSubtext =
      'Your intake contains details identified as time-sensitive. '
      'Your case has been flagged for priority staff review.';

  // Backend API Configuration
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  // Use 127.0.0.1 for web/desktop testing
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // API Endpoints
  static const String healthEndpoint = '/health';
  static const String intakeEndpoint = '/intake';
  static const String documentsEndpoint = '/documents';
  static const String casesEndpoint = '/cases';
  static const String lawyersEndpoint = '/lawyers';
  static const String appointmentsEndpoint = '/appointments';

  // Specific endpoints
  static const String caseAnalyzeEndpoint = '/cases/analyze';
  static const String lawyerMatchEndpoint = '/lawyers/match';
  static const String appointmentSlotsEndpoint = '/appointments/slots';
}
