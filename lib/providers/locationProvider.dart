import 'package:location/location.dart';

class LocationProvider {
  DeviceLocation() {
    location.hasPermission().then((value) => {_permissionStatus = value});
    location.serviceEnabled().then((value) => {_serviceEnabled = value});
  }

  Location location = Location();
  late PermissionStatus _permissionStatus;
  late bool _serviceEnabled;

  Future<LocationData> getCurrentLocation() async {
    if (_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
    }
    return await location.getLocation();
  }
}
