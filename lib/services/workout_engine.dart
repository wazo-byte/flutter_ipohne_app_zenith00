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
  
  /// Finds the most recent non-empty performance log for an exercise.
  static ExerciseLog? latestExercisePerformance({
    required List<WorkoutRecord> history,
    required String exerciseName,
  }) {
    String normalize(String value) => value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');

    final target = normalize(exerciseName);

    final records = history.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    for (final record in records) {
      for (final exercise in record.exercises) {
        if (normalize(exercise.exerciseName) == target &&
            exercise.sets.isNotEmpty) {
          return exercise;
        }
      }
    }

    return null;
  }

}
