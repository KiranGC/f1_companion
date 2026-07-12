/// Model representing lap data from the OpenF1 API.
///
/// Maps to the `/v1/laps` endpoint response. Contains sector times,
/// speed trap readings, and mini-sector segment status indicators.
/// Many fields are nullable as data may be incomplete for in-progress
/// or aborted laps.
class Lap {
  /// Unique identifier for the meeting.
  final int meetingKey;

  /// Unique identifier for the session.
  final int sessionKey;

  /// The driver's car number.
  final int driverNumber;

  /// Sequential lap number (1-indexed).
  final int lapNumber;

  /// Timestamp when the lap started. Null for incomplete data.
  final DateTime? dateStart;

  /// Duration of sector 1 in seconds. Null if sector not completed.
  final double? durationSector1;

  /// Duration of sector 2 in seconds. Null if sector not completed.
  final double? durationSector2;

  /// Duration of sector 3 in seconds. Null if sector not completed.
  final double? durationSector3;

  /// Speed at intermediate point 1 in km/h. Null if not recorded.
  final int? i1Speed;

  /// Speed at intermediate point 2 in km/h. Null if not recorded.
  final int? i2Speed;

  /// Whether this lap is a pit-out lap.
  final bool isPitOutLap;

  /// Total lap duration in seconds. Null if lap not completed.
  final double? lapDuration;

  /// Speed trap speed in km/h. Null if not recorded.
  final int? stSpeed;

  /// Mini-sector segment statuses for sector 1.
  ///
  /// Each int represents a status code (e.g., 0=unknown, 2048=green,
  /// 2049=yellow, 2050=purple, 2051=personal best, 2064=pit).
  /// Null if segment data is unavailable.
  /// Mini-sector segment statuses for sector 1.
  ///
  /// Each int represents a status code (e.g., 0=unknown, 2048=green,
  /// 2049=yellow, 2050=purple, 2051=personal best, 2064=pit).
  /// Null if segment data is unavailable.
  final List<int?>? segmentsSector1;

  /// Mini-sector segment statuses for sector 2.
  final List<int?>? segmentsSector2;

  /// Mini-sector segment statuses for sector 3.
  final List<int?>? segmentsSector3;

  const Lap({
    required this.meetingKey,
    required this.sessionKey,
    required this.driverNumber,
    required this.lapNumber,
    this.dateStart,
    this.durationSector1,
    this.durationSector2,
    this.durationSector3,
    this.i1Speed,
    this.i2Speed,
    required this.isPitOutLap,
    this.lapDuration,
    this.stSpeed,
    this.segmentsSector1,
    this.segmentsSector2,
    this.segmentsSector3,
  });

  /// Creates a [Lap] from a JSON map returned by the OpenF1 API.
  factory Lap.fromJson(Map<String, dynamic> json) {
    return Lap(
      meetingKey: json['meeting_key'] as int,
      sessionKey: json['session_key'] as int,
      driverNumber: json['driver_number'] as int,
      lapNumber: json['lap_number'] as int,
      dateStart: json['date_start'] != null
          ? DateTime.parse(json['date_start'] as String)
          : null,
      durationSector1: (json['duration_sector_1'] as num?)?.toDouble(),
      durationSector2: (json['duration_sector_2'] as num?)?.toDouble(),
      durationSector3: (json['duration_sector_3'] as num?)?.toDouble(),
      i1Speed: json['i1_speed'] as int?,
      i2Speed: json['i2_speed'] as int?,
      isPitOutLap: json['is_pit_out_lap'] as bool? ?? false,
      lapDuration: (json['lap_duration'] as num?)?.toDouble(),
      stSpeed: json['st_speed'] as int?,
      segmentsSector1: (json['segments_sector_1'] as List<dynamic>?)
          ?.map((e) => e as int?)
          .toList(),
      segmentsSector2: (json['segments_sector_2'] as List<dynamic>?)
          ?.map((e) => e as int?)
          .toList(),
      segmentsSector3: (json['segments_sector_3'] as List<dynamic>?)
          ?.map((e) => e as int?)
          .toList(),
    );
  }

  /// Converts this [Lap] to a JSON map matching the OpenF1 API format.
  Map<String, dynamic> toJson() {
    return {
      'meeting_key': meetingKey,
      'session_key': sessionKey,
      'driver_number': driverNumber,
      'lap_number': lapNumber,
      'date_start': dateStart?.toIso8601String(),
      'duration_sector_1': durationSector1,
      'duration_sector_2': durationSector2,
      'duration_sector_3': durationSector3,
      'i1_speed': i1Speed,
      'i2_speed': i2Speed,
      'is_pit_out_lap': isPitOutLap,
      'lap_duration': lapDuration,
      'st_speed': stSpeed,
      'segments_sector_1': segmentsSector1,
      'segments_sector_2': segmentsSector2,
      'segments_sector_3': segmentsSector3,
    };
  }

  /// Returns the total duration of all three sectors combined, or null
  /// if any sector time is missing.
  double? get totalSectorDuration {
    if (durationSector1 == null ||
        durationSector2 == null ||
        durationSector3 == null) {
      return null;
    }
    return durationSector1! + durationSector2! + durationSector3!;
  }

  @override
  String toString() =>
      'Lap(driver: $driverNumber, lap: $lapNumber, duration: $lapDuration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lap &&
          runtimeType == other.runtimeType &&
          sessionKey == other.sessionKey &&
          driverNumber == other.driverNumber &&
          lapNumber == other.lapNumber;

  @override
  int get hashCode => Object.hash(sessionKey, driverNumber, lapNumber);
}
