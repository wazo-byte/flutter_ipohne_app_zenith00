
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_record.dart';
import '../../services/workout_engine.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutPlan plan;
  final List<WorkoutRecord> history;

  const WorkoutSessionScreen({
    super.key,
    required this.plan,
    this.history = const [],
  });

  @override
  State<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState
    extends State<WorkoutSessionScreen> {
  static const _incrementKey = 'workoutWeightIncrement';
  static const _increments = [0.5, 1.0, 2.5, 5.0];

  final _formKey = GlobalKey<FormState>();
  final Stopwatch _stopwatch = Stopwatch();

  late final List<List<_SetInput>> _sets;
  double _weightIncrement = 0.5;

  @override
  void initState() {
    super.initState();

    _sets = List.generate(
      widget.plan.exerciseNames.length,
      (index) {
        final previous = _latestPerformance(
          widget.plan.exerciseNames[index],
        );

        if (previous == null || previous.sets.isEmpty) {
          return [_SetInput()];
        }

        return previous.sets
            .map((set) => _SetInput(
                  reps: set.reps,
                  load: set.load,
                ))
            .toList();
      },
    );

    _stopwatch.start();
    _loadWeightIncrement();
  }

  ExerciseLog? _latestPerformance(String exerciseName) {
    return WorkoutEngine.latestExercisePerformance(
      history: widget.history,
      exerciseName: exerciseName,
    );
  }

  Future<void> _loadWeightIncrement() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getDouble(_incrementKey);

    if (!mounted) return;

    if (saved != null && _increments.contains(saved)) {
      setState(() => _weightIncrement = saved);
    }
  }

  Future<void> _saveWeightIncrement(double value) async {
    setState(() => _weightIncrement = value);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_incrementKey, value);
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

    final record = WorkoutRecord(
      planId: widget.plan.id,
      planName: widget.plan.name,
      completedAt: DateTime.now(),
      duration: _stopwatch.elapsed,
      exercises: List.generate(
        widget.plan.exerciseNames.length,
        (index) => ExerciseLog(
          exerciseName: widget.plan.exerciseNames[index],
          sets: _sets[index]
              .map(
                (set) => WorkoutSet(
                  reps: int.parse(set.reps.text),
                  load: double.parse(set.load.text),
                ),
              )
              .toList(),
        ),
      ),
    );

    Navigator.of(context).pop(record);
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
                  'Log each set as you go. Your previous performance '
                  'is loaded automatically.',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Weight increment',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownButton<double>(
                      value: _weightIncrement,
                      items: _increments.map((increment) {
                        final label =
                            increment == increment.roundToDouble()
                                ? increment.toInt().toString()
                                : increment.toString();

                        return DropdownMenuItem<double>(
                          value: increment,
                          child: Text('$label kg'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _saveWeightIncrement(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  itemCount: widget.plan.exerciseNames.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final name = widget.plan.exerciseNames[index];

                    return _ExerciseLogger(
                      key: ValueKey(
                        '${widget.plan.id}-$index-$name',
                      ),
                      name: name,
                      previous: _latestPerformance(name),
                      sets: _sets[index],
                      weightIncrement: _weightIncrement,
                      onChanged: () => setState(() {}),
                    );
                  },
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
  final TextEditingController reps;
  final TextEditingController load;

  _SetInput({int reps = 8, double load = 0})
      : reps = TextEditingController(text: reps.toString()),
        load = TextEditingController(text: _formatLoad(load));

  static String _formatLoad(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  void dispose() {
    reps.dispose();
    load.dispose();
  }
}

class _ExerciseLogger extends StatelessWidget {
  final String name;
  final ExerciseLog? previous;
  final List<_SetInput> sets;
  final double weightIncrement;
  final VoidCallback onChanged;

  const _ExerciseLogger({
    super.key,
    required this.name,
    required this.previous,
    required this.sets,
    required this.weightIncrement,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          if (previous != null) ...[
            const SizedBox(height: 4),
            Text(
              'Last session: ${previous!.sets.length} sets · '
              '${_SetInput._formatLoad(previous!.sets.first.load)} kg '
              '× ${previous!.sets.first.reps} reps',
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ...sets.indexed.map((entry) {
            final index = entry.$1;
            final set = entry.$2;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text('Set ${index + 1}'),
                  ),
                  Expanded(
                    child: _NumberField(
                      controller: set.reps,
                      label: 'Reps',
                      integer: true,
                      onChanged: onChanged,
                      actions: [
                        _StepAction(
                          icon: Icons.remove,
                          tooltip: 'Decrease reps',
                          onPressed: () => _adjust(
                            set.reps,
                            -1,
                            minimum: 1,
                            integer: true,
                          ),
                        ),
                        _StepAction(
                          icon: Icons.add,
                          tooltip: 'Increase reps',
                          onPressed: () => _adjust(
                            set.reps,
                            1,
                            minimum: 1,
                            integer: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NumberField(
                      controller: set.load,
                      label: 'Load kg',
                      onChanged: onChanged,
                      actions: [
                        _StepAction(
                          icon: Icons.remove,
                          tooltip: 'Decrease weight',
                          onPressed: () => _adjust(
                            set.load,
                            -weightIncrement,
                            minimum: 0,
                          ),
                        ),
                        _StepAction(
                          icon: Icons.add,
                          tooltip: 'Increase weight',
                          onPressed: () => _adjust(
                            set.load,
                            weightIncrement,
                            minimum: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sets.length > 1)
                    IconButton(
                      tooltip: 'Remove set',
                      onPressed: () {
                        set.dispose();
                        sets.removeAt(index);
                        onChanged();
                      },
                      icon: const Icon(
                        Icons.remove_circle_outline,
                      ),
                    ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () {
              final last = sets.isEmpty ? null : sets.last;

              sets.add(
                _SetInput(
                  reps: int.tryParse(last?.reps.text ?? '') ?? 8,
                  load: double.tryParse(last?.load.text ?? '') ?? 0,
                ),
              );
              onChanged();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add set'),
          ),
        ],
      ),
    );
  }

  static void _adjust(
    TextEditingController controller,
    double change, {
    required double minimum,
    bool integer = false,
  }) {
    final current = double.tryParse(controller.text) ?? minimum;
    final next =
        (current + change).clamp(minimum, double.infinity).toDouble();

    final value = integer
        ? next.round().toString()
        : _SetInput._formatLoad(next);

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

class _StepAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _StepAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool integer;
  final VoidCallback onChanged;
  final List<_StepAction> actions;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.actions,
    this.integer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(
            decimal: !integer,
          ),
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
          ),
          validator: (value) {
            final number = double.tryParse(value ?? '');

            if (number == null ||
                !number.isFinite ||
                number < 0 ||
                (integer && number != number.roundToDouble()) ||
                (integer && number == 0)) {
              return integer ? 'Enter reps' : 'Enter load';
            }

            return null;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: actions.map((action) {
            return IconButton(
              tooltip: action.tooltip,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
              onPressed: () {
                action.onPressed();
                onChanged();
              },
              icon: Icon(action.icon, size: 18),
            );
          }).toList(),
        ),
      ],
    );
  }
}
