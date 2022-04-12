class LocationDeniedException implements Exception {
  LocationDeniedException(this.deniedForever);

  bool deniedForever;
}
