import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/race_replay_provider.dart';
import '../widgets/track_map.dart';
import '../widgets/driver_leaderboard.dart';
import '../widgets/playback_controls.dart';
import '../widgets/responsive_layout.dart';

class RaceReplayScreen extends StatefulWidget {
  const RaceReplayScreen({super.key});

  @override
  State<RaceReplayScreen> createState() => _RaceReplayScreenState();
}

class _RaceReplayScreenState extends State<RaceReplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RaceReplayProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                return _LandscapeLayout(provider: provider);
              }
              return ResponsiveLayout(
                phoneLayout: _PhoneLayout(provider: provider),
                tabletLayout: _TabletLayout(provider: provider),
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: Selector Row (Year + Race dropdowns)
// ---------------------------------------------------------------------------

class _SelectorRow extends StatelessWidget {
  const _SelectorRow({required this.provider});

  final RaceReplayProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Year dropdown
          _buildDropdown<int>(
            value: provider.selectedYear,
            items: [2023, 2024, 2025, 2026],
            labelBuilder: (year) => year.toString(),
            onChanged: (year) {
              if (year != null) provider.loadYear(year);
            },
            hint: 'Year',
          ),

          const SizedBox(width: 12),

          // Race dropdown
          Expanded(
            child: _buildMeetingDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: provider.selectedMeeting,
          isExpanded: true,
          dropdownColor: AppTheme.cardSurface,
          icon: Icon(
            Icons.expand_more_rounded,
            color: AppTheme.textMuted,
          ),
          hint: Text(
            'Select Race',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
          items: provider.availableMeetings.map((meeting) {
            return DropdownMenuItem(
              value: meeting,
              child: Text(
                meeting.meetingName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: (meeting) {
            if (meeting != null) {
              provider.selectMeeting(meeting);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: AppTheme.cardSurface,
          icon: Icon(
            Icons.expand_more_rounded,
            color: AppTheme.textMuted,
          ),
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: Empty / Placeholder State
// ---------------------------------------------------------------------------

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_motorsports_rounded,
              size: 64,
              color: AppTheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Select a race to view replay',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a year and race from the dropdowns above\n'
              'to load the track map and driver positions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Phone Layout
// ---------------------------------------------------------------------------

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({required this.provider});

  final RaceReplayProvider provider;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // App bar area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.f1RedGradient.createShader(bounds),
                child: const Text(
                  'RACE REPLAY',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // Selectors
          _SelectorRow(provider: provider),

          const SizedBox(height: 4),

          // Main content
          Expanded(child: _buildBody()),

          // Playback controls pinned at bottom
          if (provider.circuitInfo != null)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: PlaybackControls(),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (provider.circuitInfo == null) {
      return const _PlaceholderView();
    }

    return Column(
      children: [
        // Track map — 60 %
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: AppTheme.glassmorphicDecoration,
                      child: TrackMapWidget(
                        circuitInfo: provider.circuitInfo!,
                        driverPositions: provider.getCurrentDriverPositions(),
                        drivers: provider.drivers,
                        trackColor: provider.getTrackStatusColor(),
                        hasTelemetry: provider.hasTelemetry,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _LapInfoBar(provider: provider),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Leaderboard — 40 %
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DriverLeaderboard(
              entries: provider.getLeaderboard(),
              isTablet: false,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet Layout
// ---------------------------------------------------------------------------

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.provider});

  final RaceReplayProvider provider;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.f1RedGradient.createShader(bounds),
                child: const Text(
                  'RACE REPLAY',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // Selectors
          _SelectorRow(provider: provider),

          const SizedBox(height: 4),

          // Main content
          Expanded(child: _buildBody()),

          // Pinned playback controls
          if (provider.circuitInfo != null)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: PlaybackControls(),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (provider.circuitInfo == null) {
      return const _PlaceholderView();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Left: Track map
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: AppTheme.glassmorphicDecoration,
                      child: TrackMapWidget(
                        circuitInfo: provider.circuitInfo!,
                        driverPositions: provider.getCurrentDriverPositions(),
                        drivers: provider.drivers,
                        trackColor: provider.getTrackStatusColor(),
                        hasTelemetry: provider.hasTelemetry,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _LapInfoBar(provider: provider),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Right: Leaderboard
          Expanded(
            flex: 2,
            child: DriverLeaderboard(
              entries: provider.getLeaderboard(),
              isTablet: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info Chip (used in tablet weather / info bar)
// ---------------------------------------------------------------------------

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.hasDropdown = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool hasDropdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: hasDropdown ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4) : null,
      decoration: hasDropdown
          ? BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AppTheme.textMuted,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (hasDropdown) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LapInfoBar extends StatelessWidget {
  final RaceReplayProvider provider;

  const _LapInfoBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoChip(
            icon: Icons.flag_rounded,
            label: 'Lap',
            value: '${provider.currentLap} / ${provider.totalLaps}',
          ),
          PopupMenuButton<double>(
            tooltip: 'Select Speed',
            itemBuilder: (context) => [0.5, 1.0, 2.0, 5.0, 10.0, 20.0].map((s) => PopupMenuItem(
              value: s,
              height: 32,
              child: Text('${s}x', style: const TextStyle(color: Colors.white, fontSize: 13)),
            )).toList(),
            onSelected: (speed) => provider.setPlaybackSpeed(speed),
            color: AppTheme.cardSurface,
            child: _InfoChip(
              icon: Icons.speed_rounded,
              label: 'Speed',
              value: '${provider.playbackSpeed}x',
              hasDropdown: true,
            ),
          ),
          PopupMenuButton<int>(
            tooltip: 'Select Refresh Rate',
            itemBuilder: (context) => [1, 2, 5, 10, 30, 60].map((r) => PopupMenuItem(
              value: r,
              height: 32,
              child: Text('${r}s', style: const TextStyle(color: Colors.white, fontSize: 13)),
            )).toList(),
            onSelected: (seconds) => provider.setApiRefreshInterval(seconds),
            color: AppTheme.cardSurface,
            child: _InfoChip(
              icon: Icons.timer_rounded,
              label: 'Refresh',
              value: '${provider.apiRefreshIntervalSeconds}s',
              hasDropdown: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Landscape Layout (65% Map on left, 35% controls on right)
// ---------------------------------------------------------------------------

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({required this.provider});

  final RaceReplayProvider provider;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Selectors
          _SelectorRow(provider: provider),

          // Main body split: 65% left, 35% right
          Expanded(child: _buildSplitBody()),
        ],
      ),
    );
  }

  Widget _buildSplitBody() {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (provider.circuitInfo == null) {
      return const _PlaceholderView();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: 65% map
          Expanded(
            flex: 65,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: AppTheme.glassmorphicDecoration,
                        child: TrackMapWidget(
                          circuitInfo: provider.circuitInfo!,
                          driverPositions: provider.getCurrentDriverPositions(),
                          drivers: provider.drivers,
                          trackColor: provider.getTrackStatusColor(),
                          hasTelemetry: provider.hasTelemetry,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _LapInfoBar(provider: provider),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Right side: 35% controls + leaderboard
          Expanded(
            flex: 35,
            child: Column(
              children: [
                // Mini Leaderboard
                Expanded(
                  child: DriverLeaderboard(
                    entries: provider.getLeaderboard(),
                    isTablet: true,
                  ),
                ),

                const SizedBox(height: 8),

                // Controls pinned at bottom right
                const PlaybackControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
