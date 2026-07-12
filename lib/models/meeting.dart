/// Model representing an F1 meeting (race weekend) from the OpenF1 API.
///
/// Maps to the `/v1/meetings` endpoint response. Contains metadata about
/// the race weekend including location, circuit details, and schedule.
class Meeting {
  /// Unique identifier for the meeting.
  final int meetingKey;

  /// Short name of the meeting (e.g., "Austrian Grand Prix").
  final String meetingName;

  /// Official full name of the meeting.
  final String meetingOfficialName;

  /// City or locality where the meeting takes place.
  final String location;

  /// Unique identifier for the country.
  final int countryKey;

  /// ISO country code (e.g., "AUT").
  final String countryCode;

  /// Full country name (e.g., "Austria").
  final String countryName;

  /// URL to the country's flag image.
  final String countryFlag;

  /// Unique identifier for the circuit.
  final int circuitKey;

  /// Short name of the circuit (e.g., "Spielberg").
  final String circuitShortName;

  /// Type of circuit (e.g., "race", "street").
  final String circuitType;

  /// URL to circuit information page.
  final String circuitInfoUrl;

  /// URL to the circuit layout image.
  final String circuitImage;

  /// GMT offset string for the meeting's timezone (e.g., "+02:00").
  final String gmtOffset;

  /// Start date and time of the meeting.
  final DateTime dateStart;

  /// End date and time of the meeting.
  final DateTime dateEnd;

  /// Season year of the meeting.
  final int year;

  /// Whether the meeting has been cancelled.
  final bool isCancelled;

  const Meeting({
    required this.meetingKey,
    required this.meetingName,
    required this.meetingOfficialName,
    required this.location,
    required this.countryKey,
    required this.countryCode,
    required this.countryName,
    required this.countryFlag,
    required this.circuitKey,
    required this.circuitShortName,
    required this.circuitType,
    required this.circuitInfoUrl,
    required this.circuitImage,
    required this.gmtOffset,
    required this.dateStart,
    required this.dateEnd,
    required this.year,
    required this.isCancelled,
  });

  /// Creates a [Meeting] from a JSON map returned by the OpenF1 API.
  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      meetingKey: json['meeting_key'] as int,
      meetingName: json['meeting_name'] as String,
      meetingOfficialName: json['meeting_official_name'] as String,
      location: json['location'] as String,
      countryKey: json['country_key'] as int,
      countryCode: json['country_code'] as String,
      countryName: json['country_name'] as String,
      countryFlag: json['country_flag'] as String,
      circuitKey: json['circuit_key'] as int,
      circuitShortName: json['circuit_short_name'] as String,
      circuitType: json['circuit_type'] as String,
      circuitInfoUrl: json['circuit_info_url'] as String,
      circuitImage: json['circuit_image'] as String,
      gmtOffset: json['gmt_offset'] as String,
      dateStart: DateTime.parse(json['date_start'] as String),
      dateEnd: DateTime.parse(json['date_end'] as String),
      year: json['year'] as int,
      isCancelled: json['is_cancelled'] as bool? ?? false,
    );
  }

  /// Converts this [Meeting] to a JSON map matching the OpenF1 API format.
  Map<String, dynamic> toJson() {
    return {
      'meeting_key': meetingKey,
      'meeting_name': meetingName,
      'meeting_official_name': meetingOfficialName,
      'location': location,
      'country_key': countryKey,
      'country_code': countryCode,
      'country_name': countryName,
      'country_flag': countryFlag,
      'circuit_key': circuitKey,
      'circuit_short_name': circuitShortName,
      'circuit_type': circuitType,
      'circuit_info_url': circuitInfoUrl,
      'circuit_image': circuitImage,
      'gmt_offset': gmtOffset,
      'date_start': dateStart.toIso8601String(),
      'date_end': dateEnd.toIso8601String(),
      'year': year,
      'is_cancelled': isCancelled,
    };
  }

  @override
  String toString() => 'Meeting(meetingKey: $meetingKey, meetingName: $meetingName, year: $year)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meeting &&
          runtimeType == other.runtimeType &&
          meetingKey == other.meetingKey;

  @override
  int get hashCode => meetingKey.hashCode;
}
