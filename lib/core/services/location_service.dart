import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum LocationStatus { denied, granted, restricted, unknown }

class LocationResult {
  final double? lat;
  final double? lng;
  final String? address;
  final String? error;

  const LocationResult({this.lat, this.lng, this.address, this.error});

  bool get hasCoords => lat != null && lng != null;
  bool get hasError => error != null;
}

class LocationService {
  static Future<LocationStatus> checkPermission() async {
    final status = await Geolocator.checkPermission();
    return switch (status) {
      LocationPermission.always => LocationStatus.granted,
      LocationPermission.whileInUse => LocationStatus.granted,
      LocationPermission.denied => LocationStatus.denied,
      LocationPermission.deniedForever => LocationStatus.restricted,
      LocationPermission.unableToDetermine => LocationStatus.unknown,
    };
  }

  static Future<LocationStatus> requestPermission() async {
    final status = await Geolocator.requestPermission();
    return switch (status) {
      LocationPermission.always => LocationStatus.granted,
      LocationPermission.whileInUse => LocationStatus.granted,
      LocationPermission.denied => LocationStatus.denied,
      LocationPermission.deniedForever => LocationStatus.restricted,
      LocationPermission.unableToDetermine => LocationStatus.unknown,
    };
  }

  static Future<LocationResult> getCurrentPosition({
    Duration timeLimit = const Duration(seconds: 10),
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final perm = await checkPermission();
    if (perm != LocationStatus.granted) {
      final requested = await requestPermission();
      if (requested != LocationStatus.granted) {
        return const LocationResult(
          error: 'Permiso de ubicación no concedido',
        );
      }
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        ),
      );
      return LocationResult(lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return const LocationResult(error: 'No se pudo obtener la ubicación');
    }
  }

  static Future<LocationResult> getLastKnownPosition() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        return LocationResult(lat: pos.latitude, lng: pos.longitude);
      }
      return const LocationResult(error: 'Sin ubicación previa');
    } catch (_) {
      return const LocationResult(error: 'No se pudo obtener ubicación previa');
    }
  }

  static Future<LocationResult> getPositionWithFallback() async {
    final last = await getLastKnownPosition();
    if (last.hasCoords) return last;
    return getCurrentPosition(accuracy: LocationAccuracy.low);
  }

  static Future<LocationResult> addressToCoordinates(String address) async {
    if (address.trim().isEmpty) {
      return const LocationResult(error: 'Dirección vacía');
    }
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return LocationResult(
          lat: loc.latitude,
          lng: loc.longitude,
          address: address,
        );
      }
      return const LocationResult(error: 'No se encontró la dirección');
    } catch (e) {
      return LocationResult(error: 'Error al geocodificar: $e');
    }
  }

  static Future<LocationResult> coordinatesToAddress(
    double lat,
    double lng,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).toList();
        return LocationResult(
          lat: lat,
          lng: lng,
          address: parts.join(', '),
        );
      }
      return LocationResult(lat: lat, lng: lng, error: 'Sin dirección');
    } catch (e) {
      return LocationResult(lat: lat, lng: lng, error: 'Error: $e');
    }
  }
}
