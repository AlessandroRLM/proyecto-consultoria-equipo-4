class UserLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? heading;
  final DateTime timestamp;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.heading,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}