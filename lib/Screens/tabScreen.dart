import 'package:flutter/material.dart';

class TabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("TrackMate"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Sub Screen 1"),
              Tab(text: "Sub Screen 2"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SubScreen1(),
            SubScreen2(),
          ],
        ),
      ),
    );
  }
}

class SubScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("This is Sub Screen 1"));
  }
}

class SubScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("This is Sub Screen 2"));
  }
}