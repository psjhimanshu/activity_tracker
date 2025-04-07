import 'dart:async';
import 'package:activity/Screens/HomeScreen.dart';
import 'package:activity/Screens/Login_Screen.dart';
import 'package:activity/Screens/StatsScreen.dart';
import 'package:activity/Screens/mainScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final FirebaseAuth _auth=FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 1),(){
      _checkUserStatus();
    });
  }

  Future<void> _checkUserStatus() async{
    if(_auth.currentUser!=null){
      Get.off(()=>MainScreen());
    }else{
      Get.off(()=>const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyanAccent,
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          // Image.asset('name',height: 50,)
          Text("SplashScreen"),
           SizedBox(height: 20),
          CircularProgressIndicator(color: Colors.white,)
        ],
      ),
      ),
    );
  }
}
