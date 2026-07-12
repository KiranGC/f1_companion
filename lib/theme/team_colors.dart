import 'package:flutter/material.dart';

/// Provides F1 team colour mapping and tyre compound colour utilities.
///
/// Team colours follow the 2026 season branding. Tyre compound colours
/// match the official Pirelli compound colour scheme.
class TeamColors {
  TeamColors._();

  // ---------------------------------------------------------------------------
  // Team Colours (2026 season)
  // ---------------------------------------------------------------------------

  /// Map of team name → brand colour.
  ///
  /// Keys are title-cased team names as returned by the OpenF1 API's
  /// `team_name` field. The values are opaque [Color] instances.
  static final Map<String, Color> teamColors = {
    'McLaren': fromHex('FF4760'),
    'Red Bull Racing': fromHex('4781D7'),
    'Audi': fromHex('F50537'),
    'Alpine': fromHex('00A1E8'),
    'Cadillac': fromHex('909090'),
    'Mercedes': fromHex('00D2BE'),
    'Ferrari': fromHex('E80020'),
    'Haas F1 Team': fromHex('B6BABD'),
    'Williams': fromHex('005AFF'),
    'RB': fromHex('6692FF'),
  };

  /// Returns the brand [Color] for the given [teamName].
  ///
  /// Falls back to a neutral grey if the team is not found in the map.
  static Color getTeamColor(String teamName) {
    return teamColors[teamName] ?? const Color(0xFF888888);
  }

  /// Converts a hex string **without** the `#` prefix to a [Color].
  ///
  /// Example: `fromHex('FF4760')` → `Color(0xFFFF4760)`.
  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6) buffer.write('FF');
    buffer.write(hex.toUpperCase());
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // ---------------------------------------------------------------------------
  // Tyre Compound Colours
  // ---------------------------------------------------------------------------

  /// Map of Pirelli tyre compound → colour.
  static final Map<String, Color> tireCompoundColors = {
    'SOFT': fromHex('FF3333'),
    'MEDIUM': fromHex('FFCC00'),
    'HARD': fromHex('FFFFFF'),
    'INTERMEDIATE': fromHex('39B54A'),
    'WET': fromHex('0072C6'),
  };

  /// Returns the [Color] for a given tyre [compound] string.
  ///
  /// Falls back to neutral grey if the compound is not recognised.
  static Color getTireColor(String compound) {
    return tireCompoundColors[compound.toUpperCase()] ??
        const Color(0xFF555555);
  }
}
