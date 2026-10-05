import '../models/workout_plan.dart';
import '../models/workout_record.dart';

class WorkoutEngine {
  /// MVP rotation:
  /// choose the first plan after the most recently completed plan.
  /// Later this becomes history/recovery/muscle-aware.
  static WorkoutPlan nextWorkout({
    required List<WorkoutPlan> plans,
    WorkoutPlan? lastCompleted,
  }) {
    if (plans.isEmpty) {
      throw StateError('No workout plans available.');
    }

    if (lastCompleted == null) return plans.first;

    final index = plans.indexWhere((p) => p.id == lastCompleted.id);
    if (index == -1) return plans.first;

    return plans[(index + 1) % plans.length];
  }

  static List<PersonalBest> personalBests(List<WorkoutRecord> history) {
    final bests = <String, PersonalBest>{};
    for (final record in history) {
      for (final exercise in record.exercises) {
        for (final set in exercise.sets) {
          final current = bests[exercise.exerciseName];
          if (current == null ||
              set.load > current.set.load ||
              (set.load == current.set.load && set.reps > current.set.reps)) {
            bests[exercise.exerciseName] =
                PersonalBest(exerciseName: exercise.exerciseName, set: set);
          }
        }
      }
    }
    return bests.values.toList()
      ..sort((a, b) => b.set.load.compareTo(a.set.load));
  }
}
