import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final activity_Controller=TextEditingController();
  final timer_Controller=TextEditingController();
  final hoursController=TextEditingController();
  late Timer timer;
  int _secondRemaining=0;
  bool _isRunning=false;

@override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
void _pauseTimer(){
  if(_isRunning){
    timer.cancel();
    setState(() {
      _isRunning=false;
    });
  }
}

  void _startTimer(){
  int? minutes=int.tryParse(timer_Controller.text)??0;
  int? hours=int.tryParse(hoursController.text)??0;
  if(hours <=0&&minutes<=0)return;

  if(!_isRunning&&_secondRemaining==0){
    _secondRemaining=(hours*3600)+(minutes*60);
  }

  activity_Controller.clear();
  hoursController.clear();
  timer_Controller.clear();

  setState(() {
    _isRunning=true;
  });


  timer=Timer.periodic(Duration(seconds:1), (timer){
    if(_secondRemaining>0){
      setState(() =>_secondRemaining--);
    }else{
      timer.cancel();
      setState(() {
        _isRunning=false;
      });
    }

  });
  }


  String _formatTime(int seconds){
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }



  @override
  void dispose() {
  hoursController.dispose();
  activity_Controller.dispose();
  timer_Controller.dispose();
  if(_isRunning)timer.cancel();
  // TODO: implement dispose
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Screen"),),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: activity_Controller,
                    decoration: InputDecoration(labelText: "Enter Activity"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Time (in hours)"),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: timer_Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Time (in minutes)"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (activity_Controller.text.isNotEmpty &&
                        (hoursController.text.isNotEmpty || timer_Controller.text.isNotEmpty)) {
                      int? hours = int.tryParse(hoursController.text) ?? 0;
                      int? minutes = int.tryParse(timer_Controller.text) ?? 0;
                      if (hours <= 0 && minutes <= 0) return;
                      if (!_isRunning) {
                        _startTimer();
                      }
                    }
                  },
                  child: Text("Start Timer"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : null,
                  child: Text("Pause"),
                ),
              ],
            ),
            SizedBox(height: 40),
            Text(
              _formatTime(_secondRemaining),
              style: TextStyle(fontSize: 50),
            ),
          ],
        ),
      ),
    );
  }
}