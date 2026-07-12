import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/session.dart';
import '../theme/app_theme.dart';

class SessionSchedule extends StatelessWidget {
  final List<Session> sessions;

  const SessionSchedule({
    super.key,
    required this.sessions,
  });

  bool _isRaceSession(Session session) {
    final name = session.sessionName.toLowerCase();
    return name == 'race' || name == 'sprint';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE d MMM');
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sessions.map((session) {
        final isRace = _isRaceSession(session);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.border.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              // Session name
              Expanded(
                flex: 3,
                child: Text(
                  session.sessionName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isRace ? FontWeight.w700 : FontWeight.w500,
                    color: isRace ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
              ),

              // Date
              Expanded(
                flex: 3,
                child: Text(
                  dateFormat.format(session.dateStart),
                  style: TextStyle(
                    fontSize: 13,
                    color: isRace
                        ? AppTheme.primary.withValues(alpha: 0.8)
                        : AppTheme.textSecondary,
                  ),
                ),
              ),

              // Time
              SizedBox(
                width: 50,
                child: Text(
                  timeFormat.format(session.dateStart),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isRace
                        ? AppTheme.primary
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
