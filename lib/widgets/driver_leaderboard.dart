import 'package:flutter/material.dart';

import '../providers/race_replay_provider.dart';
import '../theme/app_theme.dart';
import '../theme/team_colors.dart';

class DriverLeaderboard extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final bool isTablet;

  const DriverLeaderboard({
    super.key,
    required this.entries,
    this.isTablet = false,
  });

  Color _getTireColor(String? compound) {
    return TeamColors.getTireColor(compound ?? '');
  }

  String _formatLapTime(double? seconds) {
    if (seconds == null) return '--';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toStringAsFixed(3).padLeft(6, '0')}';
  }

  String _formatGap(double? gap) {
    if (gap == null) return '--';
    if (gap == 0.0) return 'Leader';
    return '+${gap.toStringAsFixed(3)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isLeader = entry.position == 1;
        final bgColor = index.isEven
            ? AppTheme.cardSurface
            : AppTheme.cardSurface.withValues(alpha: 0.5);

        // Adjust padding and heights to fit 22 drivers
        final rowVerticalPadding = isTablet ? 2.0 : 6.0;
        final fontSize = isTablet ? 11.5 : 13.0;

        final timeText = isLeader
            ? _formatLapTime(entry.lastLapTime)
            : _formatGap(entry.gapToLeader);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: rowVerticalPadding),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.border.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: Row(
            children: [
              // Position number
              SizedBox(
                width: 24,
                child: Text(
                  '${entry.position}',
                  style: TextStyle(
                    fontSize: fontSize + 1,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              // Team color bar
              Container(
                width: 3,
                height: 18,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: TeamColors.fromHex(entry.teamColour),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),

              // Driver acronym
              SizedBox(
                width: 38,
                child: Text(
                  entry.nameAcronym,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Time Column (Leader's last lap time or gap to leader)
              Expanded(
                child: Text(
                  timeText,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'monospace',
                    color: isLeader ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: isLeader ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),

              // Tablet-only or Replay side-by-side columns: tire compound + pit stops
              if (isTablet) ...[
                const SizedBox(width: 8),

                // Tyre compound
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getTireColor(entry.currentCompound),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Pit stops
                SizedBox(
                  width: 26,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.build_rounded,
                        size: 9,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${entry.pitStops}',
                        style: TextStyle(
                          fontSize: fontSize - 1,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
