import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../models/meeting.dart';
import '../theme/app_theme.dart';

class RaceCalendarCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback? onTap;

  const RaceCalendarCard({
    super.key,
    required this.meeting,
    this.onTap,
  });

  bool get _isCompleted {
    return meeting.dateEnd.toUtc().isBefore(DateTime.now().toUtc());
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM');
    final dateRange =
        '${dateFormat.format(meeting.dateStart.toLocal())} – ${dateFormat.format(meeting.dateEnd.toLocal())}';
    final completed = _isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: completed
              ? AppTheme.border.withValues(alpha: 0.3)
              : AppTheme.primary.withValues(alpha: 0.3),
          width: completed ? 1.0 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.primary.withValues(alpha: 0.15),
        highlightColor: Colors.transparent,
        child: Ink(
          color: completed
              ? AppTheme.cardSurface.withValues(alpha: 0.6)
              : AppTheme.cardSurface,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Circuit image (only show if screen width is not constrained like in grids)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCellNarrow = MediaQuery.of(context).size.width < 500;
                  if (isCellNarrow) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Opacity(
                      opacity: completed ? 0.6 : 1.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            0, 0, 0, 0, 255,
                            0, 0, 0, 0, 255,
                            0, 0, 0, 0, 255,
                            1, 0, 0, 0, 0,
                          ]),
                          child: CachedNetworkImage(
                            imageUrl: meeting.circuitImage,
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              width: 44,
                              height: 44,
                              color: Colors.transparent,
                              child: const Icon(
                                Icons.track_changes,
                                color: AppTheme.textMuted,
                                size: 18,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 44,
                              height: 44,
                              color: Colors.transparent,
                              child: const Icon(
                                Icons.track_changes,
                                color: AppTheme.textMuted,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Meeting info
              Expanded(
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    final isCellShort = boxConstraints.maxHeight < 55;
                    return Opacity(
                      opacity: completed ? 0.7 : 1.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              // Country flag
                              if (meeting.countryCode.isNotEmpty && !isCellShort) ...[
                                CachedNetworkImage(
                                  imageUrl:
                                      'https://flagcdn.com/20x15/${meeting.countryCode.toLowerCase()}.png',
                                  width: 20,
                                  height: 15,
                                  placeholder: (context, url) =>
                                      const SizedBox(width: 20, height: 15),
                                  errorWidget: (context, url, error) => const Icon(
                                   Icons.flag,
                                    size: 15,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  meeting.meetingName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: completed
                                        ? AppTheme.textSecondary
                                        : AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (!isCellShort) ...[
                            const SizedBox(height: 2),
                            Text(
                              meeting.location,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              dateRange,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Completed badge / checkmark
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isCellNarrow = screenWidth < 700;
                  if (completed) {
                    if (isCellNarrow) {
                      return const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 14,
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            color: Colors.green,
                            size: 10,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'COMPLETED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isCellNarrow = screenWidth < 700;
                  if (!isCellNarrow) {
                    return const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.chevron_right,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
