import 'package:flutter/material.dart';

class Demohome extends StatefulWidget {
  const Demohome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.pinkAccent,
      body: Center(child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Dustbin is here"),
      )),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
