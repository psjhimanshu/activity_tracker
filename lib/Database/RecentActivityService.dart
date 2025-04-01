// lib/database/recent_activities_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class RecentActivitiesService {
  static const String _key = 'recent_activities';
  List<Map<String, String>> _recentActivities = [];

  // Load activities from SharedPreferences
  Future<void> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedActivities = prefs.getStringList(_key);
    if (savedActivities != null) {
      _recentActivities = savedActivities.map((e) {
        final parts = e.split('|');
        return {
          'activity': parts[0],
          'type': parts[1],
          'duration': parts[2],
        };
      }).toList();
    }
  }

  // Save an activity to SharedPreferences
  Future<void> saveActivity(String activity, String type, String duration) async {
    final prefs = await SharedPreferences.getInstance();
    _recentActivities.insert(0, {
      'activity': activity,
      'type': type,
      'duration': duration,
    });
    // Limit to 10 recent activities
    if (_recentActivities.length > 10) {
      _recentActivities = _recentActivities.sublist(0, 10);
    }
    await prefs.setStringList(
      _key,
      _recentActivities.map((e) => '${e['activity']}|${e['type']}|${e['duration']}').toList(),
    );
  }

  // Get the list of recent activities
  List<Map<String, String>> getActivities() {
    return _recentActivities;
  }

  // Clear all activities
  Future<void> clearActivities() async {
    final prefs = await SharedPreferences.getInstance();
    _recentActivities.clear();
    await prefs.remove(_key);
  }
}