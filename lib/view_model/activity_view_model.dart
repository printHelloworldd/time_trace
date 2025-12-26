import 'package:flutter/material.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/model/activity_model.dart';
import 'package:time_trace/service/activity_service.dart';

class ActivityViewModel extends ChangeNotifier {
  final ActivityService activityService;

  ActivityViewModel({required this.activityService}) {
    init();
  }

  List<ActivityModel> _todayActivities = [];
  bool _isLoading = false;
  String? _error;
  Map<CategoryModel, int> _categoryStatsForToday = {};
  Map<String, Map<CategoryModel, int>> _weeklyCategoryStats = {};

  List<ActivityModel> get todayActivities => _todayActivities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<CategoryModel, int> get categoryStatsForToday => _categoryStatsForToday;
  Map<String, Map<CategoryModel, int>> get weeklyCategoryStats =>
      _weeklyCategoryStats;

  Future<void> init() async {
    await loadTodayActivities();
    await loadDailyStats();
    await loadWeeklyStats();
  }

  Future<void> loadTodayActivities() async {
    _setLoading(true);
    try {
      _todayActivities = await activityService.getTodayActivities();

      _error = null;
    } catch (e) {
      _error = 'Failed to load activities: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addActivity({
    required String title,
    required int hour,
    required CategoryModel category,
  }) async {
    try {
      final now = DateTime.now();

      final activity = ActivityModel(
        title: title,
        category: category,
        date: now,
        hour: hour,
        createdAt: now,
      );

      await activityService.addActivity(activity);
      await init();
    } catch (e) {
      _error = 'Failed to add activity: $e';
      notifyListeners();
    }
  }

  Future<void> updateActivity(ActivityModel activity) async {
    try {
      await activityService.updateActivity(activity);
      await init();
    } catch (e) {
      _error = 'Failed to update activity: $e';
      notifyListeners();
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      await activityService.deleteActivity(id);
      await init();
    } catch (e) {
      _error = 'Failed to delete activity: $e';
      notifyListeners();
    }
  }

  Future<void> loadWeeklyStats() async {
    try {
      _weeklyCategoryStats = await activityService.getWeeklyStats();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load weekly report: $e';
      notifyListeners();
    }
  }

  Future<void> loadDailyStats() async {
    try {
      final now = DateTime.now();

      _categoryStatsForToday = await activityService.getCategoryStatsForDate(
        now,
      );

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load daily report: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
