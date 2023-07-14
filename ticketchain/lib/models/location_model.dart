class LocationModel {
  final String address;
  final double latitude;
  final double longitude;

  LocationModel(
    this.address,
    this.latitude,
    this.longitude,
  );

  LocationModel.fromDoc(Map<String, dynamic> doc)
      : address = doc['address'],
        latitude = doc['latitude'] * 1.0,
        longitude = doc['longitude'] * 1.0;
}
