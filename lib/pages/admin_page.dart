import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<void> updateStatus(String uid, String status) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> makeAdmin(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'role': 'admin',
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Pending Users', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users')
                      .where('status', isEqualTo: 'pending').snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) return const Center(child: Text('No pending users'));
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final d = docs[i].data() as Map<String, dynamic>;
                          final uid = docs[i].id;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: d['avatarUrl'] != null ? NetworkImage(d['avatarUrl']) : null,
                              child: d['avatarUrl'] == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text(d['fullName'] ?? d['username'] ?? uid),
                            subtitle: Text('Branch: ${d['branchId'] ?? '-'} | Username: ${d['username'] ?? '-'}'),
                            trailing: Wrap(
                              children: [
                                IconButton(onPressed: () => updateStatus(uid, 'approved'),
                                  icon: const Icon(Icons.check, color: Colors.green)),
                                IconButton(onPressed: () => updateStatus(uid, 'rejected'),
                                  icon: const Icon(Icons.close, color: Colors.red)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Approved Users', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users')
                      .where('status', isEqualTo: 'approved').snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) return const Center(child: Text('No approved users'));
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final d = docs[i].data() as Map<String, dynamic>;
                          final uid = docs[i].id;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: d['avatarUrl'] != null ? NetworkImage(d['avatarUrl']) : null,
                              child: d['avatarUrl'] == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text(d['fullName'] ?? d['username'] ?? uid),
                            subtitle: Text('Role: ${d['role'] ?? 'employee'}'),
                            trailing: Wrap(
                              children: [
                                IconButton(onPressed: () => makeAdmin(uid),
                                  icon: const Icon(Icons.security)),
                                IconButton(onPressed: () => updateStatus(uid, 'rejected'),
                                  icon: const Icon(Icons.block)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
