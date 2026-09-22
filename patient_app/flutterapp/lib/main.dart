import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/screens/login_screen.dart';
import 'package:flutterapp/screens/on_boarding_flow_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 

/// Entry-Point für Benachrichtigung-Aktionen,
/// die ausgeführt werden, wenn die App im Hintergrund
/// oder beendet ist (separater Isolate).
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  if (response.payload == null) return;

  // Plant die nächste Erinnerung basierend auf den
  // im Payload gespeicherten Informationen
  await NotificationService.scheduleNextFromPayload(response.payload!);
}

Future<void> main() async {
  // Notwendig für Plugin-Initialisierung vor runApp()
  WidgetsFlutterBinding.ensureInitialized();
  Widget startScreen;

  // Initialisierung nur für mobile Plattformen
  if (!kIsWeb) {
    // Initialisiert die lokale Zeitzone (DST-sicher)
    await NotificationService.configureLocalTimeZone();

    // Initialisiert das Notification-Plugin und registriert
    // den Background-Callback
    await NotificationService.init(
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackground,
    );
    await NotificationService.testNotificationAfter5Seconds();

  }

  final prefs = await SharedPreferences.getInstance();
  var  accepted = prefs.getBool('hasAcceptedPolicy');
  startScreen = accepted ==null ? const OnBoardingFlowScreen() : const LoginScreen();

  initializeDateFormatting().then((_) => runApp(
    ProviderScope(
      child: MyApp(startScreen: startScreen,),
    ),
  ));  //initializeDateFormatting  wird benötigt um bei table_calendar die Sprache umzustellen
}

/// The main application widget that sets up the global theme and routing.
class MyApp extends StatelessWidget {
    final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Configuration for localized DatePickers and other widgets.
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('de'),  
        ],
        
      // General app settings.
      debugShowCheckedModeBanner: false, 
      title: 'Patient App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: startScreen,
    );
  }
}
