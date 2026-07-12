/// Model representing a driver's race position at a point in time from the OpenF1 API.
///
/// Maps to the `/v1/position` endpoint response. Tracks how driver
/// positions change throughout a session.
class RacePosition {
  /// Timestamp of the position update.
  final DateTime date;

  /// Unique identifier for the session.
  final int sessionKey;

  /// Unique identifier for the meeting.
  final int meetingKey;

  /// The driver's car number.
  final int driverNumber;

  /// The driver's current position (1-indexed).
  final int position;

  const RacePosition({
    required this.date,
    required this.sessionKey,
    required this.meetingKey,
    required this.driverNumber,
    required this.position,
  });

  /// Creates a [RacePosition] from a JSON map returned by the OpenF1 API.
  factory RacePosition.fromJson(Map<String, dynamic> json) {
    return RacePosition(
      date: DateTime.parse(json['date'] as String),
      sessionKey: json['session_key'] as int,
      meetingKey: json['meeting_key'] as int,
      driverNumber: json['driver_number'] as int,
      position: json['position'] as int,
    );
  }

  /// Converts this [RacePosition] to a JSON map matching the OpenF1 API format.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'session_key': sessionKey,
      'meeting_key': meetingKey,
      'driver_number': driverNumber,
      'position': position,
    };
  }

  @override
  String toString() => 'RacePosition(driver: $driverNumber, position: $position)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RacePosition &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          driverNumber == other.driverNumber;

  @override
  int get hashCode => Object.hash(date, driverNumber);
}
