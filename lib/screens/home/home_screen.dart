import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_record.dart';
import '../../widgets/workout_card.dart';

class HomeScreen extends StatelessWidget {
  final WorkoutPlan nextWorkout;
  final List<WorkoutRecord> history;
  final ValueChanged<WorkoutPlan> onStartWorkout;

  const HomeScreen({
    super.key,
    required this.nextWorkout,
    required this.history,
    required this.onStartWorkout,
  });

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/zenith_logo.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  semanticLabel: 'Zenith logo',
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ZENITH',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(greeting,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            "Let's keep it consistent.",
            style: TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Text('Next Up',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Based on your recent workouts',
            style: TextStyle(color: AppTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          WorkoutCard(
            plan: nextWorkout,
            onStart: () => onStartWorkout(nextWorkout),
          ),
          const SizedBox(height: 28),
          const Text('Recent Workouts',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'Your completed workouts will show up here.',
                style: TextStyle(color: AppTheme.muted),
              ),
            )
          else
            ...history.take(3).map(
                  (record) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.surface2,
                      child: const Icon(Icons.fitness_center,
                          color: AppTheme.muted),
                    ),
                    title: Text(record.planName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${record.exerciseCount} exercises · ${record.completedAt.toLocal().toString().substring(0, 10)}',
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
