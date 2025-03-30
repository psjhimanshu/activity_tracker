import 'dart:async';
import 'package:flutter/material.dart';

class Demohome extends StatefulWidget {
  final String activity;
  final int minutes;

  Demohome({required this.activity, required this.minutes});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<Demohome> {
  late Timer _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.minutes * 60;
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.activity)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_secondsRemaining),
              style: TextStyle(fontSize: 48),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRunning ? null : _startTimer,
              child: Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}