/// Model representing a race control event from the OpenF1 API.
///
/// Maps to the `/v1/race_control` endpoint response.
class RaceControlEvent {
  final String category;
  final DateTime date;
  final int? driverNumber;
  final String? flag;
  final int? lapNumber;
  final int meetingKey;
  final String message;
  final int sessionKey;

  const RaceControlEvent({
    required this.category,
    required this.date,
    this.driverNumber,
    this.flag,
    this.lapNumber,
    required this.meetingKey,
    required this.message,
    required this.sessionKey,
  });

  factory RaceControlEvent.fromJson(Map<String, dynamic> json) {
    return RaceControlEvent(
      category: json['category'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      driverNumber: json['driver_number'] as int?,
      flag: json['flag'] as String?,
      lapNumber: json['lap_number'] as int?,
      meetingKey: json['meeting_key'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      sessionKey: json['session_key'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'date': date.toIso8601String(),
      'driver_number': driverNumber,
      'flag': flag,
      'lap_number': lapNumber,
      'meeting_key': meetingKey,
      'message': message,
      'session_key': sessionKey,
    };
  }

  @override
  String toString() => 'RaceControlEvent(category: $category, flag: $flag, msg: $message)';
}
