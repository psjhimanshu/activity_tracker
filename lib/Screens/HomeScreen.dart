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
  late final RecentActivitiesService _recentActivitiesService;

  @override
  void initState() {
    super.initState();
      super.initState();
      _recentActivitiesService = RecentActivitiesService(
        onLoadActivities: () {
          if (mounted) {
            setState(() {});
          }
        },
      );
      _recentActivitiesService.loadActivities();
  }


  Future<void> _loadActivities() async {
    await _recentActivitiesService.loadActivities();
    setState(() {});

  }

  // Suggestions for activities
  List<String> _getSuggestions() {
    final previousActivities = _recentActivitiesService
        .getActivities()
        .map((activity) => activity['activity']!)
        .toSet()
        .toList();
    final defaultSuggestions = ['Work', 'Study', 'Exercise', 'Meditation', 'Break'];
    return [...previousActivities, ...defaultSuggestions].toSet().toList();
  }

  Future<bool> _confirmSaveActivity(String activityName) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Activity'),
        content: Text('Do you want to save the activity "$activityName"?'),
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
    ) ??
        false;
  }

  Future<bool> _confirmSaveActivityTimer(String activityName) async {
    // Play sound
    await _audioPlayer.play(AssetSource('_vk.mp3'));

    // Show dialog
    final result = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Activity'),
          content: Text('Do you want to save the activity "$activityName"?'),
          actions: [
            TextButton(
              onPressed: () async {
                if (_audioPlayer.state == PlayerState.playing) {
                  await _audioPlayer.stop();
                }
                if (context.mounted) {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                if (_audioPlayer.state == PlayerState.playing) {
                  await _audioPlayer.stop();
                }
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }


  Future<bool> _confirmDeleteActivity(String activityName) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete the activity "$activityName"?'),
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
    ) ??
        false;
  }


  void _showInsufficientDataSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("No Data Entered! Please enter activity details."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
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
                "TrackDeed",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
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

  Widget HomeTabScreen1(TabController tabController) {
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
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _getSuggestions();
                            }
                            return _getSuggestions().where((String option) {
                              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            directActivityController.text = selection;
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: directActivityController,
                              focusNode: focusNode,
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
                            );
                          },
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
                        onPressed: () async {
                          if (directActivityController.text.isNotEmpty && directSelectedTime != null) {
                            bool shouldSave = true;
                            if (shouldSave) {
                              _recentActivitiesService.saveActivity(
                                directActivityController.text,
                                'Manual',
                                '${directSelectedTime!.hour.toString().padLeft(2, '0')}:${directSelectedTime!.minute.toString().padLeft(2, '0')}:00',
                              );
                              directActivityController.clear();
                              directSelectedTime = null;
                              FocusScope.of(context).unfocus();
                              // Already present, ensures focus is removed
                              await _loadActivities();
                              setState(() {});
                            }
                          }else{
                            _showInsufficientDataSnackBar();
                          }

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Recent Activities",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
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
                        activity['activity_name']!,
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            activity['type'] == 'Timer'
                                ? Icons.timer
                                : activity['type'] == 'Stopwatch'
                                ? Icons.watch_later
                                : Icons.edit,
                            color: Colors.purple.shade700,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool shouldDelete = await _confirmDeleteActivity(activity['activity_name']!);
                              if (shouldDelete) {
                                await _recentActivitiesService.deleteActivity(index);
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        if (activity['type'] == 'Timer') {
                          tabController.animateTo(1);
                          Future.delayed(Duration.zero, () {
                            setState(() {
                              activityController.text = activity['activity_name'] ?? '';
                              final durationParts = (activity['duration'] ?? '00:00:00').split(':');
                              selectedTime = TimeOfDay(
                                hour: int.tryParse(durationParts[0]) ?? 0,
                                minute: int.tryParse(durationParts[1]) ?? 0,
                              );
                            });
                          });
                        } else if (activity['type'] == 'Stopwatch') {
                          tabController.animateTo(2);
                          Future.delayed(Duration.zero, () {
                            setState(() {
                              stopwatchActivityController.text = activity['activity_name'] ?? '';
                            });
                          });
                        } else if (activity['type'] == 'Manual') {
                          tabController.animateTo(0);
                          Future.delayed(Duration.zero, () {
                            setState(() {
                              directActivityController.text = activity['activity_name'] ?? '';
                              final durationParts = (activity['duration'] ?? '00:00:00').split(':');
                              directSelectedTime = TimeOfDay(
                                hour: int.tryParse(durationParts[0]) ?? 0,
                                minute: int.tryParse(durationParts[1]) ?? 0,
                              );
                            });
                          });
                        }
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
  Timer? timer;
  int _secondRemaining = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  TimeOfDay? selectedTime;
  String _currentActivity = '';
  bool activityShowH2=true;
  String _initialDuration = '00:00:00';




  void _pauseTimer() {
    if (_isRunning) {
      timer?.cancel();
      _audioPlayer.stop();
      setState(() {
        _isRunning = false;
        _isPaused = true;
      });
    }
  }

  Future<void> _stopTimer() async {
    if (_isRunning || _isPaused) {
      timer?.cancel();
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


  void _resumeTimer() {
    if (_isPaused&&_secondRemaining > 0) {
      _audioPlayer.stop();
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });

      timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (_secondRemaining > 0) {
          setState(() => _secondRemaining--);
        } else {
          timer.cancel();
          await _confirmSaveActivityTimer(_currentActivity);
          await _saveTimerActivity();
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
            _loadActivities();// Clear activity when timer finishes
          });
        }
      });
    }
  }


  Future<void> _saveTimerActivity() async {
    if (_currentActivity.isNotEmpty) {
      bool shouldSave = await _confirmSaveActivity(_currentActivity);
      if (shouldSave) {
        await _recentActivitiesService.saveActivity(
          _currentActivity,
          'Timer',
          _initialDuration, // Use initial duration
        );
        setState(() {
          _loadActivities();
        });
      }
    }
  }

  void _startTimer() {
    if(activityController.text.isEmpty||selectedTime==null){
      _showInsufficientDataSnackBar();
      return;
    }
    activityShowH2=false;

    if (selectedTime == null) return;

    int hours = selectedTime!.hour;
    int minutes = selectedTime!.minute;

    if (hours <= 0 && minutes <= 0) return;

    if (!_isRunning && _secondRemaining == 0) {
      _secondRemaining = (hours * 3600) + (minutes * 60);
      if(activityController.text.isNotEmpty)
      _currentActivity = activityController.text;// Store the activity name

      _initialDuration = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';

      // _recentActivitiesService.saveActivity(_currentActivity, 'Timer', '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00');
    }

    activityController.clear();
    _audioPlayer.stop();
    setState(() {
      _isRunning = true;
      _isPaused = false;
      selectedTime = null;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_secondRemaining > 0) {
        setState(() => _secondRemaining--);
      } else {
        timer.cancel();
        activityShowH2=true;
        await _confirmSaveActivityTimer(_currentActivity);
        await _saveTimerActivity();
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
          _currentActivity = '';// Clear activity when timer finishes
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


  HomeTabScreen2() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: SingleChildScrollView( // Added to fix render overflow
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
                          onTap: _isRunning||_isPaused ? null : () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isRunning||_isPaused ? Colors.grey.shade400 : Colors.purple.shade700,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: _isRunning ||_isPaused? Colors.grey.shade200 : Colors.white,
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
              // In HomeTabScreen2, update the Row of buttons
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
                     _startTimer();
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
  Timer? stopwatchTimer;
  int _stopwatchSeconds = 0;
  bool _stopwatchRunning = false;
  bool _stopwatchPaused = false;
  String _stopwatchActivity = '';
  bool activityShowH3 = true;

  void _startStopwatch() {
    if(stopwatchActivityController.text.isEmpty){
      _showInsufficientDataSnackBar();
      return;
    }
    activityShowH3 = false;
    if (!_stopwatchRunning) {
      _stopwatchActivity = stopwatchActivityController.text;
      stopwatchActivityController.clear();
      FocusScope.of(context).unfocus();
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
      stopwatchTimer?.cancel();
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

  void _resetStopwatch() async {
    if (_stopwatchRunning || _stopwatchPaused) {
      stopwatchTimer?.cancel();
      if (_stopwatchActivity.isNotEmpty) {
        bool shouldSave = await _confirmSaveActivity(_stopwatchActivity);
        if (shouldSave) {
          _recentActivitiesService.saveActivity(
            _stopwatchActivity,
            'Stopwatch',
            _formatStopwatchTime(_stopwatchSeconds),
          );
        }
      }
      setState(() {
        _stopwatchSeconds = 0;
        _stopwatchRunning = false;
        _stopwatchPaused = false;
        _stopwatchActivity = '';
        activityShowH3 = true;
        stopwatchActivityController.clear(); // Add: Clear TextField when stopwatch resets
        FocusScope.of(context).unfocus();
      });
    }
  }

  String _formatStopwatchTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget HomeTabScreen3() {
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
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _getSuggestions();
                            }
                            return _getSuggestions().where((String option) {
                              return option.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            stopwatchActivityController.text = selection;
                          },
                          fieldViewBuilder: (context, controller, focusNode,
                              onFieldSubmitted) {
                            return TextField(
                              controller: stopwatchActivityController,
                              focusNode: focusNode,
                              enabled: activityShowH3,
                              decoration: InputDecoration(
                                labelText: "Enter Activity",
                                labelStyle: TextStyle(
                                    color: Colors.purple.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.purple.shade700),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
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
                      controller: TextEditingController(
                          text: _stopwatchActivity),
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
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: _stopwatchRunning
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _stopwatchRunning ? Colors.purple.shade700 : Colors
                        .grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  _formatStopwatchTime(_stopwatchSeconds),
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: _stopwatchRunning ? Colors.purple.shade700 : Colors
                        .white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Conditionally show Start or Stop button
                  _stopwatchRunning || _stopwatchPaused
                      ? ElevatedButton(
                    onPressed: _resetStopwatch,
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
                      _startStopwatch();
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
                  // Pause/Resume button
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
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }
  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    activityController.dispose();
    directActivityController.dispose();
    stopwatchActivityController.dispose();
    timer?.cancel();
    stopwatchTimer?.cancel();
    super.dispose();
  }
}