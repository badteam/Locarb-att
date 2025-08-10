import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfflineQueue {
  final _box = Hive.box('offline_queue');

  Future<void> enqueue(Map<String, dynamic> item) async {
    final list = List<Map<String, dynamic>>.from(_box.get('items', defaultValue: <Map<String, dynamic>>[]));
    list.add(item);
    await _box.put('items', list);
  }

  Future<void> flush() async {
    final list = List<Map<String, dynamic>>.from(_box.get('items', defaultValue: <Map<String, dynamic>>[]));
    final remaining = <Map<String, dynamic>>[];
    for (final it in list) {
      try {
        await FirebaseFirestore.instance.collection('attendance').add(it);
      } catch (_) {
        remaining.add(it);
      }
    }
    await _box.put('items', remaining);
  }
}
