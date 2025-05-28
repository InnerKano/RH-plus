import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class DashboardProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic> _summaryData = {};
  List<Map<String, dynamic>> _recentActivities = [];
  String? _token;

  bool get isLoading => _isLoading;
  Map<String, dynamic> get summaryData => _summaryData;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  void setToken(String? token) {
    _token = token;
  }

  Future<void> loadDashboardData() async {
    if (_token == null) return;

    print('DashboardProvider: Loading dashboard data...');
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadSummaryData(),
        _loadRecentActivities(),
      ]);
    } catch (e) {
      print('DashboardProvider: Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSummaryData() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/core/activities/dashboard_summary/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        _summaryData = json.decode(response.body);
        print('DashboardProvider: Summary data loaded: $_summaryData');
      } else {
        print('DashboardProvider: Error loading summary: ${response.statusCode}');
      }
    } catch (e) {
      print('DashboardProvider: Exception loading summary: $e');
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/core/activities/recent/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _recentActivities = List<Map<String, dynamic>>.from(data['results'] ?? data);
        print('DashboardProvider: Recent activities loaded: ${_recentActivities.length} items');
      } else {
        print('DashboardProvider: Error loading activities: ${response.statusCode}');
      }
    } catch (e) {
      print('DashboardProvider: Exception loading activities: $e');
    }
  }
}
