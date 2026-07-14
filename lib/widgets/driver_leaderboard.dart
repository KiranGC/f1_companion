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

  /// Returns a single-letter label for the compound: S / M / H / I / W.
  String _getTireLabel(String? compound) {
    switch ((compound ?? '').toUpperCase()) {
      case 'SOFT':         return 'S';
      case 'MEDIUM':       return 'M';
      case 'HARD':         return 'H';
      case 'INTERMEDIATE': return 'I';
      case 'WET':          return 'W';
      default:             return '?';
    }
  }

  /// Returns true when the compound should be rendered as an outlined (hollow)
  /// circle instead of a solid fill — used for HARD so the white fill does
  /// not disappear against the dark leaderboard background.
  bool _isTireOutlined(String? compound) =>
      (compound ?? '').toUpperCase() == 'HARD';

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

  Widget _buildHeaderRow(BuildContext context) {
    final headerFontSize = isTablet ? 9.5 : 10.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // POS
          SizedBox(
            width: 24,
            child: Text(
              'POS',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMuted,
                fontFamily: 'Outfit',
              ),
            ),
          ),

          // Team color bar space (3px bar + 8px margin)
          const SizedBox(width: 11),

          // DRIVER
          SizedBox(
            width: 38,
            child: Text(
              'DRIVER',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMuted,
                fontFamily: 'Outfit',
              ),
            ),
          ),

          const SizedBox(width: 8),

          // GAP / TIME
          Expanded(
            child: Text(
              'GAP / LAST LAP',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMuted,
                fontFamily: 'Outfit',
              ),
            ),
          ),

          if (isTablet) ...[
            const SizedBox(width: 8),

            // TYRE
            SizedBox(
              width: 16,
              child: Center(
                child: Text(
                  'TYR',
                  style: TextStyle(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // PITS
            SizedBox(
              width: 26,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'PIT',
                  style: TextStyle(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderRow(context),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isLeader = entry.position == 1;
              final bgColor = index.isEven
                  ? AppTheme.cardSurface
                  : AppTheme.cardSurface.withValues(alpha: 0.5);

              // Adjust padding and heights to fit 22 drivers
              final rowVerticalPadding = isTablet ? 1.5 : 4.0;
              final fontSize = isTablet ? 11.0 : 12.5;

              final timeText = entry.isRetired
                  ? 'Out'
                  : isLeader
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
                          color: entry.isRetired
                              ? AppTheme.textMuted
                              : isLeader
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                          fontWeight: entry.isRetired
                              ? FontWeight.w500
                              : isLeader
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                        ),
                      ),
                    ),

                    // Tablet-only or Replay side-by-side columns: tire compound + pit stops
                    if (isTablet) ...[
                      const SizedBox(width: 8),

                      // Tyre compound dot with letter label.
                      // HARD uses outlined style (white border, dark fill) so
                      // it is clearly visible on the dark leaderboard background.
                      Builder(builder: (_) {
                        final compound = entry.currentCompound;
                        final isHard = _isTireOutlined(compound);
                        final dotColor = isHard
                            ? const Color(0xFF1E1E2E) // dark fill for HARD
                            : _getTireColor(compound);
                        final borderColor = isHard
                            ? Colors.white           // bright white border for HARD
                            : _getTireColor(compound).withValues(alpha: 0.5);
                        final labelColor = isHard
                            ? Colors.white
                            : Colors.black87;

                        return Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                            border: Border.all(
                              color: borderColor,
                              width: isHard ? 2.0 : 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _getTireLabel(compound),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: labelColor,
                              height: 1,
                            ),
                          ),
                        );
                      }),

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
          ),
        ),
      ],
    );
  }
}
