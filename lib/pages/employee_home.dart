import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key});
  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  String? fullName;
  String statusText = '';

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!snap.exists) return;
    final data = snap.data()!;
    setState(() {
      fullName = data['fullName'] ?? data['username'];
      statusText = 'Status: ${data['status']} | Role: ${data['role'] ?? 'employee'}';
    });
    if (data['status'] != 'approved') {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حسابك غير مُعتمد بعد')));
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${fullName ?? ''}'),
            const SizedBox(height: 8),
            Text(statusText),
            const SizedBox(height: 16),
            const Text('هنا لاحقًا نضيف أزرار الحضور والانصراف والـGPS'),
          ],
        ),
      ),
    );
  }
}
