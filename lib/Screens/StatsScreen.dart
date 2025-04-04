import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatsScreen extends StatefulWidget {
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final List<Map<String, dynamic>> activities = [
    {
      'activity_name': 'Running',
      'start_time': DateTime(2025, 4, 1, 8, 0),
      'end_time': DateTime(2025, 4, 1, 9, 0),
    },
    {
      'activity_name': 'Reading',
      'start_time': DateTime(2025, 4, 1, 10, 0),
      'end_time': DateTime(2025, 4, 1, 11, 30),
    },
    {
      'activity_name': 'study',
      'start_time': DateTime(2025, 4, 1, 14, 0),
      'end_time': DateTime(2025, 4, 1, 15, 30),
    },
    {
      'activity_name': 'exercise',
      'start_time': DateTime(2025, 4, 2, 10, 0),
      'end_time': DateTime(2025, 4, 2, 11, 30),
    },
    {
      'activity_name': 'Running',
      'start_time': DateTime(2025, 4, 2, 12, 0),
      'end_time': DateTime(2025, 4, 2, 14, 30),
    },
    {
      'activity_name': 'Reading',
      'start_time': DateTime(2025, 4, 2, 16, 0),
      'end_time': DateTime(2025, 4, 2, 17, 30),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stats Screen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ActivityBarChart(activities: activities),
      ),
    );
  }
}


class ActivityBarChart extends StatefulWidget {
  final List<Map<String, dynamic>> activities;

  ActivityBarChart({required this.activities});

  @override
  State<ActivityBarChart> createState() => _ActivityBarChartState();
}

class _ActivityBarChartState extends State<ActivityBarChart> {
  late TooltipBehavior _tooltipBehavior;

  List<ActivityData> _generateChartData() {
    Map<int, Map<String, double>> dayWiseData = {};

    for (var activity in widget.activities) {
      DateTime start = activity['start_time'];
      DateTime end = activity['end_time'];
      String activityName = activity['activity_name'];
      double duration = end.difference(start).inMinutes / 60.0;

      int day = start.day;

      if (!dayWiseData.containsKey(day)) {
        dayWiseData[day] = {};
      }

      if (!dayWiseData[day]!.containsKey(activityName)) {
        dayWiseData[day]![activityName] = 0.0;
      }

      dayWiseData[day]![activityName] = dayWiseData[day]![activityName]! + duration;
    }

    List<ActivityData> chartData = [];
    dayWiseData.forEach((day, activities) {
      chartData.add(ActivityData(day, activities));
    });

    return chartData;
  }

  @override
  void initState() {
    // TODO: implement initState
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  void _onBarTap(ChartPointDetails details, String activity) {
    String day = "Day ${details.pointIndex! + 1}";
    String activityName = activity;
    double duration = details.dataPoints![details.pointIndex!].y;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Activity Details"),
        content: Text("$activityName on $day\nDuration: ${duration.toStringAsFixed(1)} hours"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ActivityData> chartData = _generateChartData();
// useless comments
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1000,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              isInversed: true,
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              opposedPosition: true,
              isVisible: false,
              title: AxisTitle(text: 'Hours'),
              minimum: 0,
              maximum: 24,
              interval: 4,
              majorGridLines: MajorGridLines(width: 0),
            ),
            legend: Legend(isVisible: true,position:LegendPosition.left),
            tooltipBehavior: _tooltipBehavior,
            series: _generateSeries(chartData),
          ),
        ),
      ),
    );
  }

  List<StackedBarSeries<ActivityData, String>> _generateSeries(List<ActivityData> data) {
    Set<String> allActivities = {};

    for (var entry in data) {
      allActivities.addAll(entry.activities.keys);
    }

    return allActivities.map((activity) {
      return StackedBarSeries<ActivityData, String>(
        name: activity,
        dataSource: data,
        yValueMapper: (ActivityData data, _) => (data.activities[activity] ?? 0).toDouble(),
        xValueMapper: (ActivityData data, _) => "Day ${data.day}",
        dataLabelSettings: DataLabelSettings(
          showZeroValue: false,
          labelAlignment: ChartDataLabelAlignment.middle,
          isVisible: true, // Center labels inside bars
          textStyle: TextStyle(color: Colors.white, fontSize: 12), // Better contrast
        ),
        onPointTap: (ChartPointDetails details) {
          _onBarTap(details, activity); // Pass activity name manually
        },
      );
    }).toList();
  }
}

class ActivityData {
  final int day;
  final Map<String, double> activities;

  ActivityData(this.day, this.activities);
}
