import 'package:bilolog/exceptions/location_denied_exception.dart';
import 'package:location/location.dart';

class LocationProvider {
  LocationProvider() {
    location.hasPermission().then((value) => {_permissionStatus = value});
    location.serviceEnabled().then((value) => {_serviceEnabled = value});
  }

  Location location = Location();
  late PermissionStatus _permissionStatus;
  late bool _serviceEnabled;

  Future<PermissionStatus> getPermissionStatus() async {
    if (_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
    }
    return await location.requestPermission();
  }

  Future<LocationData> getCurrentLocation() async {
    if (_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
    }
    if (_permissionStatus == PermissionStatus.deniedForever) {
      throw LocationDeniedException(true);
    }
    return await location.getLocation();
  }
}
