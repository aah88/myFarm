import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/cart/cart_management_screen.dart';
import 'package:flutter_application_1/screens/favorites/favorites_screen.dart';
import 'package:flutter_application_1/screens/home/home_screen_farmer.dart';
import 'package:flutter_application_1/screens/notifications/notifications_screen.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
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

      // 🎨 Clean Material 3 theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.tajawalTextTheme(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        splashFactory: InkSparkle.splashFactory, // أو InkRipple
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        dividerColor: const Color(0xFFE8EBE6),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Input decoration theme to all TextFields and Dropdowns
        inputDecorationTheme: InputDecorationTheme(
          //contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          labelStyle: const TextStyle(     // Label text style 
            color: Color(0xFF91958E), 
            fontWeight: FontWeight.bold,
          ),
          hintStyle: const TextStyle(   // placeholder 
            color: Colors.grey,
            fontSize: 14,
          ),
          enabledBorder: OutlineInputBorder(  // Border
            borderSide: const BorderSide(
              color: Color(0xFFE8EBE6), 
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(     // Border when the field is focused
            borderSide: const BorderSide(
              color: Color(0xFF2E7D32), 
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),         
        ),       
      ),
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