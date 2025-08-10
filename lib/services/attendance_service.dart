import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'gps_service.dart';
import 'offline_queue.dart';

class AttendanceService {
  final _gps = GpsService();
  final _queue = OfflineQueue();

  Future<void> punch({required String type, required String userId, required Map branch}) async {
    final connectivity = await Connectivity().checkConnectivity();
    final pos = await _gps.getLocation();

    if (!_gps.isInsideGeofence(pos, branch['lat'], branch['lng'], branch['radius'])) {
      throw Exception('Outside branch geofence');
    }

    final payload = {
      'userId': userId,
      'branchId': branch['id'],
      'type': type, // checkin or checkout
      'tsDevice': FieldValue.serverTimestamp(),
      'location': {'lat': pos.latitude, 'lng': pos.longitude, 'acc': pos.accuracy},
      'method': 'gps',
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (connectivity == ConnectivityResult.none) {
      await _queue.enqueue(Map<String, dynamic>.from(payload));
    } else {
      await FirebaseFirestore.instance.collection('attendance').add(payload);
      await _queue.flush();
    }
  }
}
