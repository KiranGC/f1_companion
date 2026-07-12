import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/meeting.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';

class CountdownCard extends StatelessWidget {
  final Meeting meeting;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final List<Session> sessions;

  const CountdownCard({
    super.key,
    required this.meeting,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassmorphicDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "NEXT RACE" header with gradient text
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.f1RedGradient.createShader(bounds),
            child: const Text(
              'NEXT RACE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Round number + official name
          Text(
            'ROUND ${meeting.meetingKey}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meeting.meetingOfficialName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Circuit short name + country flag
          Row(
            children: [
              if (meeting.countryCode.isNotEmpty) ...[
                CachedNetworkImage(
                  imageUrl:
                      'https://flagcdn.com/24x18/${meeting.countryCode.toLowerCase()}.png',
                  width: 24,
                  height: 18,
                  placeholder: (context, url) => const SizedBox(
                    width: 24,
                    height: 18,
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.flag,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  meeting.circuitShortName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Countdown boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CountdownBox(value: days, label: 'DAYS'),
              _CountdownBox(value: hours, label: 'HRS'),
              _CountdownBox(value: minutes, label: 'MIN'),
              _CountdownBox(value: seconds, label: 'SEC'),
            ],
          ),
          const SizedBox(height: 20),

          // Next session info
          if (sessions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Next: ${sessions.first.sessionName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final int value;
  final String label;

  const _CountdownBox({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              value.toString().padLeft(2, '0'),
              key: ValueKey<int>(value),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
