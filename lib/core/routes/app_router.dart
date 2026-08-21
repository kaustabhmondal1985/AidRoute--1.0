import 'package:flutter/material.dart';

import '../../screens/appointment/appointment_screen.dart';
import '../../screens/case_summary/case_summary_screen.dart';
import '../../screens/confirmation/confirmation_screen.dart';
import '../../screens/conversation/conversation_screen.dart';
import '../../screens/document_review/document_review_screen.dart';
import '../../screens/document_upload/document_upload_screen.dart';
// import '../../screens/eligibility/eligibility_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/language/language_screen.dart';
import '../../screens/matching/lawyer_matching_screen.dart';
import '../../screens/routing/routing_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/submission/submission_screen.dart';
// import '../../screens/triage/triage_screen.dart';
import '../animations/page_transitions.dart';
import '../constants/route_constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.splash:
        return FadeSlidePageRoute(page: const SplashScreen());
      case RouteConstants.language:
        return FadeSlidePageRoute(page: const LanguageScreen());
      case RouteConstants.home:
        return FadeSlidePageRoute(page: const HomeScreen());
      case RouteConstants.conversation:
        return FadeSlidePageRoute(page: const ConversationScreen());
      // Bypassed route: Triage screen removed from linear workflow
      // case RouteConstants.triage:
      //   return FadeSlidePageRoute(page: const TriageScreen());
      case RouteConstants.documents:
        return FadeSlidePageRoute(page: const DocumentUploadScreen());
      case RouteConstants.documentReview:
        return FadeSlidePageRoute(page: const DocumentReviewScreen());
      // Bypassed route: Eligibility screen removed from linear workflow
      // case RouteConstants.eligibility:
      //   return FadeSlidePageRoute(page: const EligibilityScreen());
      case RouteConstants.matching:
        return FadeSlidePageRoute(page: const LawyerMatchingScreen());
      case RouteConstants.appointment:
        return FadeSlidePageRoute(page: const AppointmentScreen());
      case RouteConstants.caseSummary:
        return FadeSlidePageRoute(page: const CaseSummaryScreen());
      case RouteConstants.routing:
        return FadeSlidePageRoute(page: const RoutingScreen());
      case RouteConstants.submission:
        return FadeSlidePageRoute(page: const SubmissionScreen());
      case RouteConstants.confirmation:
        return FadeSlidePageRoute(page: const ConfirmationScreen());
      default:
        return FadeSlidePageRoute(page: const SplashScreen());
    }
  }
}
