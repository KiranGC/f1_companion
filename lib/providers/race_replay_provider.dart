import 'dart:async';

import 'package:flutter/material.dart';

import '../models/car_location.dart';
import '../models/circuit_info.dart';
import '../models/driver.dart';
import '../models/interval_data.dart';
import '../models/meeting.dart';
import '../models/race_position.dart';
import '../models/session.dart';
import '../models/stint.dart';
import '../models/weather.dart';
import '../models/race_control_event.dart';
import '../models/lap.dart';
import '../services/circuit_service.dart';
import '../services/openf1_service.dart';

// =============================================================================
// Lightweight helper types
// =============================================================================

/// A simple 2D point used for driver positions on the track map.
class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  @override
  String toString() => 'Point($x, $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// A single row in the leaderboard table.
class LeaderboardEntry {
  final int position;
  final int driverNumber;
  final String nameAcronym;
  final String teamName;
  final String teamColour;
  final double? gapToLeader;
  final String? gapToLeaderDisplay;
  final double? interval;
  final String? currentCompound;
  final int pitStops;
  final double? lastLapTime;
  final bool isRetired;

  const LeaderboardEntry({
    required this.position,
    required this.driverNumber,
    required this.nameAcronym,
    required this.teamName,
    required this.teamColour,
    this.gapToLeader,
    this.gapToLeaderDisplay,
    this.interval,
    this.currentCompound,
    this.pitStops = 0,
    this.lastLapTime,
    this.isRetired = false,
  });

  @override
  String toString() =>
      'LeaderboardEntry(P$position $nameAcronym gap:$gapToLeader retired:$isRetired)';
}

// =============================================================================
// Provider
// =============================================================================

/// Manages state for the race replay feature.
///
/// Uses a **two-tier timing architecture**:
/// 1. **Animation timer** (16 ms / ~60 fps) — advances [playbackTime] and
///    interpolates driver positions for smooth rendering.
/// 2. **API fetch timer** (user-configurable, 1 s – 60 s) — polls OpenF1 for
///    the next batch of location data around the current playback window.
class RaceReplayProvider extends ChangeNotifier {
  final OpenF1Service _openF1Service;
  final CircuitService _circuitService;

  // ---------------------------------------------------------------------------
  // Selection state
  // ---------------------------------------------------------------------------

  int _selectedYear = 2026;
  int get selectedYear => _selectedYear;

  Meeting? _selectedMeeting;
  Meeting? get selectedMeeting => _selectedMeeting;

  Session? _selectedSession;
  Session? get selectedSession => _selectedSession;

  List<Meeting> _availableMeetings = [];
  List<Meeting> get availableMeetings => _availableMeetings;

  List<Session> _availableRaceSessions = [];
  List<Session> get availableRaceSessions => _availableRaceSessions;

  // ---------------------------------------------------------------------------
  // Session data (loaded once per session selection)
  // ---------------------------------------------------------------------------

  List<Driver> _drivers = [];
  List<Driver> get drivers => _drivers;

  CircuitInfo? _circuitInfo;
  CircuitInfo? get circuitInfo => _circuitInfo;

  List<RacePosition> _positions = [];
  List<RacePosition> get positions => _positions;

  List<IntervalData> _intervals = [];
  List<IntervalData> get intervals => _intervals;

  List<Stint> _stints = [];
  List<Stint> get stints => _stints;

  List<Weather> _weatherData = [];
  List<Weather> get weatherData => _weatherData;

  List<RaceControlEvent> _raceControlEvents = [];
  List<RaceControlEvent> get raceControlEvents => _raceControlEvents;

  List<Lap> _laps = [];
  List<Lap> get laps => _laps;

  // ---------------------------------------------------------------------------
  // Location cache — driverNumber → list of CarLocation sorted by date
  // ---------------------------------------------------------------------------

  Map<int, List<CarLocation>> _locationCache = {};
  Map<int, List<CarLocation>> get locationCache => _locationCache;

  // ---------------------------------------------------------------------------
  // Playback state
  // ---------------------------------------------------------------------------

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  static const List<double> availableSpeeds = [0.5, 1, 2, 5, 10, 20];

  DateTime? _playbackTime;
  DateTime? get playbackTime => _playbackTime;

  DateTime? _sessionStart;
  DateTime? get sessionStart => _sessionStart;

  DateTime? _sessionEnd;
  DateTime? get sessionEnd => _sessionEnd;

  int _apiRefreshIntervalSeconds = 5;
  int get apiRefreshIntervalSeconds => _apiRefreshIntervalSeconds;

  int _currentLap = 0;
  int get currentLap => _currentLap;

  int _totalLaps = 0;
  int get totalLaps => _totalLaps;

  // ---------------------------------------------------------------------------
  // Loading / error
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingLocation = false;

  bool get hasTelemetry => _locationCache.isNotEmpty && _locationCache.values.any((list) => list.isNotEmpty);

  String? _error;
  String? get error => _error;

  // ---------------------------------------------------------------------------
  // Timers
  // ---------------------------------------------------------------------------

  Timer? _animationTimer;
  Timer? _apiFetchTimer;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  RaceReplayProvider(this._openF1Service, this._circuitService);

  // ---------------------------------------------------------------------------
  // Year / meeting / session selection
  // ---------------------------------------------------------------------------

  /// Loads all meetings for [year] and resets downstream state.
  Future<void> loadYear(int year) async {
    _selectedYear = year;
    _selectedMeeting = null;
    _selectedSession = null;
    _availableRaceSessions = [];
    _clearSessionData();
    _stopPlayback();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final meetings = await _openF1Service.getMeetings(year);
      meetings.sort((a, b) => a.dateStart.compareTo(b.dateStart));
      _availableMeetings = meetings;
    } catch (e) {
      _error = 'Failed to load meetings for $year: $e';
      debugPrint('RaceReplayProvider.loadYear: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a meeting and loads its race / sprint sessions.
  Future<void> selectMeeting(Meeting meeting) async {
    _selectedMeeting = meeting;
    _selectedSession = null;
    _clearSessionData();
    _stopPlayback();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sessions = await _openF1Service.getSessions(meeting.meetingKey);
      // Keep only Race + Sprint sessions for the replay picker.
      _availableRaceSessions = sessions
          .where((s) =>
              s.sessionType == 'Race' || s.sessionType == 'Sprint')
          .toList()
        ..sort((a, b) => a.dateStart.compareTo(b.dateStart));

      // Auto-select the main Race session and load it
      final raceSession = _availableRaceSessions.where(
        (s) => s.sessionName == 'Race',
      );
      if (raceSession.isNotEmpty) {
        await selectSession(raceSession.first);
      }
    } catch (e) {
      _error = 'Failed to load sessions: $e';
      debugPrint('RaceReplayProvider.selectMeeting: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a session and loads all associated data (drivers, circuit,
  /// positions, intervals, stints, weather).
  Future<void> selectSession(Session session) async {
    _selectedSession = session;
    _clearSessionData();
    _stopPlayback();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Parallel fetch of session-level data.
      final results = await Future.wait([
        _openF1Service.getDrivers(session.sessionKey),      // 0
        _openF1Service.getPositions(session.sessionKey),     // 1
        _openF1Service.getIntervals(session.sessionKey),     // 2
        _openF1Service.getStints(session.sessionKey),        // 3
        _openF1Service.getWeather(session.sessionKey),       // 4
        _openF1Service.getRaceControlEvents(session.sessionKey), // 5
        _openF1Service.getAllLaps(session.sessionKey),       // 6
      ]);

      _drivers = results[0] as List<Driver>;
      _positions = results[1] as List<RacePosition>;
      _intervals = results[2] as List<IntervalData>;
      _stints = results[3] as List<Stint>;
      _weatherData = results[4] as List<Weather>;
      _raceControlEvents = results[5] as List<RaceControlEvent>;
      _laps = results[6] as List<Lap>;

      // Sort positions, intervals, and race control events chronologically.
      _positions.sort((a, b) => a.date.compareTo(b.date));
      _intervals.sort((a, b) => a.date.compareTo(b.date));
      _raceControlEvents.sort((a, b) => a.date.compareTo(b.date));

      // Compute total laps from laps, falling back to stints.
      if (_laps.isNotEmpty) {
        _totalLaps = _laps.map((l) => l.lapNumber).fold(0, (max, val) => val > max ? val : max);
      } else if (_stints.isNotEmpty) {
        _totalLaps = _stints.map((s) => s.lapEnd).fold(0, (max, val) => val > max ? val : max);
      }

      if (_totalLaps == 0) {
        _totalLaps = getFallbackTotalLaps(session.location, session.sessionType);
      }

      // Fetch circuit outline.
      if (_selectedMeeting != null &&
          _selectedMeeting!.circuitInfoUrl.isNotEmpty) {
        _circuitInfo = await _circuitService
            .getCircuitInfo(_selectedMeeting!.circuitInfoUrl);
      }

      _sessionStart = session.dateStart;
      _sessionEnd = session.dateEnd;
      _playbackTime = _sessionStart;
      _currentLap = 1;

      // Fetch initial locations batch.
      await _fetchLocationBatch();
    } catch (e) {
      _error = 'Failed to load session data: $e';
      debugPrint('RaceReplayProvider.selectSession: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Playback controls
  // ---------------------------------------------------------------------------

  /// Starts playback — begins both the animation and API-fetch timers.
  void play() {
    if (_playbackTime == null || _sessionEnd == null) return;
    _isPlaying = true;

    // Animation timer: ~60 fps for smooth driver-dot interpolation.
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _onAnimationTick(),
    );

    // API fetch timer: user-configurable polling rate.
    _startApiFetchTimer();

    notifyListeners();
  }

  /// Pauses playback — cancels both timers but preserves the current position.
  void pause() {
    _isPlaying = false;
    _animationTimer?.cancel();
    _apiFetchTimer?.cancel();
    notifyListeners();
  }

  /// Toggles between [play] and [pause].
  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// Sets the playback speed multiplier. Must be one of [availableSpeeds].
  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  /// Seeks to a fractional position in the session (0.0 = start, 1.0 = end).
  void seekTo(double fraction) {
    if (_sessionStart == null || _sessionEnd == null) return;
    final totalDuration = _sessionEnd!.difference(_sessionStart!);
    final offset = totalDuration * fraction;
    _playbackTime = _sessionStart!.add(offset);

    // Update current lap immediately upon seeking.
    _updateCurrentLap();

    // Immediately fetch a location batch around the new position.
    _fetchLocationBatch();

    notifyListeners();
  }

  /// Updates the API polling interval (in seconds, clamped to 1–60).
  void setApiRefreshInterval(int seconds) {
    _apiRefreshIntervalSeconds = seconds.clamp(1, 60);

    // Restart the API timer if currently playing.
    if (_isPlaying) {
      _startApiFetchTimer();
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Animation tick (~60 fps)
  // ---------------------------------------------------------------------------

  void _onAnimationTick() {
    if (_playbackTime == null || _sessionEnd == null) return;

    // Advance playback time by (16 ms × playbackSpeed).
    final advance = Duration(
      microseconds: (16000 * _playbackSpeed).round(),
    );
    _playbackTime = _playbackTime!.add(advance);

    // Clamp to session end.
    if (_playbackTime!.isAfter(_sessionEnd!)) {
      _playbackTime = _sessionEnd;
      pause();
      return;
    }

    // Update current lap from position data.
    _updateCurrentLap();

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // API data fetch
  // ---------------------------------------------------------------------------

  void _startApiFetchTimer() {
    _apiFetchTimer?.cancel();
    _apiFetchTimer = Timer.periodic(
      Duration(seconds: _apiRefreshIntervalSeconds),
      (_) => _fetchLocationBatch(),
    );
    // Also fetch immediately.
    _fetchLocationBatch();
  }

  /// Fetches a window of location data around the current [playbackTime]
  /// and caches it per-driver.
  Future<void> _fetchLocationBatch() async {
    if (_selectedSession == null || _playbackTime == null) return;
    if (_isFetchingLocation) return;
    _isFetchingLocation = true;

    try {
      // Fetch a window: current playbackTime ± 30 seconds × playbackSpeed,
      // but at least ± 10 seconds.
      final windowHalf = Duration(
        seconds: (30 * _playbackSpeed).clamp(10, 300).round(),
      );
      final windowStart = _playbackTime!.subtract(windowHalf);
      final windowEnd = _playbackTime!.add(windowHalf);

      final locations = await _openF1Service.getAllDriverLocations(
        sessionKey: _selectedSession!.sessionKey,
        dateStart: windowStart,
        dateEnd: windowEnd,
      );

      // Group by driver number.
      final Map<int, List<CarLocation>> grouped = {};
      for (final loc in locations) {
        grouped.putIfAbsent(loc.driverNumber, () => []).add(loc);
      }

      // Sort each driver's locations and merge into cache.
      for (final entry in grouped.entries) {
        entry.value.sort((a, b) => a.date.compareTo(b.date));
        _locationCache[entry.key] = entry.value;
      }
    } catch (e) {
      debugPrint('RaceReplayProvider._fetchLocationBatch: $e');
    } finally {
      _isFetchingLocation = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Derived data for the UI
  // ---------------------------------------------------------------------------

  /// Returns the current interpolated (x, y) position for each driver.
  ///
  /// The map is keyed by driver number. Positions are linearly interpolated
  /// between the two nearest cached [CarLocation] samples surrounding
  /// [playbackTime].
  Map<int, Point> getCurrentDriverPositions() {
    final result = <int, Point>{};
    if (_playbackTime == null) return result;

    for (final entry in _locationCache.entries) {
      final driverNumber = entry.key;
      final locations = entry.value;
      if (locations.isEmpty) continue;

      // Only display active drivers who are in the official list and have not retired
      final hasDriverInfo = _drivers.any((d) => d.driverNumber == driverNumber);
      if (!hasDriverInfo || isDriverRetired(driverNumber)) {
        continue;
      }

      // Binary-search for the closest samples.
      final pt = _interpolatePosition(locations, _playbackTime!);
      if (pt != null) {
        result[driverNumber] = pt;
      }
    }

    return result;
  }

  /// Builds a sorted leaderboard from the latest position/interval/stint data
  /// at or before [playbackTime].
  List<LeaderboardEntry> getLeaderboard() {
    if (_playbackTime == null || _drivers.isEmpty) return [];

    // Build driver lookup.
    final driverMap = <int, Driver>{};
    for (final d in _drivers) {
      driverMap[d.driverNumber] = d;
    }

    // Find latest position per driver at or before playbackTime.
    final latestPositions = <int, RacePosition>{};
    for (final p in _positions) {
      if (p.date.isAfter(_playbackTime!)) continue;
      final existing = latestPositions[p.driverNumber];
      if (existing == null || p.date.isAfter(existing.date)) {
        latestPositions[p.driverNumber] = p;
      }
    }

    // Find latest interval per driver.
    final latestIntervals = <int, IntervalData>{};
    for (final iv in _intervals) {
      if (iv.date.isAfter(_playbackTime!)) continue;
      final existing = latestIntervals[iv.driverNumber];
      if (existing == null || iv.date.isAfter(existing.date)) {
        latestIntervals[iv.driverNumber] = iv;
      }
    }

    // Find current compound and pit-stop count per driver.
    // pitStops = stintNumber - 1 (first stint has no pit stop).
    final currentCompound = <int, String>{};
    final pitStopCount = <int, int>{};
    for (final s in _stints) {
      final d = s.driverNumber;
      // Only consider stints that have actually started by currentLap
      if (s.lapStart <= _currentLap) {
        final stops = s.stintNumber - 1;
        if (stops > (pitStopCount[d] ?? 0)) {
          pitStopCount[d] = stops;
        }
        currentCompound[d] = s.compound ?? '';
      }
    }

    // Find latest completed lap per driver to get last lap duration.
    final latestLaps = <int, Lap>{};
    for (final lap in _laps) {
      if (lap.dateStart != null && lap.dateStart!.isAfter(_playbackTime!)) continue;
      final duration = lap.lapDuration ?? lap.totalSectorDuration;
      if (duration == null) continue;
      final existing = latestLaps[lap.driverNumber];
      if (existing == null || lap.lapNumber > existing.lapNumber) {
        latestLaps[lap.driverNumber] = lap;
      }
    }

    // Assemble entries.
    final entries = <LeaderboardEntry>[];
    for (final posEntry in latestPositions.entries) {
      final driverNum = posEntry.key;
      final driver = driverMap[driverNum];
      if (driver == null) continue;

      final iv = latestIntervals[driverNum];
      final isRetired = isDriverRetired(driverNum);

      double? lastLapTime = latestLaps[driverNum] != null
          ? (latestLaps[driverNum]!.lapDuration ?? latestLaps[driverNum]!.totalSectorDuration)
          : null;

      if (lastLapTime == null && _currentLap > 1) {
        lastLapTime = getReferenceLapDuration(_currentLap - 1);
        if (lastLapTime == null) {
          final fallbackLaps = _laps
              .where((l) => l.lapNumber == _currentLap - 1)
              .map((l) => l.lapDuration ?? l.totalSectorDuration)
              .whereType<double>()
              .toList();
          if (fallbackLaps.isNotEmpty) {
            fallbackLaps.sort();
            lastLapTime = fallbackLaps[fallbackLaps.length ~/ 2];
          }
        }
      }

      String? gapToLeaderDisplay;
      if (isRetired) {
        gapToLeaderDisplay = 'Out';
      } else if (posEntry.value.position == 1) {
        gapToLeaderDisplay = 'Leader';
      } else if (iv != null) {
        final rawGap = iv.gapToLeaderDisplay;
        if (rawGap != null) {
          if (rawGap.toUpperCase().contains('LAP')) {
            final normalized = rawGap.toUpperCase().replaceAll('LAPS', 'Laps').replaceAll('LAP', 'Lap');
            gapToLeaderDisplay = normalized.startsWith('+') ? normalized : '+$normalized';
          } else {
            final val = double.tryParse(rawGap);
            if (val != null) {
              gapToLeaderDisplay = '+${val.toStringAsFixed(3)}';
            } else {
              gapToLeaderDisplay = rawGap;
            }
          }
        }
      }

      entries.add(LeaderboardEntry(
        position: posEntry.value.position,
        driverNumber: driverNum,
        nameAcronym: driver.nameAcronym,
        teamName: driver.teamName,
        teamColour: driver.teamColour,
        gapToLeader: iv?.gapToLeader,
        gapToLeaderDisplay: gapToLeaderDisplay,
        interval: iv?.interval,
        currentCompound: currentCompound[driverNum],
        pitStops: pitStopCount[driverNum] ?? 0,
        lastLapTime: lastLapTime,
        isRetired: isRetired,
      ));
    }

    entries.sort((a, b) {
      final aRetired = a.isRetired;
      final bRetired = b.isRetired;
      if (aRetired && !bRetired) return 1;
      if (!aRetired && bRetired) return -1;
      return a.position.compareTo(b.position);
    });
    return entries;
  }

  /// Calculates a reference lap duration for [lapNumber] based on the difference
  /// between the earliest start time of that lap and the earliest start time of
  /// the next lap across all drivers.
  double? getReferenceLapDuration(int lapNumber) {
    if (lapNumber < 1 || _laps.isEmpty) return null;

    DateTime? startCurrent;
    for (final l in _laps) {
      if (l.lapNumber == lapNumber && l.dateStart != null) {
        if (startCurrent == null || l.dateStart!.isBefore(startCurrent)) {
          startCurrent = l.dateStart;
        }
      }
    }

    DateTime? startNext;
    for (final l in _laps) {
      if (l.lapNumber == lapNumber + 1 && l.dateStart != null) {
        if (startNext == null || l.dateStart!.isBefore(startNext)) {
          startNext = l.dateStart;
        }
      }
    }

    if (startCurrent != null && startNext != null) {
      final diff = startNext.difference(startCurrent).inMilliseconds / 1000.0;
      // Sanity check: F1 race lap times are typically between 60.0 and 300.0 seconds
      if (diff > 50.0 && diff < 300.0) {
        return diff;
      }
    }
    return null;
  }

  /// Checks if a driver has retired/crashed by the current [playbackTime].
  bool isDriverRetired(int driverNumber) {
    if (_playbackTime == null || _laps.isEmpty) return false;

    // Find all laps for this driver
    final driverLaps = _laps.where((l) => l.driverNumber == driverNumber).toList();
    if (driverLaps.isEmpty) return false;

    // Find the max lap number this driver ever started/finished in this session
    final maxLapNum = driverLaps.map((l) => l.lapNumber).fold(0, (max, val) => val > max ? val : max);

    // If they completed the full race distance (or within 2 laps of the max race lap), they didn't retire
    // (they just finished the race, maybe a lap down).
    if (maxLapNum >= _totalLaps - 2) return false;

    // Find the last lap record for this driver
    final lastLap = driverLaps.firstWhere((l) => l.lapNumber == maxLapNum);
    if (lastLap.dateStart == null) {
      // Find the earliest valid lap start time across any driver (race start)
      DateTime? raceStart;
      for (final l in _laps) {
        if (l.dateStart != null) {
          if (raceStart == null || l.dateStart!.isBefore(raceStart)) {
            raceStart = l.dateStart;
          }
        }
      }
      if (raceStart != null) {
        // If we are past the start of the race, they are retired
        return _playbackTime!.isAfter(raceStart);
      }
      return false;
    }

    // If playbackTime is after the start of their last lap + its duration (or a default of 2 minutes if duration is null),
    // then they have retired.
    final durationSec = lastLap.lapDuration ?? lastLap.totalSectorDuration ?? 120.0;
    final lastLapEnd = lastLap.dateStart!.add(Duration(microseconds: (durationSec * 1000000).round()));

    return _playbackTime!.isAfter(lastLapEnd);
  }

  /// Checks if the race is completed (checkered flag waved) at or before the current [playbackTime].
  bool isRaceOver() {
    if (_playbackTime == null || _raceControlEvents.isEmpty) {
      return false;
    }

    for (final event in _raceControlEvents) {
      if (event.date.isAfter(_playbackTime!)) break;

      final flag = event.flag?.toUpperCase() ?? '';
      final msg = event.message.toUpperCase();

      if (flag == 'CHECKERED' || msg.contains('CHECKERED') || msg.contains('SESSION STATUS: ENDED')) {
        return true;
      }
    }
    return false;
  }

  /// Returns the current track flag color based on race control events at or
  /// before [playbackTime].
  ///
  /// Returns:
  /// - `Colors.red`    for RED FLAG
  /// - `Colors.yellow` for YELLOW / DOUBLE YELLOW / VSC / Safety Car
  /// - `Colors.white`  otherwise (green / track clear)
  Color getTrackStatusColor() {
    if (_playbackTime == null || _raceControlEvents.isEmpty) {
      return Colors.white;
    }

    // Walk events in chronological order, updating flag state.
    // Events are pre-sorted in selectSession.
    String currentFlag = 'GREEN';
    for (final event in _raceControlEvents) {
      if (event.date.isAfter(_playbackTime!)) break;

      final flag = event.flag?.toUpperCase() ?? '';
      final msg = event.message.toUpperCase();

      if (flag == 'RED' || msg.contains('RED FLAG')) {
        currentFlag = 'RED';
      } else if (flag == 'YELLOW' ||
          flag == 'DOUBLE YELLOW' ||
          msg.contains('YELLOW FLAG') ||
          msg.contains('SAFETY CAR') ||
          msg.contains('VSC') ||
          msg.contains('VIRTUAL SAFETY CAR')) {
        currentFlag = 'YELLOW';
      } else if (flag == 'GREEN' ||
          msg.contains('GREEN FLAG') ||
          msg.contains('TRACK CLEAR') ||
          msg.contains('VSC ENDED') ||
          msg.contains('SAFETY CAR IN THIS LAP')) {
        currentFlag = 'GREEN';
      }
    }

    switch (currentFlag) {
      case 'RED':
        return Colors.red;
      case 'YELLOW':
        return Colors.yellow;
      default:
        return Colors.white;
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Linearly interpolates the (x, y) position from sorted [locations] at the
  /// given [time].
  Point? _interpolatePosition(List<CarLocation> locations, DateTime time) {
    if (locations.isEmpty) return null;

    // Before first sample → use the first sample.
    if (time.isBefore(locations.first.date) ||
        time.isAtSameMomentAs(locations.first.date)) {
      return Point(locations.first.x.toDouble(), locations.first.y.toDouble());
    }

    // After last sample → use the last sample.
    if (time.isAfter(locations.last.date)) {
      return Point(locations.last.x.toDouble(), locations.last.y.toDouble());
    }

    // Find the two surrounding samples.
    for (int i = 0; i < locations.length - 1; i++) {
      final a = locations[i];
      final b = locations[i + 1];
      if ((time.isAfter(a.date) || time.isAtSameMomentAs(a.date)) &&
          (time.isBefore(b.date) || time.isAtSameMomentAs(b.date))) {
        final totalMs = b.date.difference(a.date).inMicroseconds;
        if (totalMs == 0) return Point(a.x.toDouble(), a.y.toDouble());

        final elapsed = time.difference(a.date).inMicroseconds;
        final t = elapsed / totalMs;

        final x = a.x + (b.x - a.x) * t;
        final y = a.y + (b.y - a.y) * t;
        return Point(x, y);
      }
    }

    return Point(locations.last.x.toDouble(), locations.last.y.toDouble());
  }

  /// Updates [_currentLap] from lap telemetry or by time-interpolation.
  ///
  /// Uses the leader's lap entries (pre-fetched in [selectSession]) to find the
  /// current lap number in O(log n) via a binary search on the sorted list.
  /// Falls back to proportional time interpolation when no telemetry exists.
  void _updateCurrentLap() {
    if (_playbackTime == null) return;

    if (_laps.isNotEmpty) {
      int maxLap = 1;
      for (final lap in _laps) {
        if (lap.dateStart != null && lap.dateStart!.isAfter(_playbackTime!)) continue;
        if (lap.lapNumber > maxLap) maxLap = lap.lapNumber;
      }
      _currentLap = maxLap.clamp(1, _totalLaps > 0 ? _totalLaps : maxLap);
    } else if (_positions.isNotEmpty) {
      // Fallback: count leader position changes as lap boundaries.
      int lap = 0;
      int? leaderDriver;
      for (final p in _positions) {
        if (p.date.isAfter(_playbackTime!)) break;
        if (p.position == 1) {
          if (leaderDriver == null || p.driverNumber == leaderDriver) {
            leaderDriver = p.driverNumber;
            lap++;
          }
        }
      }
      _currentLap = lap.clamp(1, _totalLaps > 0 ? _totalLaps : lap);
    } else {
      // Final fallback: interpolate by elapsed time ratio.
      if (_sessionStart != null && _sessionEnd != null && _totalLaps > 0) {
        final totalMs = _sessionEnd!.difference(_sessionStart!).inMilliseconds;
        if (totalMs > 0) {
          final elapsedMs = _playbackTime!.difference(_sessionStart!).inMilliseconds;
          final pct = (elapsedMs / totalMs).clamp(0.0, 1.0);
          _currentLap = ((pct * _totalLaps).floor() + 1).clamp(1, _totalLaps);
        }
      }
    }
  }

  /// Returns the standard total lap count for an F1 circuit based on its location
  /// and session type (main Race vs Sprint).
  static int getFallbackTotalLaps(String location, String sessionType) {
    int raceLaps = 50;
    final loc = location.toLowerCase();
    if (loc.contains('monaco')) {
      raceLaps = 78;
    } else if (loc.contains('melbourne') || loc.contains('australia')) {
      raceLaps = 58;
    } else if (loc.contains('shanghai') || loc.contains('china')) {
      raceLaps = 56;
    } else if (loc.contains('sakhir') || loc.contains('bahrain')) {
      raceLaps = 57;
    } else if (loc.contains('suzuka') || loc.contains('japan')) {
      raceLaps = 53;
    } else if (loc.contains('jeddah') || loc.contains('saudi')) {
      raceLaps = 50;
    } else if (loc.contains('miami')) {
      raceLaps = 57;
    } else if (loc.contains('montreal') || loc.contains('canada')) {
      raceLaps = 70;
    } else if (loc.contains('barcelona') || loc.contains('catalunya') || loc.contains('spain')) {
      raceLaps = 66;
    } else if (loc.contains('spielberg') || loc.contains('austria')) {
      raceLaps = 71;
    } else if (loc.contains('silverstone') || loc.contains('great britain')) {
      raceLaps = 52;
    } else if (loc.contains('hungaroring') || loc.contains('hungary')) {
      raceLaps = 70;
    } else if (loc.contains('spa') || loc.contains('belgium')) {
      raceLaps = 44;
    } else if (loc.contains('zandvoort') || loc.contains('netherlands')) {
      raceLaps = 72;
    } else if (loc.contains('monza') || loc.contains('italy')) {
      raceLaps = 53;
    } else if (loc.contains('baku') || loc.contains('azerbaijan')) {
      raceLaps = 51;
    } else if (loc.contains('marina bay') || loc.contains('singapore')) {
      raceLaps = 62;
    } else if (loc.contains('austin') || loc.contains('united states') || loc.contains('cota')) {
      raceLaps = 56;
    } else if (loc.contains('mexico') || loc.contains('rodriguez')) {
      raceLaps = 71;
    } else if (loc.contains('interlagos') || loc.contains('brazil') || loc.contains('sao paulo')) {
      raceLaps = 71;
    } else if (loc.contains('las vegas')) {
      raceLaps = 50;
    } else if (loc.contains('yas marina') || loc.contains('abu dhabi')) {
      raceLaps = 58;
    } else if (loc.contains('lusail') || loc.contains('qatar')) {
      raceLaps = 57;
    }

    if (sessionType.toLowerCase() == 'sprint') {
      return (raceLaps * 0.35).round();
    }
    return raceLaps;
  }

  void _clearSessionData() {
    _drivers = [];
    _circuitInfo = null;
    _positions = [];
    _intervals = [];
    _stints = [];
    _weatherData = [];
    _raceControlEvents = [];
    _laps = [];
    _locationCache = {};
    _playbackTime = null;
    _sessionStart = null;
    _sessionEnd = null;
    _currentLap = 0;
    _totalLaps = 0;
  }

  void _stopPlayback() {
    _isPlaying = false;
    _animationTimer?.cancel();
    _apiFetchTimer?.cancel();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _animationTimer?.cancel();
    _apiFetchTimer?.cancel();
    super.dispose();
  }
}
