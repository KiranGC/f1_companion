import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1_companion/providers/race_replay_provider.dart';
import 'package:f1_companion/services/openf1_service.dart';
import 'package:f1_companion/services/circuit_service.dart';
import 'package:f1_companion/models/meeting.dart';
import 'package:f1_companion/models/session.dart';
import 'package:f1_companion/models/driver.dart';
import 'package:f1_companion/models/car_location.dart';
import 'package:f1_companion/models/race_position.dart';
import 'package:f1_companion/models/interval_data.dart';
import 'package:f1_companion/models/lap.dart';
import 'package:f1_companion/models/stint.dart';
import 'package:f1_companion/models/weather.dart';
import 'package:f1_companion/models/race_control_event.dart';
import 'package:f1_companion/models/circuit_info.dart';

class MockOpenF1Service implements OpenF1Service {
  List<Meeting> mockMeetings = [];
  List<Session> mockSessions = [];
  List<Driver> mockDrivers = [];
  List<CarLocation> mockLocations = [];
  List<RacePosition> mockPositions = [];
  List<IntervalData> mockIntervals = [];
  List<Lap> mockLaps = [];
  List<Stint> mockStints = [];
  List<Weather> mockWeather = [];
  List<RaceControlEvent> mockRaceControlEvents = [];

  @override
  Future<List<Meeting>> getMeetings(int year) async => mockMeetings;
  @override
  Future<List<Session>> getSessions(int meetingKey) async => mockSessions;
  @override
  Future<List<Driver>> getDrivers(int sessionKey) async => mockDrivers;
  @override
  Future<List<CarLocation>> getAllDriverLocations({
    required int sessionKey,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async => mockLocations;
  @override
  Future<List<RacePosition>> getPositions(int sessionKey) async => mockPositions;
  @override
  Future<List<IntervalData>> getIntervals(int sessionKey) async => mockIntervals;
  @override
  Future<List<Lap>> getAllLaps(int sessionKey) async => mockLaps;
  @override
  Future<List<Stint>> getStints(int sessionKey) async => mockStints;
  @override
  Future<List<Weather>> getWeather(int sessionKey) async => mockWeather;
  @override
  Future<List<RaceControlEvent>> getRaceControlEvents(int sessionKey) async => mockRaceControlEvents;
}

class MockCircuitService implements CircuitService {
  CircuitInfo? mockCircuitInfo;

  @override
  Future<CircuitInfo?> getCircuitInfo(String circuitInfoUrl) async => mockCircuitInfo;
  @override
  Future<CircuitInfo?> getCircuitInfoByKey(int circuitKey, int year) async => mockCircuitInfo;
}

void main() {
  group('RaceReplayProvider Unit Tests', () {
    late MockOpenF1Service mockOpenF1;
    late MockCircuitService mockCircuit;
    late RaceReplayProvider provider;

    setUp(() {
      mockOpenF1 = MockOpenF1Service();
      mockCircuit = MockCircuitService();
      provider = RaceReplayProvider(mockOpenF1, mockCircuit);
    });

    test('getFallbackTotalLaps returns correct lap counts', () {
      expect(RaceReplayProvider.getFallbackTotalLaps('Monaco', 'Race'), 78);
      expect(RaceReplayProvider.getFallbackTotalLaps('Monaco', 'Sprint'), 27); // 78 * 0.35 = 27.3 => 27
      expect(RaceReplayProvider.getFallbackTotalLaps('Bahrain', 'Race'), 57);
      expect(RaceReplayProvider.getFallbackTotalLaps('Unknown', 'Race'), 50); // fallback
    });

    test('Session selection and track flag color detection', () async {
      final now = DateTime.now().toUtc();
      final session = Session.fromJson({
        'session_key': 1,
        'session_name': 'Race',
        'session_type': 'Race',
        'date_start': now.toIso8601String(),
        'date_end': now.add(const Duration(hours: 2)).toIso8601String(),
        'meeting_key': 123,
        'circuit_key': 4,
        'circuit_short_name': 'Sakhir',
        'country_key': 2,
        'country_code': 'BHR',
        'country_name': 'Bahrain',
        'location': 'Sakhir',
        'gmt_offset': '03:00:00',
        'year': 2023,
        'is_cancelled': false,
      });

      mockOpenF1.mockDrivers = [
        Driver.fromJson({
          'meeting_key': 123,
          'session_key': 1,
          'driver_number': 1,
          'broadcast_name': 'M VERSTAPPEN',
          'full_name': 'Max Verstappen',
          'name_acronym': 'VER',
          'team_name': 'Red Bull Racing',
          'team_colour': '0000FF',
          'first_name': 'Max',
          'last_name': 'Verstappen'
        }),
        Driver.fromJson({
          'meeting_key': 123,
          'session_key': 1,
          'driver_number': 44,
          'broadcast_name': 'L HAMILTON',
          'full_name': 'Lewis Hamilton',
          'name_acronym': 'HAM',
          'team_name': 'Mercedes',
          'team_colour': '00FFFF',
          'first_name': 'Lewis',
          'last_name': 'Hamilton'
        }),
      ];

      mockOpenF1.mockRaceControlEvents = [
        RaceControlEvent.fromJson({
          'category': 'Flag',
          'date': now.add(const Duration(minutes: 5)).toIso8601String(),
          'flag': 'YELLOW',
          'message': 'YELLOW FLAG',
          'meeting_key': 123,
          'session_key': 1,
        }),
        RaceControlEvent.fromJson({
          'category': 'Flag',
          'date': now.add(const Duration(minutes: 10)).toIso8601String(),
          'flag': 'GREEN',
          'message': 'GREEN FLAG',
          'meeting_key': 123,
          'session_key': 1,
        }),
        RaceControlEvent.fromJson({
          'category': 'Flag',
          'date': now.add(const Duration(minutes: 15)).toIso8601String(),
          'flag': 'RED',
          'message': 'RED FLAG',
          'meeting_key': 123,
          'session_key': 1,
        }),
      ];

      await provider.selectSession(session);

      expect(provider.selectedSession, session);
      expect(provider.playbackTime, session.dateStart);
      expect(provider.getTrackStatusColor(), Colors.white); // Initially white (Green flag or not set)

      // Seek to 5 minutes after start (should turn yellow)
      provider.seekTo(5 / 120); // 5 minutes / 120 minutes
      expect(provider.getTrackStatusColor(), Colors.yellow);

      // Seek to 11 minutes after start (should be back to green / white)
      provider.seekTo(11 / 120);
      expect(provider.getTrackStatusColor(), Colors.white);

      // Seek to 20 minutes after start (should be red)
      provider.seekTo(20 / 120);
      expect(provider.getTrackStatusColor(), Colors.red);
    });

    test('Leaderboard generation and stint tires / pit-stop counts', () async {
      final now = DateTime.now().toUtc();
      final session = Session.fromJson({
        'session_key': 1,
        'session_name': 'Race',
        'session_type': 'Race',
        'date_start': now.toIso8601String(),
        'date_end': now.add(const Duration(hours: 2)).toIso8601String(),
        'meeting_key': 123,
        'circuit_key': 4,
        'circuit_short_name': 'Sakhir',
        'country_key': 2,
        'country_code': 'BHR',
        'country_name': 'Bahrain',
        'location': 'Sakhir',
        'gmt_offset': '03:00:00',
        'year': 2023,
        'is_cancelled': false,
      });

      mockOpenF1.mockDrivers = [
        Driver.fromJson({
          'meeting_key': 123,
          'session_key': 1,
          'driver_number': 1,
          'broadcast_name': 'M VERSTAPPEN',
          'full_name': 'Max Verstappen',
          'name_acronym': 'VER',
          'team_name': 'Red Bull Racing',
          'team_colour': '0000FF',
          'first_name': 'Max',
          'last_name': 'Verstappen'
        }),
        Driver.fromJson({
          'meeting_key': 123,
          'session_key': 1,
          'driver_number': 44,
          'broadcast_name': 'L HAMILTON',
          'full_name': 'Lewis Hamilton',
          'name_acronym': 'HAM',
          'team_name': 'Mercedes',
          'team_colour': '00FFFF',
          'first_name': 'Lewis',
          'last_name': 'Hamilton'
        }),
      ];

      mockOpenF1.mockPositions = [
        RacePosition.fromJson({
          'date': now.toIso8601String(),
          'session_key': 1,
          'meeting_key': 123,
          'driver_number': 1,
          'position': 1,
        }),
        RacePosition.fromJson({
          'date': now.toIso8601String(),
          'session_key': 1,
          'meeting_key': 123,
          'driver_number': 44,
          'position': 2,
        }),
      ];

      mockOpenF1.mockStints = [
        Stint.fromJson({
          'meeting_key': 123,
          'session_key': 1,
          'stint_number': 1,
          'driver_number': 1,
          'lap_start': 1,
          'lap_end': 15,
          'compound': 'SOFT',
          'tyre_age_at_start': 0,
        }),
        Stint.fromJson({
          'meeting_key': 123,
          'session_key': 1,
          'stint_number': 2,
          'driver_number': 1,
          'lap_start': 16,
          'lap_end': 57,
          'compound': 'HARD',
          'tyre_age_at_start': 0,
        }),
        Stint.fromJson({
          'meeting_key': 123,
          'session_key': 1,
          'stint_number': 1,
          'driver_number': 44,
          'lap_start': 1,
          'lap_end': 57,
          'compound': 'MEDIUM',
          'tyre_age_at_start': 0,
        }),
      ];

      await provider.selectSession(session);

      final leaderboard = provider.getLeaderboard();
      expect(leaderboard.length, 2);

      // VER is P1, HAM is P2
      expect(leaderboard[0].driverNumber, 1);
      expect(leaderboard[0].position, 1);
      expect(leaderboard[0].currentCompound, 'SOFT');
      expect(leaderboard[0].pitStops, 0); // stintNumber 2 starts on Lap 16, so 0 stops on Lap 1

      expect(leaderboard[1].driverNumber, 44);
      expect(leaderboard[1].position, 2);
      expect(leaderboard[1].currentCompound, 'MEDIUM');
      expect(leaderboard[1].pitStops, 0); // stintNumber 1 - 1 = 0
    });

    test('Lapped cars formatting and isRaceOver detection', () async {
      final now = DateTime.now().toUtc();
      final session = Session.fromJson({
        'session_key': 1,
        'meeting_key': 123,
        'session_name': 'Race',
        'session_type': 'Race',
        'date_start': now.toIso8601String(),
        'date_end': now.add(const Duration(hours: 2)).toIso8601String(),
        'location': 'Suzuka',
        'country_name': 'Japan',
        'country_code': 'JPN',
        'country_key': 6,
        'circuit_key': 6,
        'circuit_short_name': 'Suzuka',
        'gmt_offset': '09:00:00',
        'year': 2026,
      });

      mockOpenF1.mockDrivers = [
        Driver.fromJson({
          'meeting_key': 123,
          'session_key': 1,
          'driver_number': 1,
          'broadcast_name': 'M VERSTAPPEN',
          'full_name': 'Max Verstappen',
          'name_acronym': 'VER',
          'team_name': 'Red Bull Racing',
          'team_colour': '0000FF',
          'first_name': 'Max',
          'last_name': 'Verstappen'
        }),
        Driver.fromJson({
          'meeting_key': 123,
          'session_key': 1,
          'driver_number': 44,
          'broadcast_name': 'L HAMILTON',
          'full_name': 'Lewis Hamilton',
          'name_acronym': 'HAM',
          'team_name': 'Mercedes',
          'team_colour': '00FFFF',
          'first_name': 'Lewis',
          'last_name': 'Hamilton'
        }),
      ];

      mockOpenF1.mockPositions = [
        RacePosition.fromJson({
          'date': now.toIso8601String(),
          'session_key': 1,
          'meeting_key': 123,
          'driver_number': 1,
          'position': 1,
        }),
        RacePosition.fromJson({
          'date': now.toIso8601String(),
          'session_key': 1,
          'meeting_key': 123,
          'driver_number': 44,
          'position': 2,
        }),
      ];

      mockOpenF1.mockIntervals = [
        IntervalData.fromJson({
          'date': now.toIso8601String(),
          'session_key': 1,
          'meeting_key': 123,
          'driver_number': 44,
          'gap_to_leader': '+1 LAP',
          'interval': '+1 LAP',
        }),
      ];

      mockOpenF1.mockRaceControlEvents = [
        RaceControlEvent.fromJson({
          'category': 'Flag',
          'date': now.add(const Duration(hours: 1, minutes: 30)).toIso8601String(),
          'meeting_key': 123,
          'session_key': 1,
          'flag': 'CHEQUERED',
          'message': 'CHEQUERED FLAG',
        }),
      ];

      await provider.selectSession(session);

      // Verify lapped formatting at Lap 1
      final leaderboard = provider.getLeaderboard();
      expect(leaderboard[1].gapToLeaderDisplay, '+1 Lap');

      // Verify isRaceOver is false at start
      expect(provider.isRaceOver(), false);

      // Seek past checkered flag time and verify isRaceOver becomes true
      provider.seekTo(0.8); // Advances playbackTime past checkered flag event
      expect(provider.isRaceOver(), true);
    });
  });
}
