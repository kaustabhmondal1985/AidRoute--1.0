import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/document_provider.dart';
import 'providers/eligibility_provider.dart';
import 'providers/language_provider.dart';
import 'providers/matching_provider.dart';
import 'providers/routing_provider.dart';
import 'providers/submission_provider.dart';
import 'providers/triage_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AidRouteApp());
}

class AidRouteApp extends StatelessWidget {
  const AidRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => TriageProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => EligibilityProvider()),
        ChangeNotifierProvider(create: (_) => MatchingProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => RoutingProvider()),
        ChangeNotifierProvider(create: (_) => SubmissionProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: RouteConstants.splash,
          );
        },
      ),
    );
  }
}
