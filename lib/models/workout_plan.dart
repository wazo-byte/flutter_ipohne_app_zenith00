class WorkoutPlan {
  final String id;
  final String name;
  final int exerciseCount;
  final DateTime? lastCompleted;
  final List<String> exercises;
  final List<String?> exerciseImages;

  /// Reserved for future push/pull/legs, upper/lower, and muscle visuals.
  final String? category;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.exerciseCount,
    this.lastCompleted,
    this.exercises = const [],
    this.exerciseImages = const [],
    this.category,
  });

  List<String> get exerciseNames => exercises.isEmpty
      ? List.generate(exerciseCount, (index) => 'Exercise ${index + 1}')
      : exercises;

  String? exerciseImageAt(int index) =>
      index < exerciseImages.length ? exerciseImages[index] : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exerciseNames,
        'exerciseImages': List.generate(
          exerciseNames.length,
          exerciseImageAt,
        ),
        'category': category,
      };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final exercises = List<String>.from(json['exercises'] as List? ?? const []);
    final exerciseImages =
        List<String?>.from(json['exerciseImages'] as List? ?? const []);
    return WorkoutPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      exerciseCount: exercises.length,
      exercises: exercises,
      exerciseImages: exerciseImages,
      category: json['category'] as String?,
    );
  }
}
