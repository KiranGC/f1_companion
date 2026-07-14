import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/meeting.dart';
import '../models/session.dart';
import '../services/openf1_service.dart';

/// Provides countdown-to-next-race state and the full 2026 calendar.
///
/// On construction, call [loadData] to kick off the initial data fetch.
/// A 1-second periodic timer continuously recomputes the remaining time
/// until the next meeting's start date.
class CountdownProvider extends ChangeNotifier {
  final OpenF1Service _openF1Service;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// All meetings for the 2026 season, ordered by date.
  List<Meeting> _allMeetings = [];
  List<Meeting> get allMeetings => _allMeetings;

  /// The next upcoming meeting (first meeting whose `dateStart` is in the future).
  Meeting? _nextMeeting;
  Meeting? get nextMeeting => _nextMeeting;

  /// Sessions belonging to [nextMeeting] (FP1, FP2, …, Race).
  List<Session> _nextMeetingSessions = [];
  List<Session> get nextMeetingSessions => _nextMeetingSessions;

  // Countdown components.
  int _countdownDays = 0;
  int get countdownDays => _countdownDays;

  int _countdownHours = 0;
  int get countdownHours => _countdownHours;

  int _countdownMinutes = 0;
  int get countdownMinutes => _countdownMinutes;

  int _countdownSeconds = 0;
  int get countdownSeconds => _countdownSeconds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Timer? _timer;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  CountdownProvider(this._openF1Service);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches 2026 meetings and sessions, determines the next meeting, and
  /// starts the countdown timer.
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all 2026 meetings.
      final meetings = await _openF1Service.getMeetings(2026);

      // Sort chronologically (should already be, but be safe).
      meetings.sort((a, b) => a.dateStart.compareTo(b.dateStart));
      _allMeetings = meetings;

      // Find the next upcoming meeting.
      final now = DateTime.now();
      _nextMeeting = meetings.cast<Meeting?>().firstWhere(
            (m) => m!.dateStart.isAfter(now),
            orElse: () => null,
          );

      // Fetch sessions for the next meeting.
      if (_nextMeeting != null) {
        final sessions =
            await _openF1Service.getSessions(_nextMeeting!.meetingKey);
        sessions.sort((a, b) => a.dateStart.compareTo(b.dateStart));
        _nextMeetingSessions = sessions;
      } else {
        _nextMeetingSessions = [];
      }

      // Compute initial countdown and start the periodic timer.
      _updateCountdown();
      startTimer();
    } catch (e) {
      _error = 'Failed to load race calendar: $e';
      debugPrint('CountdownProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Timer
  // ---------------------------------------------------------------------------

  void startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateCountdown() {
    if (_nextMeeting == null) {
      _countdownDays = 0;
      _countdownHours = 0;
      _countdownMinutes = 0;
      _countdownSeconds = 0;
      return;
    }

    final remaining = _nextMeeting!.dateStart.difference(DateTime.now());

    if (remaining.isNegative) {
      _countdownDays = 0;
      _countdownHours = 0;
      _countdownMinutes = 0;
      _countdownSeconds = 0;
      return;
    }

    _countdownDays = remaining.inDays;
    _countdownHours = remaining.inHours.remainder(24);
    _countdownMinutes = remaining.inMinutes.remainder(60);
    _countdownSeconds = remaining.inSeconds.remainder(60);
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
