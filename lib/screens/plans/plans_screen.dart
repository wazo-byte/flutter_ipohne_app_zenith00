import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/workout_plan.dart';

class PlansScreen extends StatelessWidget {
  final List<WorkoutPlan> plans;
  final void Function(String name, int exerciseCount) onCreatePlan;
  final ValueChanged<WorkoutPlan> onDeletePlan;
  final ValueChanged<WorkoutPlan> onStartWorkout;

  const PlansScreen({
    super.key,
    required this.plans,
    required this.onCreatePlan,
    required this.onDeletePlan,
    required this.onStartWorkout,
  });

  Future<void> _showCreatePlanDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    var exerciseCount = 5;
    var planName = '';

    final result = await showDialog<(String, int)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create a plan'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Plan name'),
                  onSaved: (value) => planName = value?.trim() ?? '',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a plan name'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: exerciseCount,
                  decoration: const InputDecoration(labelText: 'Exercises'),
                  items: List.generate(8, (index) => index + 1)
                      .map(
                        (count) => DropdownMenuItem(
                          value: count,
                          child: Text('$count exercises'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => exerciseCount = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.pop(context, (planName, exerciseCount));
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (result != null) onCreatePlan(result.$1, result.$2);
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
                onPressed: () => _showCreatePlanDialog(context),
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
                      trailing: plans.length > 1
                          ? PopupMenuButton<String>(
                              tooltip: 'Plan options',
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _confirmDelete(context, plan);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete plan')),
                              ],
                            )
                          : null,
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
            onPressed: () => _showCreatePlanDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create New Plan'),
          ),
        ],
      ),
    );
  }
}
