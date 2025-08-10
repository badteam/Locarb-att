import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_page.dart';
import 'pages/admin_page.dart';
import 'pages/employee_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBVvrJe9DzjRU5ieU4vnz0rQ-Vo4s7_CCg",
        authDomain: "locarb-attendance.firebaseapp.com",
        projectId: "locarb-attendance",
        storageBucket: "locarb-attendance.appspot.com",
        messagingSenderId: "155078748572",
        appId: "1:155078748572:web:e54a5156dee79f1243c059",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoCarb Attendance',
      theme: ThemeData(useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snap.data == null) return const LoginPage();
          return const EmployeeHome();
        },
      ),
      routes: {
        '/admin': (_) => const AdminPage(),
        '/home': (_) => const EmployeeHome(),
      },
    );
  }
}
