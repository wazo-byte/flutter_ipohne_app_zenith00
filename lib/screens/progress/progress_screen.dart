import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/workout_record.dart';
import '../../services/workout_engine.dart';

class MonthlyWorkoutCalendar extends StatefulWidget {
  final List<WorkoutRecord> history;
  final DateTime? initialDate;

  const MonthlyWorkoutCalendar({
    super.key,
    required this.history,
    this.initialDate,
  });

  @override
  State<MonthlyWorkoutCalendar> createState() => _MonthlyWorkoutCalendarState();
}

class _MonthlyWorkoutCalendarState extends State<MonthlyWorkoutCalendar> {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final date = widget.initialDate ?? DateTime.now();
    _visibleMonth = DateTime(date.year, date.month);
  }

  Map<int, int> _sessionCounts() {
    final counts = <int, int>{};
    for (final record in widget.history) {
      final date = record.completedAt.toLocal();
      if (date.year == _visibleMonth.year &&
          date.month == _visibleMonth.month) {
        counts.update(date.day, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  void _changeMonth(int amount) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionsByDay = _sessionCounts();
    final sessionCount =
        sessionsByDay.values.fold<int>(0, (sum, count) => sum + count);
    final daysInMonth =
        DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final leadingDays = DateTime(
          _visibleMonth.year,
          _visibleMonth.month,
        ).weekday -
        1;
    final today = widget.initialDate ?? DateTime.now();
    final isCurrentMonth =
        _visibleMonth.year == today.year && _visibleMonth.month == today.month;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Monthly activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                key: const ValueKey('previous-month'),
                tooltip: 'Previous month',
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                key: const ValueKey('calendar-month'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              IconButton(
                key: const ValueKey('next-month'),
                tooltip: 'Next month',
                onPressed: isCurrentMonth ? null : () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${sessionsByDay.length} workout ${sessionsByDay.length == 1 ? 'day' : 'days'}'
            ' · $sessionCount ${sessionCount == 1 ? 'session' : 'sessions'}',
            key: const ValueKey('monthly-workout-summary'),
            style: const TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 18),
          Row(
            children: _weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            key: const ValueKey('monthly-calendar-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingDays + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              if (index < leadingDays) return const SizedBox.shrink();
              final day = index - leadingDays + 1;
              final sessionCount = sessionsByDay[day] ?? 0;
              final isToday = isCurrentMonth && today.day == day;

              return Container(
                key: ValueKey('calendar-day-$day'),
                decoration: BoxDecoration(
                  color: sessionCount > 0
                      ? AppTheme.accent.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday
                        ? AppTheme.primary
                        : sessionCount > 0
                            ? AppTheme.accent.withValues(alpha: 0.45)
                            : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        color:
                            sessionCount > 0 ? AppTheme.text : AppTheme.muted,
                        fontWeight: isToday || sessionCount > 0
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (sessionCount > 0)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(height: 5),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Workout completed',
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  final List<WorkoutRecord> history;
  final int weeklyGoal;

  const ProgressScreen({
    super.key,
    required this.history,
    required this.weeklyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    final workoutsThisWeek =
        history.where((record) => record.completedAt.isAfter(weekStart)).length;
    final completedExercises =
        history.fold<int>(0, (total, record) => total + record.exerciseCount);
    final progress = (workoutsThisWeek / weeklyGoal).clamp(0.0, 1.0).toDouble();
    final personalBests = WorkoutEngine.personalBests(history);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const Text('Progress',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          MonthlyWorkoutCalendar(history: history),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weekly goal',
                    style: TextStyle(color: AppTheme.muted)),
                const SizedBox(height: 10),
                Text(
                  '$workoutsThisWeek of $weeklyGoal workouts',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: AppTheme.surface2,
                ),
                const SizedBox(height: 10),
                Text(
                  workoutsThisWeek >= weeklyGoal
                      ? 'Weekly goal reached. Nice work!'
                      : '${weeklyGoal - workoutsThisWeek} more to reach your goal',
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total workouts',
                  value: '${history.length}',
                  icon: Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Exercises done',
                  value: '$completedExercises',
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text('Personal Bests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Your heaviest set for each exercise.',
              style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 12),
          if (personalBests.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                    'Finish your first workout to start tracking personal bests.',
                    style: TextStyle(color: AppTheme.muted)),
              ),
            )
          else
            ...personalBests.map(
              (best) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                      child: Icon(Icons.emoji_events_outlined)),
                  title: Text(best.exerciseName,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: Text(
                      '${best.set.load.toStringAsFixed(best.set.load.truncateToDouble() == best.set.load ? 0 : 1)} kg × ${best.set.reps}',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(height: 14),
          Text(value,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
        ],
      ),
    );
  }
}
