import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:activity/Screens/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _improvementMode = 'normal';
  List<String> _freqHabits = [];
  List<double> _freqDurations = [];
  final TextEditingController _activityController = TextEditingController();
  TimeOfDay? _selectedDuration;
  final int _maxInputs = 5; // अधिकतम 5 इनपुट

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSharedPreferences(); // SharedPreferences से डेटा लोड
  }

  Future<void> _loadSettings() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      DocumentSnapshot snapshot = await _firestore.collection('userData').doc(userId).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('settings')) {
          final settings = data['settings'] as Map<String, dynamic>?;
          setState(() {
            _improvementMode = settings?['improvement_mode'] ?? 'normal';
          });
        } else {
          await _firestore.collection('userData').doc(userId).set({
            'settings': {'improvement_mode': 'normal'},
          }, SetOptions(merge: true));
          setState(() {
            _improvementMode = 'normal';
          });
        }
      } else {
        await _firestore.collection('userData').doc(userId).set({
          'settings': {'improvement_mode': 'normal'},
        });
        setState(() {
          _improvementMode = 'normal';
        });
      }
    } catch (e) {
      print("Load settings error: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load settings: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _freqHabits = prefs.getStringList('freq_habits') ?? [];
      _freqDurations = prefs.getStringList('freq_durations')?.map(double.parse).toList() ?? [];
    });
  }

  Future<void> _saveSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('freq_habits', _freqHabits);
    await prefs.setStringList('freq_durations', _freqDurations.map((d) => d.toString()).toList());
  }

  Future<void> _toggleImprovementMode() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      String newMode = _improvementMode == 'normal' ? 'advanced' : 'normal';
      await _firestore.collection('userData').doc(userId).update({
        'settings': {'improvement_mode': newMode},
      });
      setState(() {
        _improvementMode = newMode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to toggle mode: $e")),
      );
    }
  }

  Future<void> _addFrequentActivity() async {
    if (_activityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an activity!")),
      );
      return;
    }
    if (_freqHabits.length >= _maxInputs) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 5 activities allowed!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      _freqHabits.add(_activityController.text);
      await _saveSharedPreferences();
      _activityController.clear();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add activity: $e")),
      );
    }
  }

  Future<void> _selectDuration(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDuration ?? const TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDuration) {
      setState(() {
        _selectedDuration = picked;
      });
    }
  }

  Future<void> _addFrequentDuration() async {
    if (_selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a duration!")),
      );
      return;
    }
    if (_freqDurations.length >= _maxInputs) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 5 durations allowed!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      double durationInHours = _selectedDuration!.hour + (_selectedDuration!.minute / 60.0);
      _freqDurations.add(durationInHours);
      await _saveSharedPreferences();
      setState(() {
        _selectedDuration = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add duration: $e")),
      );
    }
  }

  Future<void> _clearAllData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to clear all data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true);
      try {
        QuerySnapshot activitiesSnapshot = await _firestore
            .collection('userData')
            .doc(userId)
            .collection('activities')
            .get();
        for (var doc in activitiesSnapshot.docs) {
          await doc.reference.delete();
        }
        await _firestore.collection('userData').doc(userId).update({'recents': []});
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('freq_habits');
        await prefs.remove('freq_durations');
        setState(() {
          _freqHabits = [];
          _freqDurations = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear data: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      DocumentSnapshot snapshot = await _firestore.collection('userData').doc(userId).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('settings')) {
          final settings = data['settings'] as Map<String, dynamic>?;
          setState(() {
            _improvementMode = settings?['improvement_mode'] ?? 'normal';
            _freqHabits = List<String>.from(settings?['freq_habits'] ?? []);
            _freqDurations = List<double>.from(settings?['freq_durations'] ?? []);
          });
          await _saveSharedPreferences(); // Fetch के बाद SharedPreferences अपडेट
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch data: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully!')),
      );
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: SwitchListTile(
                  title: const Text('Improvement Mode'),
                  subtitle: Text(_improvementMode ?? 'normal'),
                  value: _improvementMode == 'advanced',
                  onChanged: (_) => _toggleImprovementMode(),
                  activeColor: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: _improvementMode == 'advanced',
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ListTile(
                        title: Text('Frequent Activities'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _activityController,
                                decoration: InputDecoration(
                                  labelText: 'Add Activity',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _freqHabits.length >= _maxInputs ? null : _addFrequentActivity,
                              child: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ..._freqHabits.map((habit) => ListTile(
                        title: Text(habit),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _freqHabits.remove(habit));
                            _saveSharedPreferences();
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: _improvementMode == 'advanced',
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ListTile(
                        title: Text('Frequent Duration'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _freqDurations.length >= _maxInputs ? null : () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedDuration ?? const TimeOfDay(hour: 0, minute: 0),
                                    builder: (BuildContext context, Widget? child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null && picked != _selectedDuration) {
                                    setState(() {
                                      _selectedDuration = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _freqDurations.length >= _maxInputs ? Colors.grey : Colors.purple.shade700,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: _freqDurations.length >= _maxInputs ? Colors.grey.shade200 : Colors.white,
                                  ),
                                  child: Text(
                                    _selectedDuration != null
                                        ? '${_selectedDuration!.hour.toString().padLeft(2, '0')}:${_selectedDuration!.minute.toString().padLeft(2, '0')}'
                                        : 'Select Duration',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedDuration != null ? Colors.black : Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _freqDurations.length >= _maxInputs ? null : _addFrequentDuration,
                              child: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ..._freqDurations.map((duration) => ListTile(
                        title: Text('$duration hours'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _freqDurations.remove(duration));
                            _saveSharedPreferences();
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _fetchData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'fetch data',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _clearAllData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Clear All Data from this Account',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }
}