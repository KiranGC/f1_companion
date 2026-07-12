/// Model representing an F1 driver from the OpenF1 API.
///
/// Contains driver identity, team affiliation, and session context.
/// The [headshotUrl] and [countryCode] fields are nullable as they
/// may not be available for all drivers.
class Driver {
  /// Unique identifier for the meeting this driver entry belongs to.
  final int meetingKey;

  /// Unique identifier for the session this driver entry belongs to.
  final int sessionKey;

  /// The driver's car number (e.g., 1 for Verstappen, 44 for Hamilton).
  final int driverNumber;

  /// Broadcast-friendly name (e.g., "M VERSTAPPEN").
  final String broadcastName;

  /// Full name of the driver (e.g., "Max VERSTAPPEN").
  final String fullName;

  /// Three-letter acronym (e.g., "VER").
  final String nameAcronym;

  /// Name of the driver's team (e.g., "Red Bull Racing").
  final String teamName;

  /// Team colour as a hex string without the '#' prefix (e.g., "3671C6").
  final String teamColour;

  /// Driver's first name.
  final String firstName;

  /// Driver's last name.
  final String lastName;

  /// URL to the driver's headshot image. May be null if unavailable.
  final String? headshotUrl;

  /// ISO country code of the driver's nationality. May be null.
  final String? countryCode;

  const Driver({
    required this.meetingKey,
    required this.sessionKey,
    required this.driverNumber,
    required this.broadcastName,
    required this.fullName,
    required this.nameAcronym,
    required this.teamName,
    required this.teamColour,
    required this.firstName,
    required this.lastName,
    this.headshotUrl,
    this.countryCode,
  });

  /// Creates a [Driver] from a JSON map returned by the OpenF1 API.
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      meetingKey: json['meeting_key'] as int,
      sessionKey: json['session_key'] as int,
      driverNumber: json['driver_number'] as int,
      broadcastName: json['broadcast_name'] as String,
      fullName: json['full_name'] as String,
      nameAcronym: json['name_acronym'] as String,
      teamName: json['team_name'] as String,
      teamColour: json['team_colour'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      headshotUrl: json['headshot_url'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  /// Converts this [Driver] to a JSON map matching the OpenF1 API format.
  Map<String, dynamic> toJson() {
    return {
      'meeting_key': meetingKey,
      'session_key': sessionKey,
      'driver_number': driverNumber,
      'broadcast_name': broadcastName,
      'full_name': fullName,
      'name_acronym': nameAcronym,
      'team_name': teamName,
      'team_colour': teamColour,
      'first_name': firstName,
      'last_name': lastName,
      'headshot_url': headshotUrl,
      'country_code': countryCode,
    };
  }

  /// Returns the team colour as a hex string with '#' prefix for use in UI.
  String get teamColourHex => '#$teamColour';

  @override
  String toString() => 'Driver(driverNumber: $driverNumber, fullName: $fullName, teamName: $teamName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Driver &&
          runtimeType == other.runtimeType &&
          sessionKey == other.sessionKey &&
          driverNumber == other.driverNumber;

  @override
  int get hashCode => Object.hash(sessionKey, driverNumber);
}
