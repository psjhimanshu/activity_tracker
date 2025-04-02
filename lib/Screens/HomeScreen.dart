import 'dart:async';
import 'package:activity/Database/RecentActivityService.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RecentActivitiesService _recentActivitiesService = RecentActivitiesService();

  @override
  void initState() {
    super.initState();
    _recentActivitiesService.loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Home Screen",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                indicator: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                tabs: [
                  Tab(text: "Direct"),
                  Tab(text: "By Timer"),
                  Tab(text: "By Counter"),
                ],
              ),
              backgroundColor: Colors.purple.shade700,
              elevation: 0,
            ),
            body: TabBarView(
              controller: tabController,
              children: [
                HomeTabScreen1(tabController),
                HomeTabScreen2(),
                HomeTabScreen3(),
              ],
            ),
          );
        },
      ),
    );
  }

  // HomeTabScreen1 Functionality (Direct)
  final directActivityController = TextEditingController();
  TimeOfDay? directSelectedTime;

  Future<void> _selectDirectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != directSelectedTime) {
      setState(() {
        directSelectedTime = picked;
      });
    }
  }

  HomeTabScreen1(TabController tabController) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recent Activities",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: directActivityController,
                          decoration: InputDecoration(
                            labelText: "Add Manual Activity",
                            labelStyle: TextStyle(color: Colors.purple.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple.shade700),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDirectTime(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.purple.shade700),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Text(
                              directSelectedTime != null
                                  ? '${directSelectedTime!.hour.toString().padLeft(2, '0')}:${directSelectedTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Select Time',
                              style: TextStyle(
                                fontSize: 16,
                                color: directSelectedTime != null ? Colors.black : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (directActivityController.text.isNotEmpty && directSelectedTime != null) {
                            // Check for duplicate activity
                            bool exists = _recentActivitiesService
                                .getActivities()
                                .any((activity) => activity['activity'] == directActivityController.text);
                            if (exists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Activity '${directActivityController.text}' already exists! Consider updating it.",
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            } else {
                              _recentActivitiesService.saveActivity(
                                directActivityController.text,
                                'Manual',
                                '${directSelectedTime!.hour.toString().padLeft(2, '0')}:${directSelectedTime!.minute.toString().padLeft(2, '0')}:00',
                              );
                              directActivityController.clear();
                              directSelectedTime = null;
                              setState(() {});
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _recentActivitiesService.getActivities().isEmpty
                  ? const Center(
                child: Text(
                  "No recent activities yet.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentActivitiesService.getActivities().length,
                itemBuilder: (context, index) {
                  final activity = _recentActivitiesService.getActivities()[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        activity['activity']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      subtitle: Text(
                        'Type: ${activity['type']} | Duration: ${activity['duration']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Icon(
                        activity['type'] == 'Timer'
                            ? Icons.timer
                            : activity['type'] == 'Stopwatch'
                            ? Icons.watch_later
                            : Icons.handyman,
                        color: Colors.purple.shade700,
                      ),
                      onTap: () {
                        // Navigate to Timer tab for all activities
                        tabController.animateTo(1);
                        setState(() {
                          activityController.text = activity['activity']!;
                          final durationParts = activity['duration']!.split(':');
                          selectedTime = TimeOfDay(
                            hour: int.parse(durationParts[0]),
                            minute: int.parse(durationParts[1]),
                          );
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HomeTabScreen2 Functionality (Timer)
  final activityController = TextEditingController();
  late Timer timer;
  int _secondRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  TimeOfDay? selectedTime;
  String _currentActivity = '';
  bool activityShowH2 = true;

  void _playSound() async {
    await _audioPlayer.play(AssetSource('_vk.mp3'));
    Timer(const Duration(seconds: 3), () {
      _audioPlayer.stop();
    });
  }

  void _pauseTimer() {
    if (_isRunning) {
      timer.cancel();
      _audioPlayer.stop();
      setState(() {
        _isRunning = false;
        _isPaused = true;
      });
    }
  }

  void _resumeTimer() {
    if (_isPaused && _secondRemaining > 0) {
      _audioPlayer.stop();
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });

      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondRemaining > 0) {
          setState(() => _secondRemaining--);
        } else {
          timer.cancel();
          _playSound();
          // Check for duplicate activity before saving
          bool exists = _recentActivitiesService
              .getActivities()
              .any((activity) => activity['activity'] == _currentActivity);
          if (exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Activity '$_currentActivity' already exists! Consider updating it.",
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            // Save activity only when timer ends naturally
            int hours = _secondRemaining ~/ 3600;
            int minutes = (_secondRemaining % 3600) ~/ 60;
            _recentActivitiesService.saveActivity(
              _currentActivity,
              'Timer',
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00',
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Timer Finished!"),
              backgroundColor: Colors.purple,
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            _isRunning = false;
            _isPaused = false;
            _currentActivity = '';
          });
        }
      });
    }
  }

  void _stopTimer() {
    if (_isRunning || _isPaused) {
      timer.cancel();
      _audioPlayer.stop();
      setState(() {
        _secondRemaining = 0;
        _isRunning = false;
        _isPaused = false;
        _currentActivity = '';
        activityShowH2 = true;
        selectedTime = null;
      });
    }
  }

  void _startTimer() {
    activityShowH2 = false;

    if (selectedTime == null) return;

    int hours = selectedTime!.hour;
    int minutes = selectedTime!.minute;

    if (hours <= 0 && minutes <= 0) return;

    if (!_isRunning && _secondRemaining == 0) {
      _secondRemaining = (hours * 3600) + (minutes * 60);
      _currentActivity = activityController.text;
      // Do not save activity here; save only when timer ends
    }

    activityController.clear();
    _audioPlayer.stop();
    setState(() {
      _isRunning = true;
      _isPaused = false;
      selectedTime = null;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondRemaining > 0) {
        setState(() => _secondRemaining--);
      } else {
        timer.cancel();
        activityShowH2 = true;
        _playSound();
        // Check for duplicate activity before saving
        bool exists = _recentActivitiesService
            .getActivities()
            .any((activity) => activity['activity'] == _currentActivity);
        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Activity '$_currentActivity' already exists! Consider updating it.",
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Save activity only when timer ends naturally
          int hours = _secondRemaining ~/ 3600;
          int minutes = (_secondRemaining % 3600) ~/ 60;
          _recentActivitiesService.saveActivity(
            _currentActivity,
            'Timer',
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00',
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Timer Finished!"),
            backgroundColor: Colors.purple,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _isRunning = false;
          _isPaused = false;
          _currentActivity = '';
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    activityController.dispose();
    directActivityController.dispose();
    stopwatchActivityController.dispose();
    if (_isRunning) timer.cancel();
    super.dispose();
  }

  HomeTabScreen2() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: activityController,
                          enabled: activityShowH2,
                          decoration: InputDecoration(
                            labelText: "Enter Activity",
                            labelStyle: TextStyle(color: Colors.purple.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple.shade700),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _isRunning || _isPaused ? null : () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isRunning || _isPaused ? Colors.grey.shade400 : Colors.purple.shade700,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: _isRunning || _isPaused ? Colors.grey.shade200 : Colors.white,
                            ),
                            child: Text(
                              selectedTime != null
                                  ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Select Time',
                              style: TextStyle(
                                fontSize: 16,
                                color: _isRunning
                                    ? Colors.grey
                                    : (selectedTime != null ? Colors.black : Colors.grey),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_currentActivity.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: TextEditingController(text: _currentActivity),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Current Activity",
                        labelStyle: TextStyle(color: Colors.purple.shade700),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: _isRunning ? Colors.purple.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _isRunning ? Colors.purple.shade700 : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  _formatTime(_secondRemaining),
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: _isRunning ? Colors.purple.shade700 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isRunning || _isPaused
                      ? ElevatedButton(
                    onPressed: _stopTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                      : ElevatedButton(
                    onPressed: () {
                      if (activityController.text.isNotEmpty && selectedTime != null) {
                        _startTimer();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isRunning || _isPaused
                        ? () {
                      if (_isPaused) {
                        _resumeTimer();
                      } else {
                        _pauseTimer();
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HomeTabScreen3 Functionality (Stopwatch)
  final stopwatchActivityController = TextEditingController();
  late Timer stopwatchTimer;
  int _stopwatchSeconds = 0;
  bool _stopwatchRunning = false;
  bool _stopwatchPaused = false;
  String _stopwatchActivity = '';
  bool activityShowH3 = true;

  void _startStopwatch() {
    activityShowH3 = false;
    if (!_stopwatchRunning) {
      _stopwatchActivity = stopwatchActivityController.text;
      stopwatchActivityController.clear();
      setState(() {
        _stopwatchRunning = true;
        _stopwatchPaused = false;
      });

      stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _stopwatchSeconds++;
        });
      });
    }
  }

  void _pauseStopwatch() {
    if (_stopwatchRunning) {
      stopwatchTimer.cancel();
      setState(() {
        _stopwatchRunning = false;
        _stopwatchPaused = true;
      });
    }
  }

  void _resumeStopwatch() {
    if (_stopwatchPaused) {
      setState(() {
        _stopwatchRunning = true;
        _stopwatchPaused = false;
      });

      stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _stopwatchSeconds++;
        });
      });
    }
  }

  void _resetStopwatch() {
    if (_stopwatchRunning || _stopwatchPaused) {
      stopwatchTimer.cancel();
      // Check for duplicate activity before saving
      bool exists = _recentActivitiesService
          .getActivities()
          .any((activity) => activity['activity'] == _stopwatchActivity);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Activity '$_stopwatchActivity' already exists! Consider updating it.",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        _recentActivitiesService.saveActivity(
          _stopwatchActivity,
          'Stopwatch',
          _formatStopwatchTime(_stopwatchSeconds),
        );
      }
      setState(() {
        _stopwatchSeconds = 0;
        _stopwatchRunning = false;
        _stopwatchPaused = false;
        _stopwatchActivity = '';
        activityShowH3 = true;
      });
    }
  }

  String _formatStopwatchTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  HomeTabScreen3() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: stopwatchActivityController,
                          enabled: activityShowH3,
                          decoration: InputDecoration(
                            labelText: "Enter Activity",
                            labelStyle: TextStyle(color: Colors.purple.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple.shade700),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_stopwatchRunning || _stopwatchPaused) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: TextEditingController(text: _stopwatchActivity),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Current Activity",
                        labelStyle: TextStyle(color: Colors.purple.shade700),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: _stopwatchRunning ? Colors.purple.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _stopwatchRunning ? Colors.purple.shade700 : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  _formatStopwatchTime(_stopwatchSeconds),
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: _stopwatchRunning ? Colors.purple.shade700 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _stopwatchRunning
                        ? null
                        : () {
                      if (stopwatchActivityController.text.isNotEmpty) {
                        _startStopwatch();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _stopwatchRunning || _stopwatchPaused
                        ? () {
                      if (_stopwatchPaused) {
                        _resumeStopwatch();
                      } else {
                        _pauseStopwatch();
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Icon(
                      _stopwatchPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _stopwatchRunning || _stopwatchPaused ? _resetStopwatch : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}