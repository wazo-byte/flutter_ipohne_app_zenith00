import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';

typedef _PlanDraft = ({String name, List<String> exercises});

class PlansScreen extends StatelessWidget {
  final List<WorkoutPlan> plans;
  final void Function(String name, List<String> exercises) onCreatePlan;
  final ValueChanged<WorkoutPlan> onUpdatePlan;
  final ValueChanged<WorkoutPlan> onDeletePlan;
  final ValueChanged<WorkoutPlan> onStartWorkout;

  const PlansScreen({
    super.key,
    required this.plans,
    required this.onCreatePlan,
    required this.onUpdatePlan,
    required this.onDeletePlan,
    required this.onStartWorkout,
  });

  Future<void> _showPlanDialog(
    BuildContext context, {
    WorkoutPlan? plan,
  }) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: plan?.name ?? '');
    final exerciseControllers = plan == null
        ? List.generate(5, (_) => TextEditingController())
        : plan.exerciseNames
            .map((exercise) => TextEditingController(text: exercise))
            .toList();

    try {
      final result = await showDialog<_PlanDraft>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(plan == null ? 'Create a plan' : 'Edit plan'),
            content: SizedBox(
              width: 420,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.65,
                ),
                child: Form(
                  key: formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: nameController,
                        autofocus: plan == null,
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            const InputDecoration(labelText: 'Plan name'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a plan name'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      ...exerciseControllers.indexed.map((entry) {
                        final index = entry.$1;
                        final controller = entry.$2;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  key: ValueKey(controller),
                                  controller: controller,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    labelText: 'Exercise ${index + 1}',
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Enter an exercise name'
                                          : null,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove exercise',
                                onPressed: exerciseControllers.length == 1
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          exerciseControllers
                                              .removeAt(index)
                                              .dispose();
                                        });
                                      },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setDialogState(
                            () => exerciseControllers.add(
                              TextEditingController(),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add exercise'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(
                    context,
                    (
                      name: nameController.text.trim(),
                      exercises: exerciseControllers
                          .map((controller) => controller.text.trim())
                          .toList(),
                    ),
                  );
                },
                child: Text(plan == null ? 'Create' : 'Save'),
              ),
            ],
          ),
        ),
      );
      if (result == null) return;
      if (plan == null) {
        onCreatePlan(result.name, result.exercises);
      } else {
        onUpdatePlan(
          WorkoutPlan(
            id: plan.id,
            name: result.name,
            exerciseCount: result.exercises.length,
            exercises: result.exercises,
            category: plan.category,
            lastCompleted: plan.lastCompleted,
          ),
        );
      }
    } finally {
      nameController.dispose();
      for (final controller in exerciseControllers) {
        controller.dispose();
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WorkoutPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete plan?'),
        content: Text('“${plan.name}” will be removed from your plans.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) onDeletePlan(plan);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Workout Plans',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              ),
              IconButton.filled(
                tooltip: 'Create plan',
                onPressed: () => _showPlanDialog(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (plans.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No plans yet. Create one to get started.',
                  style: TextStyle(color: AppTheme.muted),
                ),
              ),
            ),
          ...plans.map(
            (plan) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.surface2,
                        child:
                            Icon(Icons.fitness_center, color: AppTheme.muted),
                      ),
                      title: Text(plan.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${plan.exerciseCount} exercises'),
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Plan options',
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showPlanDialog(context, plan: plan);
                          } else if (value == 'delete') {
                            _confirmDelete(context, plan);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit plan'),
                          ),
                          if (plans.length > 1)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete plan'),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: () => onStartWorkout(plan),
                          child: const Text('Start workout'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showPlanDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create New Plan'),
          ),
        ],
      ),
    );
  }
}
