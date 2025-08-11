import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _form = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final branchId = TextEditingController(text: 'main');
  Uint8List? avatarBytes;
  String? avatarName;
  bool loading = false;
  String? error;

  Future<void> pickAvatar() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res != null && res.files.single.bytes != null) {
      setState(() {
        avatarBytes = res.files.single.bytes;
        avatarName = res.files.single.name;
      });
    }
  }

  Future<void> register() async {
  if (!_form.currentState!.validate()) return;
  setState(() { loading = true; error = null; });
  try {
    final emailAlias = '${username.text.trim()}@company.com';

    // 0) هل فيه أدمن موجود أصلاً؟
    final admins = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();
    final bool noAdminYet = admins.docs.isEmpty;

    // 1) إنشاء حساب في Auth
    final userCred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: emailAlias, password: password.text.trim());
    final uid = userCred.user!.uid;

    // 2) رفع الصورة (اختياري)
    String? avatarUrl;
    if (avatarBytes != null) {
      final ref = FirebaseStorage.instance.ref('users/$uid/avatar.jpg');
      await ref.putData(avatarBytes!, SettableMetadata(contentType: 'image/jpeg'));
      avatarUrl = await ref.getDownloadURL();
    }

    // 3) تحديد الدور والحالة
    final role = noAdminYet ? 'admin' : 'employee';
    final status = noAdminYet ? 'approved' : 'pending';

    // 4) جسم البيانات
    final data = {
      'uid': uid,
      'username': username.text.trim(),
      'fullName': fullName.text.trim(),
      'email': email.text.trim().isEmpty ? null : email.text.trim(),
      'branchId': branchId.text.trim(),
      'avatarUrl': avatarUrl,
      'role': role,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 5) الكتابة في مسارين:
    final batch = FirebaseFirestore.instance.batch();
    final rootUserDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final companyUserDoc = FirebaseFirestore.instance
        .collection('companies').doc('default_company')
        .collection('users').doc(uid);

    batch.set(rootUserDoc, data);
    batch.set(companyUserDoc, data);
    await batch.commit();

    // 6) خروج ورسالة
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(noAdminYet
          ? 'تم إنشاء حساب الأدمن واعتماده تلقائيًا. سجّل دخولك الآن.'
          : 'تم إرسال طلب التسجيل للمراجعة'),
    ));
    Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Create Account')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: username, decoration: const InputDecoration(labelText: 'Username'),
              validator: (v)=> v==null || v.trim().isEmpty ? 'Required' : null),
            TextFormField(controller: password, decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true, validator: (v)=> v==null || v.length<6 ? '6 chars min' : null),
            TextFormField(controller: fullName, decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v)=> v==null || v.trim().isEmpty ? 'Required' : null),
            TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Email (optional)')),
            TextFormField(controller: branchId, decoration: const InputDecoration(labelText: 'Branch ID'),
              validator: (v)=> v==null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton(onPressed: pickAvatar, child: const Text('Upload Avatar')),
              const SizedBox(width: 12),
              if (avatarName != null) Expanded(child: Text(avatarName!, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: loading ? null : register,
              child: loading ? const CircularProgressIndicator() : const Text('Submit Request')),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
