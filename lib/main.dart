// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Firebase + Providers
import 'firebase_options.dart';
import 'providers/listing_provider.dart';

// screens
import 'screens/login/login_screen.dart';



Future<void> main() async {
  // Ensure bindings are initialized before async calls
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2E7D32); // brand green

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق زراعي',

      // Localization & RTL
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),

      // Clean Material 3 theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2E7D32)),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Cairo', // TODO: ensure the font is added to pubspec.yaml or change it
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
