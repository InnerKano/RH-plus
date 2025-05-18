import 'package:flutter/foundation.dart';
import 'package:rh_plus/services/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityService _activityService;
  List<ActivityModel> _activities = [];
  DashboardSummary? _dashboardSummary;
  bool _isLoading = false;
  String? _error;

  ActivityProvider({required String token})
      : _activityService = ActivityService(token: token);

  List<ActivityModel> get activities => _activities;
  DashboardSummary? get dashboardSummary => _dashboardSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecentActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _activityService.getRecentActivities();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching activities: $_error');
      }
      notifyListeners();
    }
  }

  Future<void> fetchDashboardSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardSummary = await _activityService.getDashboardSummary();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching dashboard summary: $_error');
      }
      notifyListeners();
    }
  }
  
  // Helper method to refresh all dashboard data
  Future<void> refreshDashboardData() async {
    try {
      await Future.wait([
        fetchDashboardSummary(),
        fetchRecentActivities(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing dashboard data: $e');
      }
    }
  }
}
