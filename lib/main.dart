// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Firebase + Providers
import 'firebase_options.dart';
import 'providers/listing_provider.dart';

// Screens used from your project (keep these imports if files remain separate)
// If you later inline these too, you can remove the imports.
import 'package:flutter_application_1/screens/main/main_screen.dart';
import 'package:flutter_application_1/screens/product/product_management_screen.dart';
import 'package:flutter_application_1/screens/category/category_management_screen.dart';
import 'package:flutter_application_1/screens/auth/validation_per_phone.dart';

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

      // Home is now the merged HomeScreen below
      home: const HomeScreen(),
    );
  }
}

/// Merged HomeScreen (inline in this same file)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper to push screens with MaterialPageRoute
    void go(Widget page) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Spacer(),

            // Login with phone
            ElevatedButton(
              onPressed: () => go(PhoneAuthPage()),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(color: Color(0xFF2E7D32)),
              ),
            ),

            const SizedBox(height: 10),

            // Browse as guest
            ElevatedButton(
              onPressed: () => go(MainScreen()),
              child: const Text('استعراض كزائر'),
            ),

            // Product management
            ElevatedButton(
              onPressed: () => go(const ProductManagementScreen()),
              child: const Text('Add Product'),
            ),

            // Category management
            ElevatedButton(
              onPressed: () => go(const CategoryManagementScreen()),
              child: const Text('Add Category'),
            ),

            const SizedBox(height: 20),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
