import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin/settings_page.dart';
import '../services/attendance_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = 'Ready';
  bool busy = false;

  final service = AttendanceService();

  // فرع افتراضي للتجربة
  final branch = {'id':'main','lat':29.3759,'lng':47.9774,'radius':120.0};

  Future<void> _punch(String type) async {
    setState(() { busy = true; status = 'Working...'; });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'TEST_USER';
      await service.punch(type: type, userId: uid, branch: branch);
      setState(() { status = 'Success: $type recorded'; });
    } catch (e) {
      setState(() { status = 'Error: $e'; });
    } finally {
      setState(() { busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async { await FirebaseAuth.instance.signOut(); if (mounted) Navigator.pop(context); },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello ${user?.email ?? 'User'}'),
            const SizedBox(height: 16),
            Text(status),
            const SizedBox(height: 16),
            Wrap(spacing: 12, children: [
              ElevatedButton(onPressed: busy ? null : () => _punch('checkin'), child: const Text('Check In')),
              ElevatedButton(onPressed: busy ? null : () => _punch('checkout'), child: const Text('Check Out')),
            ]),
          ],
        ),
      ),
    );
  }
}
