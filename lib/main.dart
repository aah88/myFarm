import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'firebase_options.dart';


// rules_version = '2';

// service cloud.firestore {
//   match /databases/{database}/documents {
//     match /{document=**} {
//       allow read, write: if
//           request.time < timestamp.date(2025, 6, 23);
//     }
//   }
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'تطبيق زراعي', home: const HomeScreen());
  }
}
