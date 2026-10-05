import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/workout_record.dart';

class HistoryScreen extends StatelessWidget {
  final List<WorkoutRecord> history;

  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const Text(
            'Workout History',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 72),
              child: Column(
                children: [
                  Icon(Icons.history, size: 48, color: AppTheme.muted),
                  SizedBox(height: 14),
                  Text('No completed workouts yet'),
                  SizedBox(height: 6),
                  Text(
                    'Finish a workout and it will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.muted),
                  ),
                ],
              ),
            )
          else
            ...history.map(
              (record) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.surface2,
                    child: Icon(Icons.check, color: AppTheme.primary),
                  ),
                  title: Text(record.planName,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${record.completedAt.toLocal().toString().substring(0, 16)}\n'
                    '${record.exerciseCount} exercises · ${record.setCount} sets · ${record.duration.inMinutes} min',
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
