import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zenith/core/theme/app_theme.dart';
import 'package:zenith/main.dart';
import 'package:zenith/models/workout_record.dart';
import 'package:zenith/screens/progress/progress_screen.dart';
import 'package:zenith/services/local_store.dart';
import 'package:zenith/services/workout_engine.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('app loads the workout home screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byKey(const ValueKey('splash-logo')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text("Let's keep it consistent."), findsOneWidget);
    expect(find.text('Next Up'), findsOneWidget);
  });

  testWidgets('a logged workout updates monthly progress',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('START WORKOUT  →'));
    await tester.pumpAndSettle();
    expect(find.text('Bench press'), findsOneWidget);

    await tester.tap(find.text('Add set').first);
    await tester.pump();
    expect(find.text('Set 2'), findsOneWidget);

    await tester.tap(find.text('Finish workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    expect(find.text('Monthly activity'), findsOneWidget);
    expect(find.text('1 workout day · 1 session'), findsOneWidget);
  });

  testWidgets('monthly calendar counts distinct workout days and browses months',
      (tester) async {
    WorkoutRecord recordOn(int year, int month, int day) => WorkoutRecord(
          planId: 'push',
          planName: 'Push Day',
          completedAt: DateTime(year, month, day, 12),
          duration: Duration.zero,
          exercises: const [],
        );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: ListView(
            children: [
              MonthlyWorkoutCalendar(
                initialDate: DateTime(2026, 5, 15),
                history: [
                  recordOn(2026, 5, 5),
                  recordOn(2026, 5, 5),
                  recordOn(2026, 5, 22),
                  recordOn(2026, 4, 30),
                  recordOn(2026, 6, 1),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text('2 workout days · 3 sessions'), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-day-5')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-day-22')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('previous-month')));
    await tester.pumpAndSettle();

    expect(find.text('April 2026'), findsOneWidget);
    expect(find.text('1 workout day · 1 session'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('next-month')));
    await tester.pumpAndSettle();

    expect(find.text('May 2026'), findsOneWidget);
    expect(find.text('2 workout days · 3 sessions'), findsOneWidget);
  });

  test('personal best prefers the heaviest set then reps', () {
    final records = [
      WorkoutRecord(
        planId: 'push',
        planName: 'Push',
        completedAt: DateTime(2026),
        duration: Duration.zero,
        exercises: const [
          ExerciseLog(
              exerciseName: 'Bench press',
              sets: [WorkoutSet(reps: 8, load: 80)]),
          ExerciseLog(
              exerciseName: 'Bench press',
              sets: [WorkoutSet(reps: 10, load: 80)]),
        ],
      ),
    ];

    final best = WorkoutEngine.personalBests(records).single;
    expect(best.set.reps, 10);
    expect(best.set.load, 80);
  });

  test('workout records survive a local store reload', () async {
    final record = WorkoutRecord(
      planId: 'push',
      planName: 'Push',
      completedAt: DateTime(2026),
      duration: Duration(minutes: 45),
      exercises: [
        ExerciseLog(
          exerciseName: 'Bench press',
          sets: [WorkoutSet(reps: 8, load: 80)],
        ),
      ],
    );
    final store = LocalStore();

    await store.save(plans: const [], history: [record], weeklyGoal: 3);
    final restored = await store.load();

    expect(restored.weeklyGoal, 3);
    expect(restored.history.single.exercises.single.sets.single.load, 80);
  });
}
