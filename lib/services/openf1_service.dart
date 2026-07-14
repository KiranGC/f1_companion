import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/meeting.dart';
import '../models/session.dart';
import '../models/driver.dart';
import '../models/car_location.dart';
import '../models/race_position.dart';
import '../models/interval_data.dart';
import '../models/lap.dart';
import '../models/stint.dart';
import '../models/weather.dart';
import '../models/race_control_event.dart';

abstract class OpenF1Service {
  Future<List<Meeting>> getMeetings(int year);
  Future<List<Session>> getSessions(int meetingKey);
  Future<List<Driver>> getDrivers(int sessionKey);
  Future<List<CarLocation>> getAllDriverLocations({
    required int sessionKey,
    required DateTime dateStart,
    required DateTime dateEnd,
  });
  Future<List<RacePosition>> getPositions(int sessionKey);
  Future<List<IntervalData>> getIntervals(int sessionKey);
  Future<List<Lap>> getAllLaps(int sessionKey);
  Future<List<Stint>> getStints(int sessionKey);
  Future<List<Weather>> getWeather(int sessionKey);
  Future<List<RaceControlEvent>> getRaceControlEvents(int sessionKey);
}

class HttpOpenF1Service implements OpenF1Service {
  static const String _baseUrl = 'https://api.openf1.org/v1';

  final http.Client _client;

  HttpOpenF1Service(this._client);

  Future<List<T>> _getList<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    int retries = 3;
    int backoffMs = 500;

    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body) as List<dynamic>;
          return data
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (response.statusCode == 429 && attempt < retries) {
          debugPrint('OpenF1Service: Rate limited (429) on GET $url. Retrying in ${backoffMs}ms...');
          await Future.delayed(Duration(milliseconds: backoffMs));
          backoffMs *= 2; // exponential backoff
          continue;
        } else {
          debugPrint('OpenF1Service: GET $url returned ${response.statusCode}');
          throw Exception('OpenF1 API error: GET $url returned ${response.statusCode}');
        }
      } catch (e) {
        if (attempt < retries) {
          debugPrint('OpenF1Service: Error fetching $url ($e). Retrying in ${backoffMs}ms...');
          await Future.delayed(Duration(milliseconds: backoffMs));
          backoffMs *= 2;
          continue;
        }
        debugPrint('OpenF1Service: Final error fetching $url — $e');
        rethrow;
      }
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Meetings
  // ---------------------------------------------------------------------------

  @override
  Future<List<Meeting>> getMeetings(int year) {
    return _getList<Meeting>(
      '$_baseUrl/meetings?year=$year',
      Meeting.fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  @override
  Future<List<Session>> getSessions(int meetingKey) {
    return _getList<Session>(
      '$_baseUrl/sessions?meeting_key=$meetingKey',
      Session.fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Drivers
  // ---------------------------------------------------------------------------

  @override
  Future<List<Driver>> getDrivers(int sessionKey) {
    return _getList<Driver>(
      '$_baseUrl/drivers?session_key=$sessionKey',
      Driver.fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Car Locations
  // ---------------------------------------------------------------------------
  @override
  Future<List<CarLocation>> getAllDriverLocations({
    required int sessionKey,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) {
    final start = dateStart.toUtc().toIso8601String();
    final end = dateEnd.toUtc().toIso8601String();
    return _getList<CarLocation>(
      '$_baseUrl/location?session_key=$sessionKey'
      '&date>=$start'
      '&date<=$end',
      CarLocation.fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Positions
  // ---------------------------------------------------------------------------

  @override
  Future<List<RacePosition>> getPositions(int sessionKey) {
    return _getList<RacePosition>(
      '$_baseUrl/position?session_key=$sessionKey',
      RacePosition.fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Intervals
  // ---------------------------------------------------------------------------

  @override
  Future<List<IntervalData>> getIntervals(int sessionKey) {
    return _getList<IntervalData>(
      '$_baseUrl/intervals?session_key=$sessionKey',
      IntervalData.fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Laps
  // ---------------------------------------------------------------------------

  @override
  Future<List<Lap>> getAllLaps(int sessionKey) {
    return _getList<Lap>(
      '$_baseUrl/laps?session_key=$sessionKey',
      Lap.fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Stints
  // ---------------------------------------------------------------------------

  @override
  Future<List<Stint>> getStints(int sessionKey) {
    return _getList<Stint>(
      '$_baseUrl/stints?session_key=$sessionKey',
      Stint.fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Weather
  // ---------------------------------------------------------------------------

  @override
  Future<List<Weather>> getWeather(int sessionKey) {
    return _getList<Weather>(
      '$_baseUrl/weather?session_key=$sessionKey',
      Weather.fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // Race Control (Flags / Safety Car)
  // ---------------------------------------------------------------------------

  @override
  Future<List<RaceControlEvent>> getRaceControlEvents(int sessionKey) {
    return _getList<RaceControlEvent>(
      '$_baseUrl/race_control?session_key=$sessionKey',
      RaceControlEvent.fromJson,
    );
  }
}
