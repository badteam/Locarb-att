import 'package:geolocator/geolocator.dart';

class GpsService {
  Future<Position> getLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      perm = await Geolocator.requestPermission();
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (pos.isMocked == true) {
      throw Exception('Mock location detected');
    }
    return pos;
  }

  bool isInsideGeofence(Position p, double lat, double lng, double radiusM) {
    final d = Geolocator.distanceBetween(p.latitude, p.longitude, lat, lng);
    return d <= radiusM;
  }
}
