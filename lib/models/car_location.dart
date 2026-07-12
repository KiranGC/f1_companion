/// Model representing a car's 3D position on the circuit from the OpenF1 API.
///
/// Maps to the `/v1/location` endpoint response. Provides real-time
/// x, y, z coordinates of a car on the track at a given timestamp.
class CarLocation {
  /// Timestamp of the position sample.
  final DateTime date;

  /// Unique identifier for the session.
  final int sessionKey;

  /// The driver's car number.
  final int driverNumber;

  /// Unique identifier for the meeting.
  final int meetingKey;

  /// X-coordinate of the car's position on the circuit.
  final int x;

  /// Y-coordinate of the car's position on the circuit.
  final int y;

  /// Z-coordinate (elevation) of the car's position on the circuit.
  final int z;

  const CarLocation({
    required this.date,
    required this.sessionKey,
    required this.driverNumber,
    required this.meetingKey,
    required this.x,
    required this.y,
    required this.z,
  });

  /// Creates a [CarLocation] from a JSON map returned by the OpenF1 API.
  factory CarLocation.fromJson(Map<String, dynamic> json) {
    return CarLocation(
      date: DateTime.parse(json['date'] as String),
      sessionKey: json['session_key'] as int,
      driverNumber: json['driver_number'] as int,
      meetingKey: json['meeting_key'] as int,
      x: json['x'] as int,
      y: json['y'] as int,
      z: json['z'] as int,
    );
  }

  /// Converts this [CarLocation] to a JSON map matching the OpenF1 API format.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'session_key': sessionKey,
      'driver_number': driverNumber,
      'meeting_key': meetingKey,
      'x': x,
      'y': y,
      'z': z,
    };
  }

  @override
  String toString() => 'CarLocation(driver: $driverNumber, x: $x, y: $y, z: $z)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarLocation &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          driverNumber == other.driverNumber;

  @override
  int get hashCode => Object.hash(date, driverNumber);
}
