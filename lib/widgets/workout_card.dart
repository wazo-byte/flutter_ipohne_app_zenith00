import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/workout_plan.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onStart;

  const WorkoutCard({
    super.key,
    required this.plan,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child:
                  Icon(Icons.fitness_center, size: 64, color: AppTheme.muted),
            ),
          ),
          const SizedBox(height: 14),
          Text(plan.name,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            '${plan.exerciseCount} exercises',
            style: const TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'START WORKOUT  →',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
