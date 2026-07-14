import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meeting.dart';
import '../theme/app_theme.dart';
import '../providers/countdown_provider.dart';
import '../providers/race_replay_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/countdown_card.dart';
import '../widgets/race_calendar_card.dart';
import '../widgets/session_schedule.dart';
import '../widgets/responsive_layout.dart';

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CountdownProvider>(
      builder: (context, provider, child) {
        return OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return ResponsiveLayout(
                phoneLayout: _PhoneLayout(provider: provider),
                tabletLayout: _TabletLayout(provider: provider),
              );
            } else {
              return ResponsiveLayout(
                phoneLayout: _PhoneLayout(provider: provider),
                tabletLayout: _TabletPortraitLayout(provider: provider),
              );
            }
          },
        );
      },
    );
  }
}

/// Shared handler: navigates to the Race Replay screen for completed races,
/// or shows a snack-bar for upcoming ones.
void _onMeetingTap(BuildContext context, Meeting meeting) {
  if (meeting.dateEnd.toUtc().isBefore(DateTime.now().toUtc())) {
    final replayProvider =
        Provider.of<RaceReplayProvider>(context, listen: false);
    replayProvider.loadYear(meeting.year);
    replayProvider.selectMeeting(meeting);
    Provider.of<NavigationProvider>(context, listen: false).setTab(1);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Replay will be available after the race weekend.'),
      ),
    );
  }
}

List<Meeting> _getCalendarMeetings(List<Meeting> allMeetings, Meeting? nextMeeting) {
  return allMeetings
      .where((m) => !m.meetingName.toLowerCase().contains('testing'))
      .toList();
}

// ---------------------------------------------------------------------------
// Phone Layout
// ---------------------------------------------------------------------------

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({required this.provider});

  final CountdownProvider provider;

  @override
  Widget build(BuildContext context) {
    final meetings = _getCalendarMeetings(provider.allMeetings, provider.nextMeeting);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.f1RedGradient.createShader(bounds),
              child: const Text(
                '2026 F1 COUNTDOWN',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Countdown to upcoming events...',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : provider.error != null
              ? _ErrorView(
                  error: provider.error!,
                  onRetry: provider.loadData,
                )
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (provider.nextMeeting != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: CountdownCard(
                            meeting: provider.nextMeeting!,
                            days: provider.countdownDays,
                            hours: provider.countdownHours,
                            minutes: provider.countdownMinutes,
                            seconds: provider.countdownSeconds,
                            sessions: provider.nextMeetingSessions,
                          ),
                        ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'RACE CALENDAR',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: meetings.length,
                          itemBuilder: (context, index) {
                            final meeting = meetings[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: RaceCalendarCard(
                                meeting: meeting,
                                onTap: () => _onMeetingTap(context, meeting),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet Layout
// ---------------------------------------------------------------------------

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.provider});

  final CountdownProvider provider;

  @override
  Widget build(BuildContext context) {
    final meetings = _getCalendarMeetings(provider.allMeetings, provider.nextMeeting);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.f1RedGradient.createShader(bounds),
              child: const Text(
                '2026 F1 COUNTDOWN',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Countdown to upcoming events...',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : provider.error != null
              ? _ErrorView(
                  error: provider.error!,
                  onRetry: provider.loadData,
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (provider.nextMeeting != null)
                                CountdownCard(
                                  meeting: provider.nextMeeting!,
                                  days: provider.countdownDays,
                                  hours: provider.countdownHours,
                                  minutes: provider.countdownMinutes,
                                  seconds: provider.countdownSeconds,
                                  sessions: provider.nextMeetingSessions,
                                ),
                              const SizedBox(height: 16),
                              if (provider.nextMeetingSessions.isNotEmpty)
                                SessionSchedule(
                                  sessions: provider.nextMeetingSessions,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'RACE CALENDAR',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.4,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: RaceCalendarListView(
                                  meetings: meetings,
                                  nextMeeting: provider.nextMeeting,
                                  onMeetingTap: _onMeetingTap,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet Portrait Layout
// ---------------------------------------------------------------------------

class _TabletPortraitLayout extends StatelessWidget {
  const _TabletPortraitLayout({required this.provider});

  final CountdownProvider provider;

  @override
  Widget build(BuildContext context) {
    final meetings = _getCalendarMeetings(provider.allMeetings, provider.nextMeeting);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.f1RedGradient.createShader(bounds),
              child: const Text(
                '2026 F1 COUNTDOWN',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Countdown to upcoming events...',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : provider.error != null
              ? _ErrorView(
                  error: provider.error!,
                  onRetry: provider.loadData,
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top row: Countdown card on left, Weekend schedule on right
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: provider.nextMeeting != null
                                  ? CountdownCard(
                                      meeting: provider.nextMeeting!,
                                      days: provider.countdownDays,
                                      hours: provider.countdownHours,
                                      minutes: provider.countdownMinutes,
                                      seconds: provider.countdownSeconds,
                                      sessions: provider.nextMeetingSessions,
                                    )
                                  : const SizedBox(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: provider.nextMeetingSessions.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'WEEKEND SCHEDULE',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.4,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SessionSchedule(
                                          sessions:
                                              provider.nextMeetingSessions,
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'RACE CALENDAR',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bottom scrollable calendar list
                        Expanded(
                          child: RaceCalendarListView(
                            meetings: meetings,
                            nextMeeting: provider.nextMeeting,
                            onMeetingTap: _onMeetingTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error View
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: AppTheme.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Race Calendar List View (Independent Scroll, exactly 4 visible, auto-scroll to next)
// ---------------------------------------------------------------------------

class RaceCalendarListView extends StatefulWidget {
  final List<Meeting> meetings;
  final Meeting? nextMeeting;
  final Function(BuildContext, Meeting) onMeetingTap;

  const RaceCalendarListView({
    super.key,
    required this.meetings,
    required this.nextMeeting,
    required this.onMeetingTap,
  });

  @override
  State<RaceCalendarListView> createState() => _RaceCalendarListViewState();
}

class _RaceCalendarListViewState extends State<RaceCalendarListView> {
  late final ScrollController _scrollController;
  bool _hasScrolledToNext = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant RaceCalendarListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nextMeeting?.meetingKey != oldWidget.nextMeeting?.meetingKey) {
      _hasScrolledToNext = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 450;
        final double itemHeight = useSingleColumn
            ? (constraints.maxWidth / 4.2)
            : (constraints.maxWidth / 2 / 2.8);
        final double itemSpacing = 8.0;
        final double rowHeight = itemHeight + itemSpacing;

        // Auto-scroll to center on next meeting (index - 2) once
        if (!_hasScrolledToNext) {
          final nextIndex = widget.meetings.indexWhere(
              (m) => m.meetingKey == widget.nextMeeting?.meetingKey);

          if (nextIndex != -1) {
            final int startIndex = useSingleColumn
                ? (nextIndex - 2).clamp(0, widget.meetings.length)
                : ((nextIndex - 2) ~/ 2).clamp(0, widget.meetings.length ~/ 2);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(startIndex * rowHeight);
                _hasScrolledToNext = true;
              }
            });
          }
        }

        // Limit height to fit exactly 4 rows (or 2 rows if 2 columns, to display 4 items total)
        final visibleRows = useSingleColumn ? 4 : 2;
        final viewportHeight = visibleRows * rowHeight;
        final height = constraints.maxHeight.isFinite ? constraints.maxHeight : viewportHeight;

        return SizedBox(
          height: height,
          child: GridView.builder(
            controller: _scrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: useSingleColumn ? 1 : 2,
              mainAxisSpacing: itemSpacing,
              crossAxisSpacing: itemSpacing,
              childAspectRatio: useSingleColumn ? 4.2 : 2.8,
            ),
            itemCount: widget.meetings.length,
            itemBuilder: (context, index) {
              final meeting = widget.meetings[index];
              return RaceCalendarCard(
                meeting: meeting,
                onTap: () => widget.onMeetingTap(context, meeting),
              );
            },
          ),
        );
      },
    );
  }
}
