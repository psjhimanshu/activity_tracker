import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final activityController = TextEditingController();
  late Timer timer;
  int _secondRemaining = 0;
  bool _isRunning = false;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
  }

  void _pauseTimer() {
    if (_isRunning) {
      timer.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _startTimer() {
    if (selectedTime == null) return;

    int hours = selectedTime!.hour;
    int minutes = selectedTime!.minute;

    if (hours <= 0 && minutes <= 0) return;

    if (!_isRunning && _secondRemaining == 0) {
      _secondRemaining = (hours * 3600) + (minutes * 60);
    }

    activityController.clear();
    setState(() {
      _isRunning = true;
      selectedTime = null;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondRemaining > 0) {
        setState(() => _secondRemaining--);
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
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

  @override
  void dispose() {
    activityController.dispose();
    if (_isRunning) timer.cancel();
    super.dispose();
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Home Screen",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Direct"),
              Tab(text: "By Timer"),
              Tab(text: "By Counter"),
            ],
          ),
          backgroundColor: Colors.purple.shade700,
          elevation: 0,
        ),
        body: TabBarView(children: [
            HomeTabScreen1(),
          HomeTabScreen2(),
      HomeTabScreen3(),
        ]),
      ),
    );
  }

  HomeTabScreen1() {
    return Center(child: Text("This is Sub Screen 1"));
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.purple.shade700),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Text(
                            selectedTime != null
                                ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                : 'Select Time',
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedTime != null ? Colors.black : Colors.grey,
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
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (activityController.text.isNotEmpty && selectedTime != null) {
                      if (!_isRunning) {
                        _startTimer();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Start Timer",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                //Pause button ka code h testing ke liye liya tha agr  chaiye to uncomment kr dena

                // SizedBox(width: 20),
                // ElevatedButton(
                //   onPressed: _isRunning ? _pauseTimer : null,
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.redAccent,
                //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     elevation: 5,
                //   ),
                //   child: Text(
                //     "Pause",
                //     style: TextStyle(fontSize: 16, color: Colors.white),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 50),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: BoxDecoration(
                color: _isRunning ? Colors.teal.withOpacity(0.1) : Colors.transparent,
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
          ],
        ),
      ),
    );
  }

  HomeTabScreen3() {
    return Center(child: Text("This is Sub Screen 3"));
  }
}