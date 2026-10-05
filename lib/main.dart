import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'models/workout_plan.dart';
import 'models/workout_record.dart';
import 'screens/history/history_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/plans/plans_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/session/workout_session_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/workout_engine.dart';
import 'services/local_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenith',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const ZenithShell(),
    );
  }
}

class ZenithShell extends StatefulWidget {
  const ZenithShell({super.key});

  @override
  State<ZenithShell> createState() => _ZenithShellState();
}

class _ZenithShellState extends State<ZenithShell> {
  int _index = 0;
  int _weeklyGoal = 4;
  final _store = LocalStore();
  bool _loading = true;
  late List<WorkoutPlan> _plans;
  List<WorkoutRecord> _history = [];

  static const _starterPlans = [
    WorkoutPlan(
      id: 'Day 1',
      name: 'D-1Glutes + Hamstrings',
      category: 'Lower',
      exerciseCount: 5,
      exercises: [
        'Hip Thrust',
        'Romanian Deadlift',
        'Step Ups',
        'Seated / Lying Hamstring Curl',
        'Hip Abduction',
      ],
    ),
    WorkoutPlan(
      id: 'Day 2 ',
      name: 'D-2 Back + Biceps',
      category: 'Upper',
      exerciseCount: 6,
      exercises: [
        'Lat pulldown',
        'Chest-Supported/Seated Cable Row',
        'Single-arm Row',
        'Straight-arm Pulldown',
        'Face Pull/ Rear Delt Fly',
        'Bicep Curl',
      ],
    ),
    WorkoutPlan(
      id: 'Day 3',
      name: 'D-3 Glutes + Quads',
      category: 'Lower',
      exerciseCount: 5,
      exercises: [
        'Hip Thrust',
        'Squat',
        'Bulgarian Split Squat',
        'Leg Extension',
        'Cable Kickback',
      ],
    ),
    WorkoutPlan(
      id: 'Day 4',
      name: 'D-4 Shoulder + Chest + Triceps',
      category: 'Upper',
      exerciseCount: 6,
      exercises: [
        'Shoulder Press',
        'Lateral Raise',
        'Incline Chest Press',
        'Push-up',
        'Rear Delt Fly',
        'Tricep Pushdown',
      ],
    ),
    WorkoutPlan(
      id: 'abs 1',
      name: 'ABS (leg raises)',
      category: 'Core',
      exerciseCount: 5,
      exercises: [
        'Straight Leg Lifts',
        'Single Leg Lifts',
        'Around The Worlds',
        'Knee Crunches',
        'Holding Leg Lifts',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dataFuture = _store.load();
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    final data = await dataFuture;
    if (!mounted) return;
    setState(() {
      _plans = data.plans.isEmpty ? List.of(_starterPlans) : data.plans;
      _history = List.of(data.history);
      _weeklyGoal = data.weeklyGoal;
      _loading = false;
    });
    if (data.plans.isEmpty) _save();
  }

  Future<void> _save() => _store.save(
        plans: _plans,
        history: _history,
        weeklyGoal: _weeklyGoal,
      );

  WorkoutPlan get _nextWorkout => WorkoutEngine.nextWorkout(
        plans: _plans,
        lastCompleted: _history.isEmpty
            ? null
            : WorkoutPlan(
                id: _history.first.planId,
                name: _history.first.planName,
                exerciseCount: _history.first.exerciseCount,
              ),
      );

  Future<void> _startWorkout(WorkoutPlan plan) async {
    final record = await Navigator.of(context).push<WorkoutRecord>(
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(plan: plan),
      ),
    );
    if (!mounted || record == null) return;
    setState(() {
      _history.insert(0, record);
    });
    _save();
  }

  void _createPlan(
    String name,
    List<String> exercises,
    String? coverImageData,
  ) {
    final id = 'custom-${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _plans.add(
        WorkoutPlan(
          id: id,
          name: name,
          exerciseCount: exercises.length,
          exercises: exercises,
          coverImageData: coverImageData,
        ),
      );
    });
    _save();
  }

  void _updatePlan(WorkoutPlan plan) {
    setState(() {
      final index = _plans.indexWhere((item) => item.id == plan.id);
      if (index != -1) _plans[index] = plan;
    });
    _save();
  }

  void _deletePlan(WorkoutPlan plan) {
    setState(() {
      _plans.removeWhere((item) => item.id == plan.id);
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _SplashScreen();
    final screens = [
      HomeScreen(
        nextWorkout: _nextWorkout,
        history: _history,
        onStartWorkout: _startWorkout,
      ),
      PlansScreen(
        plans: _plans,
        onCreatePlan: _createPlan,
        onUpdatePlan: _updatePlan,
        onDeletePlan: _deletePlan,
        onStartWorkout: _startWorkout,
      ),
      HistoryScreen(history: _history),
      ProgressScreen(history: _history, weeklyGoal: _weeklyGoal),
      SettingsScreen(
        weeklyGoal: _weeklyGoal,
        onWeeklyGoalChanged: (value) {
          setState(() => _weeklyGoal = value);
          _save();
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppTheme.background,
        body: SizedBox.expand(
          child: Image(
            key: ValueKey('splash-logo'),
            image: AssetImage('assets/images/zenith_logo_splash.png'),
            fit: BoxFit.contain,
          ),
        ),
      );
}
