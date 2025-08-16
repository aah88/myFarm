import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/cart/cart_management_screen.dart';
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

Future<void> main() async {
  // Ensure Flutter bindings are initialized before async work
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Root app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListingProvider()),
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
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),

        theme: AppTheme.light(),        // Light
        // darkTheme: AppTheme.dark(),   // (اختياري) Dark
        // themeMode: ThemeMode.system,  // (اختياري) تبديل تلقائي

  // مهم: عرّف المسارات
    routes: {
      '/home'   : (_) => HomeScreenFarmer(),
      '/cart': (_) => CartScreen(),
      '/favorites': (_) => const FavoritesScreen(),
      '/notifications': (_) => NotificationsScreen(),
    },
      home: const SignInPage(),
    );
  }
}