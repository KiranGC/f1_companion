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
        return ResponsiveLayout(
          phoneLayout: _PhoneLayout(provider: provider),
          tabletLayout: _TabletLayout(provider: provider),
        );
      },
    );
  }
}

/// Shared handler: navigates to the Race Replay screen for completed races,
/// or shows a snack-bar for upcoming ones.
void _onMeetingTap(BuildContext context, Meeting meeting) {
  if (meeting.dateEnd.isBefore(DateTime.now())) {
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

/// Returns all meetings that are not pre-season testing events.
List<Meeting> _filteredMeetings(List<Meeting> all) =>
    all.where((m) => !m.meetingName.toLowerCase().contains('testing')).toList();

// ---------------------------------------------------------------------------
// Phone Layout
// ---------------------------------------------------------------------------

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({required this.provider});

  final CountdownProvider provider;

  @override
  Widget build(BuildContext context) {
    final meetings = _filteredMeetings(provider.allMeetings);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (provider.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (provider.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorView(
                error: provider.error!,
                onRetry: provider.loadData,
              ),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate([
                // Countdown card for the next race
                if (provider.nextMeeting != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: CountdownCard(
                      meeting: provider.nextMeeting!,
                      days: provider.countdownDays,
                      hours: provider.countdownHours,
                      minutes: provider.countdownMinutes,
                      seconds: provider.countdownSeconds,
                      sessions: provider.nextMeetingSessions,
                    ),
                  ),

                const SizedBox(height: 32),

                // Section header
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
                const SizedBox(height: 12),

                // List of all meetings (exclude pre-season testing)
                ...meetings.map(
                  (meeting) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: RaceCalendarCard(
                      meeting: meeting,
                      onTap: () => _onMeetingTap(context, meeting),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ]),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppTheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
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
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.background,
                AppTheme.surface.withValues(alpha: 0.95),
              ],
            ),
          ),
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
    final meetings = _filteredMeetings(provider.allMeetings);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (provider.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (provider.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorView(
                error: provider.error!,
                onRetry: provider.loadData,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left panel — countdown + session schedule
                    Expanded(
                      flex: 3,
                      child: Column(
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

                    // Right panel — race calendar grid
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final useSingleColumn = constraints.maxWidth < 450;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: useSingleColumn ? 1 : 2,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio:
                                      useSingleColumn ? 4.2 : 2.8,
                                ),
                                itemCount: meetings.length,
                                itemBuilder: (context, index) {
                                  final meeting = meetings[index];
                                  return RaceCalendarCard(
                                    meeting: meeting,
                                    onTap: () =>
                                        _onMeetingTap(context, meeting),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppTheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
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
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.background,
                AppTheme.surface.withValues(alpha: 0.95),
              ],
            ),
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
