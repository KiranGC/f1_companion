/// Model representing a tyre stint from the OpenF1 API.
///
/// Maps to the `/v1/stints` endpoint response. A stint is a continuous
/// period of driving on the same set of tyres between pit stops.
class Stint {
  /// Unique identifier for the meeting.
  final int meetingKey;

  /// Unique identifier for the session.
  final int sessionKey;

  /// Sequential stint number within the session (1-indexed).
  final int stintNumber;

  /// The driver's car number.
  final int driverNumber;

  /// Lap number when the stint started.
  final int lapStart;

  /// Lap number when the stint ended.
  final int lapEnd;

  /// Tyre compound used (e.g., "SOFT", "MEDIUM", "HARD", "INTERMEDIATE", "WET").
  final String? compound;

  /// Number of laps already on the tyre at the start of this stint.
  ///
  /// A value > 0 indicates used tyres (e.g., from a previous session
  /// or a red-flag restart).
  final int tyreAgeAtStart;

  const Stint({
    required this.meetingKey,
    required this.sessionKey,
    required this.stintNumber,
    required this.driverNumber,
    required this.lapStart,
    required this.lapEnd,
    this.compound,
    required this.tyreAgeAtStart,
  });

  /// Creates a [Stint] from a JSON map returned by the OpenF1 API.
  factory Stint.fromJson(Map<String, dynamic> json) {
    return Stint(
      meetingKey: json['meeting_key'] as int,
      sessionKey: json['session_key'] as int,
      stintNumber: json['stint_number'] as int,
      driverNumber: json['driver_number'] as int,
      lapStart: json['lap_start'] as int,
      lapEnd: json['lap_end'] as int,
      compound: json['compound'] as String?,
      tyreAgeAtStart: json['tyre_age_at_start'] as int,
    );
  }

  /// Converts this [Stint] to a JSON map matching the OpenF1 API format.
  Map<String, dynamic> toJson() {
    return {
      'meeting_key': meetingKey,
      'session_key': sessionKey,
      'stint_number': stintNumber,
      'driver_number': driverNumber,
      'lap_start': lapStart,
      'lap_end': lapEnd,
      'compound': compound,
      'tyre_age_at_start': tyreAgeAtStart,
    };
  }

  /// Total number of laps completed during this stint.
  int get stintLength => lapEnd - lapStart + 1;

  /// Total tyre age at the end of this stint.
  int get tyreAgeAtEnd => tyreAgeAtStart + stintLength;

  @override
  String toString() =>
      'Stint(driver: $driverNumber, stint: $stintNumber, compound: $compound, '
      'laps: $lapStart-$lapEnd)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stint &&
          runtimeType == other.runtimeType &&
          sessionKey == other.sessionKey &&
          driverNumber == other.driverNumber &&
          stintNumber == other.stintNumber;

  @override
  int get hashCode => Object.hash(sessionKey, driverNumber, stintNumber);
}
