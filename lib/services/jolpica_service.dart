import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class JolpicaService {
  Future<List<Map<String, dynamic>>> getRaceCalendar(int year);
}

class HttpJolpicaService implements JolpicaService {
  static const String _baseUrl = 'https://api.jolpi.ca/ergast/f1';

  final http.Client _client;

  HttpJolpicaService(this._client);

  /// Fetches the race calendar for the given [year].
  ///
  /// Returns the list found at `MRData.RaceTable.Races` in the JSON response,
  /// or an empty list on failure.
  @override
  Future<List<Map<String, dynamic>>> getRaceCalendar(int year) async {
    final url = '$_baseUrl/$year.json';
    try {
      final response = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final mrData = data['MRData'] as Map<String, dynamic>?;
        final raceTable = mrData?['RaceTable'] as Map<String, dynamic>?;
        final races = raceTable?['Races'] as List<dynamic>?;

        if (races != null) {
          return races
              .map((race) => race as Map<String, dynamic>)
              .toList();
        }

        debugPrint('JolpicaService: Unexpected JSON structure at $url');
        return [];
      } else {
        debugPrint(
          'JolpicaService: GET $url returned ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('JolpicaService: Error fetching $url — $e');
      return [];
    }
  }
}
