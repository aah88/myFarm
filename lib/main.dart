import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/full_listing_provider.dart';
import 'package:flutter_application_1/screens/cart/cart_screen.dart';
import 'package:flutter_application_1/screens/favorites/favorites_screen.dart';
import 'package:flutter_application_1/screens/home/home_screen_farmer.dart';
import 'package:flutter_application_1/screens/notifications/notifications_screen.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/listing_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/login/sign_in_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//PUSH NOTIFICATION
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Nachricht im Hintergrund empfangen: ${message.messageId}");
}

Future<void> main() async {
  // Ensure Flutter bindings are initialized before async work
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //PUSH NOTIFICATION
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
 // (Optional but recommended) Ask for notification permission
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  // === Step 6: Get the FCM token (after init) ===
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM token: $token');

 

  // === Step 7: Register message listeners ===
  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground: ${message.notification?.title}');
  });

  // App opened from a notification (while in background)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Opened from notification: ${message.messageId}');
  });

  // App launched from terminated state via notification
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint(
      'Launched from terminated via notification: ${initialMessage.messageId}',
    );
  }
  // Root app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => FullListingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق زراعي',

      // 🌍 Localization & RTL
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder:
          (context, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),

      theme: AppTheme.light(), // Light
      // darkTheme: AppTheme.dark(),   // (اختياري) Dark
      // themeMode: ThemeMode.system,  // (اختياري) تبديل تلقائي

      // مهم: عرّف المسارات
      routes: {
        '/home': (_) => HomeScreenFarmer(),
        '/cart': (_) => CartScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/notifications': (_) => NotificationsScreen(),
      },
      home: const SignInPage(),
    );
  }
}
