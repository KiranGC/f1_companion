import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/circuit_info.dart';
import '../models/driver.dart';
import '../providers/race_replay_provider.dart' show Point;
import '../theme/app_theme.dart';
import '../theme/team_colors.dart';

class TrackMapWidget extends StatelessWidget {
  final CircuitInfo circuitInfo;
  final Map<int, Point> driverPositions;
  final List<Driver> drivers;
  final Color trackColor;
  final bool hasTelemetry;

  const TrackMapWidget({
    super.key,
    required this.circuitInfo,
    required this.driverPositions,
    required this.drivers,
    this.trackColor = Colors.white,
    this.hasTelemetry = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: TrackMapPainter(
              circuitInfo: circuitInfo,
              driverPositions: driverPositions,
              drivers: drivers,
              trackColor: trackColor,
            ),
            size: Size.infinite,
          ),
        ),
        if (!hasTelemetry)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No telemetry data available for this session.',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: Colors.amber.shade200,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class TrackMapPainter extends CustomPainter {
  final CircuitInfo circuitInfo;
  final Map<int, Point> driverPositions;
  final List<Driver> drivers;
  final Color trackColor;

  TrackMapPainter({
    required this.circuitInfo,
    required this.driverPositions,
    required this.drivers,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (circuitInfo.x.isEmpty || circuitInfo.y.isEmpty) return;

    final padding = 20.0;

    // Apply rotation if specified
    final rotation = circuitInfo.rotation * math.pi / 180.0;

    // Calculate center of raw bounding box to rotate around
    final rawMinX = circuitInfo.x.reduce(math.min).toDouble();
    final rawMaxX = circuitInfo.x.reduce(math.max).toDouble();
    final rawMinY = circuitInfo.y.reduce(math.min).toDouble();
    final rawMaxY = circuitInfo.y.reduce(math.max).toDouble();
    final rawCenterX = (rawMinX + rawMaxX) / 2.0;
    final rawCenterY = (rawMinY + rawMaxY) / 2.0;

    // Helper to rotate raw point around raw center
    Offset rotateRawPoint(double x, double y) {
      if (rotation == 0) return Offset(x, y);
      final rx = x - rawCenterX;
      final ry = y - rawCenterY;
      final rotX = rx * math.cos(rotation) - ry * math.sin(rotation) + rawCenterX;
      final rotY = rx * math.sin(rotation) + ry * math.cos(rotation) + rawCenterY;
      return Offset(rotX, rotY);
    }

    // Compute rotated coordinates for all track points to find actual bounds
    final rotatedPoints = <Offset>[];
    for (int i = 0; i < circuitInfo.x.length; i++) {
      rotatedPoints.add(rotateRawPoint(
        circuitInfo.x[i].toDouble(),
        circuitInfo.y[i].toDouble(),
      ));
    }

    double minX = rotatedPoints.map((p) => p.dx).reduce(math.min);
    double maxX = rotatedPoints.map((p) => p.dx).reduce(math.max);
    double minY = rotatedPoints.map((p) => p.dy).reduce(math.min);
    double maxY = rotatedPoints.map((p) => p.dy).reduce(math.max);

    final trackWidth = maxX - minX;
    final trackHeight = maxY - minY;

    if (trackWidth == 0 || trackHeight == 0) return;

    // Calculate scale to fit canvas preserving aspect ratio
    final availableWidth = size.width - 2 * padding;
    final availableHeight = size.height - 2 * padding;
    final scale = math.min(
      availableWidth / trackWidth,
      availableHeight / trackHeight,
    );

    // Center the track
    final scaledTrackWidth = trackWidth * scale;
    final scaledTrackHeight = trackHeight * scale;
    final offsetX = (size.width - scaledTrackWidth) / 2;
    final offsetY = (size.height - scaledTrackHeight) / 2;

    // Transform function: raw track coord -> canvas coord
    Offset transformPoint(double x, double y) {
      final rotP = rotateRawPoint(x, y);
      final nx = (rotP.dx - minX) * scale;
      final ny = (rotP.dy - minY) * scale;
      return Offset(nx + offsetX, ny + offsetY);
    }

    // Build track path
    final path = Path();
    for (int i = 0; i < circuitInfo.x.length; i++) {
      final p = transformPoint(
        circuitInfo.x[i].toDouble(),
        circuitInfo.y[i].toDouble(),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    // Draw track glow
    final glowPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);

    // Draw track outline
    final trackPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, trackPaint);

    // Draw corner numbers
    for (final corner in circuitInfo.corners) {
      final pos = corner.trackPosition;
      final cp = transformPoint(
        pos.x,
        pos.y,
      );

      // Small numbered circle
      final circlePaint = Paint()
        ..color = AppTheme.textMuted.withValues(alpha: 0.5);
      canvas.drawCircle(cp, 8, circlePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${corner.number}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 7,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(cp.dx - textPainter.width / 2, cp.dy - textPainter.height / 2),
      );
    }

    // Build a map from driver number to driver for quick lookup
    final driverMap = <int, Driver>{};
    for (final d in drivers) {
      driverMap[d.driverNumber] = d;
    }

    // Draw driver dots
    for (final entry in driverPositions.entries) {
      final driverNumber = entry.key;
      final pos = entry.value;

      final dp = transformPoint(pos.x, pos.y);
      final driver = driverMap[driverNumber];

      // Get team color
      Color teamColor = AppTheme.textMuted;
      String acronym = '';
      if (driver != null) {
        teamColor = TeamColors.getTeamColor(driver.teamName);
        acronym = driver.nameAcronym;
      }

      // Filled circle for driver
      final dotPaint = Paint()..color = teamColor;
      canvas.drawCircle(dp, 10, dotPaint);

      // Acronym text
      if (acronym.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: acronym,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(dp.dx + 12, dp.dy - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TrackMapPainter oldDelegate) {
    if (oldDelegate.circuitInfo != circuitInfo ||
        oldDelegate.trackColor != trackColor) {
      return true;
    }
    if (oldDelegate.driverPositions.length != driverPositions.length) {
      return true;
    }
    for (final key in driverPositions.keys) {
      if (oldDelegate.driverPositions[key] != driverPositions[key]) {
        return true;
      }
    }
    return false;
  }
}
