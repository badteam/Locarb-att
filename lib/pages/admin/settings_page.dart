import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final companyId = 'default_company';
  final _form = GlobalKey<FormState>();

  final start = TextEditingController(text: '09:00');
  final end = TextEditingController(text: '18:00');
  final grace = TextEditingController(text: '10');
  final overtimeStart = TextEditingController(text: '18:15');
  final breakMin = TextEditingController(text: '30');
  final radius = TextEditingController(text: '120');

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    await FirebaseFirestore.instance.collection('companies').doc(companyId).set({
      'settings': {
        'workStart': start.text,
        'workEnd': end.text,
        'graceMin': int.parse(grace.text),
        'overtimeStart': overtimeStart.text,
        'unpaidBreakMin': int.parse(breakMin.text),
        'defaultRadiusM': double.parse(radius.text),
      }
    }, SetOptions(merge: true));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Settings')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Work Hours', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: start, decoration: const InputDecoration(labelText: 'Start (HH:mm)'), validator: (v)=> v!.isEmpty?'Required':null),
            TextFormField(controller: end, decoration: const InputDecoration(labelText: 'End (HH:mm)'), validator: (v)=> v!.isEmpty?'Required':null),
            TextFormField(controller: grace, decoration: const InputDecoration(labelText: 'Grace minutes'), keyboardType: TextInputType.number),
            TextFormField(controller: overtimeStart, decoration: const InputDecoration(labelText: 'Overtime starts (HH:mm)')),
            TextFormField(controller: breakMin, decoration: const InputDecoration(labelText: 'Unpaid break (min)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            const Text('Geofence', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: radius, decoration: const InputDecoration(labelText: 'Default radius (m)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Save Settings')),
          ],
        ),
      ),
    );
  }
}
