import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// صفحاتك
import 'pages/login_page.dart';
import 'pages/admin_page.dart';
import 'pages/employee_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Web config (قيمك)
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
      routes: {
        '/home': (_) => const EmployeeHome(),
        '/admin': (_) => const AdminPage(),
      },
      // التوجيه الأساسي
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnap) {
          // لسه بنستنى حالة الدخول
          if (authSnap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // مش داخل → صفحة تسجيل الدخول
          final user = authSnap.data;
          if (user == null) return const LoginPage();

          // داخل: نجيب مستنده ونقرر نوديه فين
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, docSnap) {
              if (docSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // لو مفيش مستند (حالة نادرة): نطلعه للّوجين
              if (!docSnap.hasData || !docSnap.data!.exists) {
                return const LoginPage();
              }

              final data = docSnap.data!.data()!;
              final status = (data['status'] ?? 'pending').toString();
              final role = (data['role'] ?? 'employee').toString();

              // لو مش معتمد، نعرض صفحة الموظف فيها رسالة داخلية (موجودة في EmployeeHome)
              if (status != 'approved') {
                return const EmployeeHome();
              }

              // لو أدمن → صفحة الأدمن، غير كده → الموظف
              return role == 'admin' ? const AdminPage() : const EmployeeHome();
            },
          );
        },
      ),
    );
  }
}
