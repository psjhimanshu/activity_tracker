import 'package:flutter/material.dart';

class Demohome extends StatelessWidget {
  const Demohome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      body: Center(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Dustbin is here"),
      )),
    );
  }
}
