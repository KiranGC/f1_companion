/// Model representing circuit layout information from the MultiViewer API.
///
/// Contains the track outline coordinates, corner positions, and marshal
/// light positions used for rendering the circuit map visualization.
class CircuitInfo {
  /// Unique identifier for the circuit.
  final int circuitKey;

  /// Full name of the circuit.
  final String circuitName;

  /// Country where the circuit is located.
  final String countryName;

  /// City or locality of the circuit.
  final String location;

  /// Rotation angle in degrees to orient the circuit map.
  final int rotation;

  /// X-coordinates of the track outline (300-900 points).
  final List<int> x;

  /// Y-coordinates of the track outline (same length as [x]).
  final List<int> y;

  /// List of corner positions on the circuit.
  final List<Corner> corners;

  /// List of marshal light positions on the circuit.
  final List<MarshalLight> marshalLights;

  const CircuitInfo({
    required this.circuitKey,
    required this.circuitName,
    required this.countryName,
    required this.location,
    required this.rotation,
    required this.x,
    required this.y,
    required this.corners,
    required this.marshalLights,
  });

  /// Creates a [CircuitInfo] from a JSON map returned by the MultiViewer API.
  ///
  /// Note: The MultiViewer API uses camelCase keys unlike the OpenF1 API.
  factory CircuitInfo.fromJson(Map<String, dynamic> json) {
    return CircuitInfo(
      circuitKey: json['circuitKey'] as int,
      circuitName: json['circuitName'] as String,
      countryName: json['countryName'] as String,
      location: json['location'] as String,
      rotation: (json['rotation'] as num).toInt(),
      x: (json['x'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      y: (json['y'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      corners: (json['corners'] as List<dynamic>)
          .map((e) => Corner.fromJson(e as Map<String, dynamic>))
          .toList(),
      marshalLights: (json['marshalLights'] as List<dynamic>)
          .map((e) => MarshalLight.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this [CircuitInfo] to a JSON map matching the MultiViewer API format.
  Map<String, dynamic> toJson() {
    return {
      'circuitKey': circuitKey,
      'circuitName': circuitName,
      'countryName': countryName,
      'location': location,
      'rotation': rotation,
      'x': x,
      'y': y,
      'corners': corners.map((e) => e.toJson()).toList(),
      'marshalLights': marshalLights.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'CircuitInfo(circuitKey: $circuitKey, circuitName: $circuitName, '
      'points: ${x.length}, corners: ${corners.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircuitInfo &&
          runtimeType == other.runtimeType &&
          circuitKey == other.circuitKey;

  @override
  int get hashCode => circuitKey.hashCode;
}

/// Model representing a track position with x and y coordinates.
///
/// Used by [Corner] and [MarshalLight] to specify positions on the
/// circuit map.
class TrackPosition {
  /// X-coordinate of the position on the circuit map.
  final double x;

  /// Y-coordinate of the position on the circuit map.
  final double y;

  const TrackPosition({
    required this.x,
    required this.y,
  });

  /// Creates a [TrackPosition] from a JSON map.
  factory TrackPosition.fromJson(Map<String, dynamic> json) {
    return TrackPosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  /// Converts this [TrackPosition] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  @override
  String toString() => 'TrackPosition(x: $x, y: $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackPosition &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// Model representing a corner on the circuit.
///
/// Contains the corner number, geometric properties, and its position
/// on the track map.
class Corner {
  /// Corner number (sequential around the circuit).
  final int number;

  /// Angle of the corner in degrees.
  final double angle;

  /// Length of the corner in meters.
  final double length;

  /// Position of the corner on the circuit map.
  final TrackPosition trackPosition;

  const Corner({
    required this.number,
    required this.angle,
    required this.length,
    required this.trackPosition,
  });

  /// Creates a [Corner] from a JSON map returned by the MultiViewer API.
  factory Corner.fromJson(Map<String, dynamic> json) {
    return Corner(
      number: json['number'] as int,
      angle: (json['angle'] as num).toDouble(),
      length: (json['length'] as num).toDouble(),
      trackPosition:
          TrackPosition.fromJson(json['trackPosition'] as Map<String, dynamic>),
    );
  }

  /// Converts this [Corner] to a JSON map matching the MultiViewer API format.
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'angle': angle,
      'length': length,
      'trackPosition': trackPosition.toJson(),
    };
  }

  @override
  String toString() => 'Corner(number: $number, angle: $angle)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Corner &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;
}

/// Model representing a marshal light position on the circuit.
///
/// Marshal lights are used to display flag/safety car status at
/// specific points around the track.
class MarshalLight {
  /// Marshal light number (sequential around the circuit).
  final int number;

  /// Position of the marshal light on the circuit map.
  final TrackPosition trackPosition;

  const MarshalLight({
    required this.number,
    required this.trackPosition,
  });

  /// Creates a [MarshalLight] from a JSON map returned by the MultiViewer API.
  factory MarshalLight.fromJson(Map<String, dynamic> json) {
    return MarshalLight(
      number: json['number'] as int,
      trackPosition:
          TrackPosition.fromJson(json['trackPosition'] as Map<String, dynamic>),
    );
  }

  /// Converts this [MarshalLight] to a JSON map matching the MultiViewer API format.
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'trackPosition': trackPosition.toJson(),
    };
  }

  @override
  String toString() => 'MarshalLight(number: $number)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarshalLight &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;
}
