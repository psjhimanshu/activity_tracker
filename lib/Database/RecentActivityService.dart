// lib/Database/RecentActivityService.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentActivitiesService{

  static const String _key = 'recent_activities';
  List<Map<String, String>> _recentActivities = [];

  final VoidCallback onLoadActivities;
  RecentActivitiesService({required this.onLoadActivities});


  Future<void> loadActivities() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in
      _recentActivities = [];
      return;
    }

    final userId = user.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentSnapshot userDoc = await firestore.collection('userData').doc(userId).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;

      if (data.containsKey('recents') && data['recents'] is List) {
        List<dynamic> recentsList = data['recents'];

        _recentActivities = recentsList.map<Map<String, String>>((item) {
          return {
            'activity_name': (item['activity_name'] ?? '').toString(),
            'type': (item['type'] ?? '').toString(),
            'duration': (item['duration'] ?? '').toString(),
            'activity_id': (item ['activity_id'] ?? '').toString(),
          };
        }).toList();
      } else {
        _recentActivities = [];
      }
    } else {
      _recentActivities = [];
    }
      onLoadActivities();
  }


  Duration parseDuration(String timeStr) {
    List<String> parts = timeStr.split(":");
    if (parts.length != 3) return Duration.zero;
    int hours = int.tryParse(parts[0]) ?? 0;
    int minutes = int.tryParse(parts[1]) ?? 0;
    int seconds = int.tryParse(parts[2]) ?? 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }



  Future<void> saveActivity(String activity, String type, String durationStr) async {
    print("called save method");

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _recentActivities = [];
      return;
    }

    final userId = user.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Parse duration and compute start/end time
    Duration duration = parseDuration(durationStr);
    DateTime endTime = DateTime.now();
    DateTime startTime = endTime.subtract(duration);


    print("Parsed duration: $duration minutes");
    print("Start time: $startTime");
    print("End time: $endTime");

    // Step 1: Check for overlap in 'activities'
    final overlapSnapshot = await firestore
        .collection('userData')
        .doc(userId)
        .collection('activities')
        .where('end_time', isGreaterThanOrEqualTo: startTime)
        .get();

    for (var doc in overlapSnapshot.docs) {
      DateTime existingStart = (doc['start_time'] as Timestamp).toDate();
      DateTime existingEnd = (doc['end_time'] as Timestamp).toDate();

      if (startTime.isBefore(existingEnd) && endTime.isAfter(existingStart)) {
        throw Exception("Overlapping activity detected. Please try again later.");
      }
    }

    // Step 2: Save activity to 'activities' subcollection
    DocumentReference activityRef = await firestore
        .collection('userData')
        .doc(userId)
        .collection('activities')
        .add({
      'activity_name': activity,
      'start_time': startTime,
      'end_time': endTime,
    });

    String activityId = activityRef.id;

    // Step 3: Update recents
    DocumentReference userDoc = firestore.collection('userData').doc(userId);
    DocumentSnapshot snapshot = await userDoc.get();
    List<Map<String, dynamic>> currentRecents = [];

    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data() as Map<String, dynamic>;
      final recentsData = data['recents'];
      if (recentsData is List) {
        currentRecents = List<Map<String, dynamic>>.from(recentsData);
      }
    }

    currentRecents.insert(0, {
      'activity_name': activity,
      'type': type,
      'duration': durationStr,
      'activity_id': activityId,
    });

    print(activityId);
    if (currentRecents.length > 10) {
      currentRecents = currentRecents.sublist(0, 10);
    }

    await userDoc.update({'recents': currentRecents});
    await loadActivities();
    AllActivityService.notifyUpdate();
  }



  Future<void> deleteActivity(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('userData').doc(userId);

    if (index < 0 || index >= _recentActivities.length) return;

    // Step 1: Get the activity_id from the local list
    String? activityId = _recentActivities[index]['activity_id'];
    print(activityId);
    print(_recentActivities[index]);
    if (activityId != null && activityId.isNotEmpty) {
      // Step 2: Delete from 'activities' subcollection
      await firestore
          .collection('userData')
          .doc(userId)
          .collection('activities')
          .doc(activityId)
          .delete();
    }

    // Step 3: Remove from local recent list
    _recentActivities.removeAt(index);
    // Step 4: Update Firestore 'recents' with new list
    await userDoc.update({'recents': _recentActivities});
    AllActivityService.notifyUpdate();
  }




  List<Map<String, String>> getActivities() {
    return _recentActivities;
  }

  Future<void> clearActivities() async {
    final prefs = await SharedPreferences.getInstance();
    _recentActivities.clear();
    await prefs.remove(_key);
  }
}


class AllActivityService{
  static VoidCallback? onUpdate;

  static void registerCallback(VoidCallback callback) {
    onUpdate = callback;
  }

  static void notifyUpdate() {
    onUpdate?.call();
  }

  static Future<List<Map<String, dynamic>>> fetchAllActivities() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userId = user.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch all activity documents
    final querySnapshot = await firestore
        .collection('userData')
        .doc(userId)
        .collection('activities')
        .orderBy('end_time', descending: true)
        .get();

    // Convert each document to a map, converting Timestamp to DateTime
    List<Map<String, dynamic>> activities = querySnapshot.docs.map((doc) {
      final data = _convertTimestamps(doc.data());
      data['id'] = doc.id; // include document ID
      return data;
    }).toList();

    return activities;
  }
  static Map<String, dynamic> _convertTimestamps(Map<String, dynamic> map) {
    final newMap = <String, dynamic>{};

    map.forEach((key, value) {
      if (value is Timestamp) {
        newMap[key] = value.toDate();
      } else if (value is Map<String, dynamic>) {
        newMap[key] = _convertTimestamps(value);
      } else if (value is List) {
        newMap[key] = value.map((item) {
          if (item is Timestamp) return item.toDate();
          if (item is Map<String, dynamic>) return _convertTimestamps(item);
          return item;
        }).toList();
      } else {
        newMap[key] = value;
      }
    });

    return newMap;
  }
}
