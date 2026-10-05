class WorkoutPlan {
  final String id;
  final String name;
  final int exerciseCount;
  final DateTime? lastCompleted;
  final List<String> exercises;
  final String? coverImageData;

  /// Reserved for future push/pull/legs, upper/lower, and muscle visuals.
  final String? category;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.exerciseCount,
    this.lastCompleted,
    this.exercises = const [],
    this.coverImageData,
    this.category,
  });

  List<String> get exerciseNames => exercises.isEmpty
      ? List.generate(exerciseCount, (index) => 'Exercise ${index + 1}')
      : exercises;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exerciseNames,
        'coverImageData': coverImageData,
        'category': category,
      };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final exercises = List<String>.from(json['exercises'] as List? ?? const []);
    return WorkoutPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      exerciseCount: exercises.length,
      exercises: exercises,
      coverImageData: json['coverImageData'] as String?,
      category: json['category'] as String?,
    );
  }
}
