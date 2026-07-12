/// Model representing weather data from the OpenF1 API.
///
/// Maps to the `/v1/weather` endpoint response. Contains atmospheric
/// conditions at the circuit during a session.
class Weather {
  /// Timestamp of the weather reading.
  final DateTime date;

  /// Unique identifier for the session.
  final int sessionKey;

  /// Unique identifier for the meeting.
  final int meetingKey;

  /// Wind direction in degrees (0-360, where 0/360 = North).
  final int windDirection;

  /// Air temperature in degrees Celsius.
  final double airTemperature;

  /// Relative humidity as a percentage (0-100).
  final double humidity;

  /// Atmospheric pressure in millibars (hPa).
  final double pressure;

  /// Rainfall indicator (0 = no rain, 1 = raining).
  final int rainfall;

  /// Wind speed in km/h.
  final double windSpeed;

  /// Track surface temperature in degrees Celsius.
  final double trackTemperature;

  const Weather({
    required this.date,
    required this.sessionKey,
    required this.meetingKey,
    required this.windDirection,
    required this.airTemperature,
    required this.humidity,
    required this.pressure,
    required this.rainfall,
    required this.windSpeed,
    required this.trackTemperature,
  });

  /// Creates a [Weather] from a JSON map returned by the OpenF1 API.
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      date: DateTime.parse(json['date'] as String),
      sessionKey: json['session_key'] as int,
      meetingKey: json['meeting_key'] as int,
      windDirection: json['wind_direction'] as int,
      airTemperature: (json['air_temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      rainfall: json['rainfall'] as int,
      windSpeed: (json['wind_speed'] as num).toDouble(),
      trackTemperature: (json['track_temperature'] as num).toDouble(),
    );
  }

  /// Converts this [Weather] to a JSON map matching the OpenF1 API format.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'session_key': sessionKey,
      'meeting_key': meetingKey,
      'wind_direction': windDirection,
      'air_temperature': airTemperature,
      'humidity': humidity,
      'pressure': pressure,
      'rainfall': rainfall,
      'wind_speed': windSpeed,
      'track_temperature': trackTemperature,
    };
  }

  /// Whether it is currently raining at the circuit.
  bool get isRaining => rainfall == 1;

  @override
  String toString() =>
      'Weather(air: $airTemperature°C, track: $trackTemperature°C, '
      'rain: $isRaining, wind: $windSpeed km/h)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weather &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          sessionKey == other.sessionKey;

  @override
  int get hashCode => Object.hash(date, sessionKey);
}
