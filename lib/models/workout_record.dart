class WorkoutSet {
  final int reps;
  final double load;

  const WorkoutSet({required this.reps, required this.load});

  Map<String, dynamic> toJson() => {'reps': reps, 'load': load};

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        reps: json['reps'] as int,
        load: (json['load'] as num).toDouble(),
      );
}

class ExerciseLog {
  final String exerciseName;
  final List<WorkoutSet> sets;

  const ExerciseLog({required this.exerciseName, required this.sets});

  Map<String, dynamic> toJson() => {
        'exerciseName': exerciseName,
        'sets': sets.map((set) => set.toJson()).toList(),
      };

  factory ExerciseLog.fromJson(Map<String, dynamic> json) => ExerciseLog(
        exerciseName: json['exerciseName'] as String,
        sets: (json['sets'] as List)
            .map((set) =>
                WorkoutSet.fromJson(Map<String, dynamic>.from(set as Map)))
            .toList(),
      );
}

class WorkoutRecord {
  final String planId;
  final String planName;
  final DateTime completedAt;
  final Duration duration;
  final List<ExerciseLog> exercises;

  const WorkoutRecord({
    required this.planId,
    required this.planName,
    required this.completedAt,
    required this.duration,
    required this.exercises,
  });

  int get exerciseCount => exercises.length;
  int get setCount =>
      exercises.fold(0, (total, exercise) => total + exercise.sets.length);

  Map<String, dynamic> toJson() => {
        'planId': planId,
        'planName': planName,
        'completedAt': completedAt.toIso8601String(),
        'durationSeconds': duration.inSeconds,
        'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => WorkoutRecord(
        planId: json['planId'] as String,
        planName: json['planName'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String),
        duration: Duration(seconds: json['durationSeconds'] as int),
        exercises: (json['exercises'] as List)
            .map((exercise) => ExerciseLog.fromJson(
                Map<String, dynamic>.from(exercise as Map)))
            .toList(),
      );
}

class PersonalBest {
  final String exerciseName;
  final WorkoutSet set;

  const PersonalBest({required this.exerciseName, required this.set});
}
