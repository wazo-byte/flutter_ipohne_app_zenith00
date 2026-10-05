import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_plan.dart';
import '../models/workout_record.dart';

class LocalStore {
  static const _plansKey = 'plans';
  static const _historyKey = 'history';
  static const _weeklyGoalKey = 'weeklyGoal';

  Future<
      ({
        List<WorkoutPlan> plans,
        List<WorkoutRecord> history,
        int weeklyGoal
      })> load() async {
    final preferences = await SharedPreferences.getInstance();
    return (
      plans: _decodePlans(preferences.getString(_plansKey)),
      history: _decodeHistory(preferences.getString(_historyKey)),
      weeklyGoal: preferences.getInt(_weeklyGoalKey) ?? 4,
    );
  }

  Future<void> save({
    required List<WorkoutPlan> plans,
    required List<WorkoutRecord> history,
    required int weeklyGoal,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
        _plansKey, jsonEncode(plans.map((plan) => plan.toJson()).toList()));
    await preferences.setString(_historyKey,
        jsonEncode(history.map((record) => record.toJson()).toList()));
    await preferences.setInt(_weeklyGoalKey, weeklyGoal);
  }

  List<WorkoutPlan> _decodePlans(String? value) => value == null
      ? const []
      : (jsonDecode(value) as List)
          .map((item) =>
              WorkoutPlan.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

  List<WorkoutRecord> _decodeHistory(String? value) => value == null
      ? const []
      : (jsonDecode(value) as List)
          .map((item) =>
              WorkoutRecord.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
}
