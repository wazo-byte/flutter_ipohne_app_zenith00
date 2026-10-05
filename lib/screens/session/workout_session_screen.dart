import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_record.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutPlan plan;

  const WorkoutSessionScreen({super.key, required this.plan});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<List<_SetInput>> _sets;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _sets = List.generate(
      widget.plan.exerciseNames.length,
      (_) => [_SetInput()],
    );
    _stopwatch.start();
  }

  @override
  void dispose() {
    for (final exerciseSets in _sets) {
      for (final set in exerciseSets) {
        set.dispose();
      }
    }
    super.dispose();
  }

  void _finishWorkout() {
    if (!_formKey.currentState!.validate()) return;
    _stopwatch.stop();
    Navigator.of(context).pop(
      WorkoutRecord(
        planId: widget.plan.id,
        planName: widget.plan.name,
        completedAt: DateTime.now(),
        duration: _stopwatch.elapsed,
        exercises: List.generate(
          widget.plan.exerciseNames.length,
          (index) => ExerciseLog(
            exerciseName: widget.plan.exerciseNames[index],
            sets: _sets[index]
                .map((set) => WorkoutSet(
                      reps: int.parse(set.reps.text),
                      load: double.parse(set.load.text),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.plan.name)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                    'Log each set as you go. Your best lifts update when you finish.'),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  itemCount: widget.plan.exerciseNames.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ExerciseLogger(
                    name: widget.plan.exerciseNames[index],
                    sets: _sets[index],
                    onChanged: () => setState(() {}),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _finishWorkout,
                    child: const Text('Finish workout'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetInput {
  final reps = TextEditingController(text: '8');
  final load = TextEditingController(text: '0');

  void dispose() {
    reps.dispose();
    load.dispose();
  }
}

class _ExerciseLogger extends StatelessWidget {
  final String name;
  final List<_SetInput> sets;
  final VoidCallback onChanged;

  const _ExerciseLogger({
    required this.name,
    required this.sets,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 8),
            ...sets.indexed.map((entry) => Row(
                  children: [
                    SizedBox(width: 48, child: Text('Set ${entry.$1 + 1}')),
                    Expanded(
                        child: _NumberField(
                            controller: entry.$2.reps,
                            label: 'Reps',
                            integer: true)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _NumberField(
                            controller: entry.$2.load, label: 'Load kg')),
                    if (sets.length > 1)
                      IconButton(
                        tooltip: 'Remove set',
                        onPressed: () {
                          entry.$2.dispose();
                          sets.removeAt(entry.$1);
                          onChanged();
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                  ],
                )),
            TextButton.icon(
              onPressed: () {
                sets.add(_SetInput());
                onChanged();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add set'),
            ),
          ],
        ),
      );
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool integer;

  const _NumberField(
      {required this.controller, required this.label, this.integer = false});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, isDense: true),
        validator: (value) {
          final number = double.tryParse(value ?? '');
          if (number == null ||
              number < 0 ||
              (integer && number != number.roundToDouble()) ||
              (integer && number == 0)) {
            return 'Enter ${integer ? 'reps' : 'a load'}';
          }
          return null;
        },
      );
}
