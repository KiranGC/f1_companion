/// Model representing interval/gap data from the OpenF1 API.
///
/// Maps to the `/v1/intervals` endpoint response. Contains the gap
/// to the race leader and the interval to the car ahead.
/// Both [gapToLeader] and [interval] may be null when data is unavailable
/// (e.g., for the leader's gap_to_leader, or during safety car periods).
class IntervalData {
  /// Timestamp of the interval measurement.
  final DateTime date;

  /// Unique identifier for the session.
  final int sessionKey;

  /// The driver's car number.
  final int driverNumber;

  /// Unique identifier for the meeting.
  final int meetingKey;

  /// Time gap to the race leader in seconds. Null for the leader or when unavailable.
  final double? gapToLeader;

  /// String representation of the time gap to the race leader, preserving raw string flags like "+1 LAP".
  final String? gapToLeaderDisplay;

  /// Time interval to the car directly ahead in seconds. Null for the leader or when unavailable.
  final double? interval;

  const IntervalData({
    required this.date,
    required this.sessionKey,
    required this.driverNumber,
    required this.meetingKey,
    this.gapToLeader,
    this.gapToLeaderDisplay,
    this.interval,
  });

  /// Creates an [IntervalData] from a JSON map returned by the OpenF1 API.
  ///
  /// Handles the case where `gap_to_leader` and `interval` may be returned
  /// as either a number or a string (e.g., "LAP" for lapped cars).
  factory IntervalData.fromJson(Map<String, dynamic> json) {
    final rawGap = json['gap_to_leader'];
    return IntervalData(
      date: DateTime.parse(json['date'] as String),
      sessionKey: json['session_key'] as int,
      driverNumber: json['driver_number'] as int,
      meetingKey: json['meeting_key'] as int,
      gapToLeader: _parseNullableDouble(rawGap),
      gapToLeaderDisplay: rawGap?.toString(),
      interval: _parseNullableDouble(json['interval']),
    );
  }

  /// Parses a value that may be a num, a numeric string, or a non-numeric
  /// string (like "LAP") into a nullable double.
  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Converts this [IntervalData] to a JSON map matching the OpenF1 API format.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'session_key': sessionKey,
      'driver_number': driverNumber,
      'meeting_key': meetingKey,
      'gap_to_leader': gapToLeaderDisplay ?? gapToLeader,
      'interval': interval,
    };
  }

  @override
  String toString() =>
      'IntervalData(driver: $driverNumber, gap: $gapToLeader, interval: $interval)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalData &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          driverNumber == other.driverNumber;

  @override
  int get hashCode => Object.hash(date, driverNumber);
}
