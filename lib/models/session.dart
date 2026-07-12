/// Model representing an F1 session from the OpenF1 API.
///
/// A session is a single on-track activity within a meeting, such as
/// Practice, Qualifying, Sprint, or Race.
class Session {
  /// Unique identifier for the session.
  final int sessionKey;

  /// Type of session (e.g., "Practice", "Qualifying", "Race").
  final String sessionType;

  /// Display name of the session (e.g., "Practice 1", "Qualifying").
  final String sessionName;

  /// Start date and time of the session.
  final DateTime dateStart;

  /// End date and time of the session.
  final DateTime dateEnd;

  /// Unique identifier of the parent meeting.
  final int meetingKey;

  /// Unique identifier for the circuit.
  final int circuitKey;

  /// Short name of the circuit (e.g., "Spielberg").
  final String circuitShortName;

  /// Unique identifier for the country.
  final int countryKey;

  /// ISO country code (e.g., "AUT").
  final String countryCode;

  /// Full country name (e.g., "Austria").
  final String countryName;

  /// City or locality where the session takes place.
  final String location;

  /// GMT offset string for the session's timezone (e.g., "+02:00").
  final String gmtOffset;

  /// Season year of the session.
  final int year;

  /// Whether the session has been cancelled.
  final bool isCancelled;

  const Session({
    required this.sessionKey,
    required this.sessionType,
    required this.sessionName,
    required this.dateStart,
    required this.dateEnd,
    required this.meetingKey,
    required this.circuitKey,
    required this.circuitShortName,
    required this.countryKey,
    required this.countryCode,
    required this.countryName,
    required this.location,
    required this.gmtOffset,
    required this.year,
    required this.isCancelled,
  });

  /// Creates a [Session] from a JSON map returned by the OpenF1 API.
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionKey: json['session_key'] as int,
      sessionType: json['session_type'] as String,
      sessionName: json['session_name'] as String,
      dateStart: DateTime.parse(json['date_start'] as String),
      dateEnd: DateTime.parse(json['date_end'] as String),
      meetingKey: json['meeting_key'] as int,
      circuitKey: json['circuit_key'] as int,
      circuitShortName: json['circuit_short_name'] as String,
      countryKey: json['country_key'] as int,
      countryCode: json['country_code'] as String,
      countryName: json['country_name'] as String,
      location: json['location'] as String,
      gmtOffset: json['gmt_offset'] as String,
      year: json['year'] as int,
      isCancelled: json['is_cancelled'] as bool? ?? false,
    );
  }

  /// Converts this [Session] to a JSON map matching the OpenF1 API format.
  Map<String, dynamic> toJson() {
    return {
      'session_key': sessionKey,
      'session_type': sessionType,
      'session_name': sessionName,
      'date_start': dateStart.toIso8601String(),
      'date_end': dateEnd.toIso8601String(),
      'meeting_key': meetingKey,
      'circuit_key': circuitKey,
      'circuit_short_name': circuitShortName,
      'country_key': countryKey,
      'country_code': countryCode,
      'country_name': countryName,
      'location': location,
      'gmt_offset': gmtOffset,
      'year': year,
      'is_cancelled': isCancelled,
    };
  }

  @override
  String toString() => 'Session(sessionKey: $sessionKey, sessionName: $sessionName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          runtimeType == other.runtimeType &&
          sessionKey == other.sessionKey;

  @override
  int get hashCode => sessionKey.hashCode;
}
