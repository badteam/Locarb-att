import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_page.dart';
import 'admin_page.dart';
import 'employee_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  String? error;
  bool loading = false;

  Future<void> _login() async {
    setState(() { loading = true; error = null; });
    try {
      final emailAlias = '${username.text.trim()}@company.com';
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAlias, password: password.text.trim());
      final uid = cred.user!.uid;
      final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!snap.exists) {
        throw Exception('No profile found, please sign up first');
      }
      final data = snap.data()!;
      if (data['status'] != 'approved') {
        await FirebaseAuth.instance.signOut();
        throw Exception('حسابك قيد المراجعة من الإدارة (الحالة: ${data['status']})');
      }
      if (data['role'] == 'admin') {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPage()));
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EmployeeHome()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() { error = e.message; });
    } catch (e) {
      setState(() { error = e.toString(); });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(controller: username, decoration: const InputDecoration(labelText: 'Username')),
                const SizedBox(height: 8),
                TextField(controller: password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: loading ? null : _login, child: loading ? const CircularProgressIndicator() : const Text('Login')),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                  child: const Text('Create a new account'),
                ),
                if (error != null) Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
