import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBVvrJe9DzjRU5ieU4vnz0rQ-Vo4s7_CCg",
        authDomain: "locarb-attendance.firebaseapp.com",
        projectId: "locarb-attendance",
        storageBucket: "locarb-attendance.appspot.com", // تم التصحيح هنا
        messagingSenderId: "155078748572",
        appId: "1:155078748572:web:e54a5156dee79f1243c059",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await Hive.initFlutter();
  await Hive.openBox('offline_queue');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance MVP',
      theme: ThemeData(useMaterial3: true),
      home: const LoginPage(),
      routes: {
        '/home': (_) => const HomePage(),
      },
    );
  }
}
