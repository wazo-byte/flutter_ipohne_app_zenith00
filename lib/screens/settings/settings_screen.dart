import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final int weeklyGoal;
  final ValueChanged<int> onWeeklyGoalChanged;

  const SettingsScreen({
    super.key,
    required this.weeklyGoal,
    required this.onWeeklyGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const Text('Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly workout goal',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose how many sessions you want to complete each week.',
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Decrease weekly goal',
                        onPressed: weeklyGoal > 1
                            ? () => onWeeklyGoalChanged(weeklyGoal - 1)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Expanded(
                        child: Text(
                          '$weeklyGoal ${weeklyGoal == 1 ? 'workout' : 'workouts'} per week',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Increase weekly goal',
                        onPressed: weeklyGoal < 7
                            ? () => onWeeklyGoalChanged(weeklyGoal + 1)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
