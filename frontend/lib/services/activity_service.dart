import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rh_plus/utils/constants.dart';
import 'package:flutter/foundation.dart';

class ActivityModel {
  final String title;
  final String description;
  final String type;
  final DateTime timestamp;
  
  ActivityModel({
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
  });
  
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      title: json['title'],
      description: json['description'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class DashboardSummary {
  final int employeeCount;
  final int candidateCount;
  final String payrollPeriod;
  final int upcomingTrainingsCount;
  final List<ActivityModel> recentActivities;
  
  DashboardSummary({
    required this.employeeCount,
    required this.candidateCount,
    required this.payrollPeriod,
    required this.upcomingTrainingsCount,
    required this.recentActivities,
  });
}

class ActivityService {
  final String token;
  
  ActivityService({required this.token});
    Future<List<ActivityModel>> getRecentActivities() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/core/activities/recent/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ActivityModel.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print('Failed to load activities: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching activities: $e');
      }
      return [];
    }
  }
    Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/core/activities/dashboard-summary/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract activities from the response
        final List<dynamic> activitiesData = data['recent_activities'] ?? [];
        final recentActivities = activitiesData
            .map((json) => ActivityModel.fromJson(json))
            .toList();
            
        return DashboardSummary(
          employeeCount: data['employee_count'] ?? 0,
          candidateCount: data['candidate_count'] ?? 0,
          payrollPeriod: data['payroll_period'] ?? 'Sin período activo',
          upcomingTrainingsCount: data['upcoming_trainings_count'] ?? 0,
          recentActivities: recentActivities,
        );
      } else {
        if (kDebugMode) {
          print('Failed to load dashboard summary: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        
        // Return default values as fallback if API request fails
        return DashboardSummary(
          employeeCount: 0,
          candidateCount: 0,
          payrollPeriod: 'Sin datos',
          upcomingTrainingsCount: 0,
          recentActivities: [],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching dashboard summary: $e');
      }
      
      // Return default values on exception
      return DashboardSummary(
        employeeCount: 0,
        candidateCount: 0,
        payrollPeriod: 'Sin datos',
        upcomingTrainingsCount: 0,
        recentActivities: [],
      );
    }
  }
}
