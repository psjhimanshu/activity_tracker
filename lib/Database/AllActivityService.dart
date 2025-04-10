
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
