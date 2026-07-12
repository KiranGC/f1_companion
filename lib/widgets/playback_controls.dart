import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/race_replay_provider.dart';
import '../theme/app_theme.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({super.key});

  String _formatElapsed(DateTime? playbackTime, DateTime? sessionStart) {
    if (playbackTime == null || sessionStart == null) return '00:00:00';
    final diff = playbackTime.difference(sessionStart);
    final hours = diff.inHours.abs().toString().padLeft(2, '0');
    final minutes = (diff.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds.abs() % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceReplayProvider>(
      builder: (context, provider, child) {
        final progress = _calculateProgress(provider);

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
}
