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
    final selected = provider.selectedMeeting;
    final value = provider.availableMeetings.contains(selected) ? selected : null;
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
          value: value,
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
                        isRaceOver: provider.isRaceOver(),
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
                        isRaceOver: provider.isRaceOver(),
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
    this.showLabel = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool hasDropdown;
  final bool showLabel;

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
          if (showLabel)
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
            )
          else
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

class _CombinedPlaybackControls extends StatelessWidget {
  final RaceReplayProvider provider;

  const _CombinedPlaybackControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress(provider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;
        final spacing = isNarrow ? 6.0 : 12.0;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.border.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              // Play/Pause button
              IconButton(
                icon: Icon(
                  provider.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: AppTheme.textPrimary,
                ),
                onPressed: provider.togglePlayPause,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
              const SizedBox(width: 4),

              // Timeline slider
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor:
                        AppTheme.border.withValues(alpha: 0.3),
                    thumbColor: AppTheme.primary,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    trackHeight: 2,
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) => provider.seekTo(value),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Elapsed time
              Text(
                _formatElapsed(
                  provider.playbackTime,
                  provider.sessionStart,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (!isNarrow) ...[
                const SizedBox(width: 12),
                // Vertical divider
                Container(
                  width: 1,
                  height: 20,
                  color: AppTheme.border.withValues(alpha: 0.2),
                ),
              ],
              SizedBox(width: spacing),

              // Lap Chip
              _InfoChip(
                icon: Icons.flag_rounded,
                label: 'Lap',
                value: '${provider.currentLap} / ${provider.totalLaps}',
                showLabel: !isNarrow,
              ),
              SizedBox(width: spacing),

              // Speed selector
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
                  showLabel: !isNarrow,
                ),
              ),
              SizedBox(width: spacing),

              // Refresh selector
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
                  showLabel: !isNarrow,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateProgress(RaceReplayProvider provider) {
    if (provider.sessionStart == null || provider.sessionEnd == null) {
      return 0.0;
    }
    if (provider.playbackTime == null) return 0.0;
    final total = provider.sessionEnd!
        .difference(provider.sessionStart!)
        .inMilliseconds;
    if (total <= 0) return 0.0;
    final elapsed = provider.playbackTime!
        .difference(provider.sessionStart!)
        .inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  String _formatElapsed(DateTime? playbackTime, DateTime? sessionStart) {
    if (playbackTime == null || sessionStart == null) return '00:00:00';
    final diff = playbackTime.difference(sessionStart);
    final hours = diff.inHours.abs().toString().padLeft(2, '0');
    final minutes = (diff.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds.abs() % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
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
                          isRaceOver: provider.isRaceOver(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _CombinedPlaybackControls(provider: provider),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Right side: 35% leaderboard (filling full height)
          Expanded(
            flex: 35,
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
