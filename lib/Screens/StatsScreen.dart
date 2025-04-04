import 'dart:math';

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
    {
      'activity_name': 'Sleep',
      'start_time': DateTime(2025, 4, 2, 22, 0),
      'end_time': DateTime(2025, 4, 3, 3, 30),
    },
    {
      'activity_name': 'skeet',
      'start_time': DateTime(2025, 4, 6, 22, 0),
      'end_time': DateTime(2025, 4, 7, 3, 30),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stats Screen")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
  Map<String, bool> _selectedActivities = {};
  final Map<String, Color> _activityColors = {};

  Color _generateColor(int index, [double saturation = 0.6, double value = 0.85]) {
    double hue = (index * 137.508) % 360; // Golden angle in degrees for better distribution
    return HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
  }


  Map<String, dynamic> _generateChartData() {
    Map<int, Map<String, double>> dayWiseData = {};

    for (var activity in widget.activities) {
      DateTime start = activity['start_time'];
      DateTime end = activity['end_time'];
      String activityName = activity['activity_name'];

      DateTime current = start;

      while (current.day != end.day || current.month != end.month || current.year != end.year) {
        DateTime endOfDay = DateTime(current.year, current.month, current.day, 23, 59, 59);
        double duration = double.parse((endOfDay.difference(current).inMinutes / 60.0).toStringAsFixed(2));

        int day = current.day;
        dayWiseData[day] ??= {};
        dayWiseData[day]![activityName] = (dayWiseData[day]![activityName] ?? 0) + duration;

        current = DateTime(current.year, current.month, current.day + 1, 0, 0);
      }

      int finalDay = end.day;
      double remainingDuration = double.parse((end.difference(current).inMinutes / 60.0).toStringAsFixed(2));
      dayWiseData[finalDay] ??= {};
      dayWiseData[finalDay]![activityName] = (dayWiseData[finalDay]![activityName] ?? 0) + remainingDuration;
    }

    List<ActivityData> chartData = [];
    double maxHours = 0;

    dayWiseData.forEach((day, activities) {
      double totalDuration = activities.values.fold(0, (sum, value) => sum + value);
      if (totalDuration > maxHours) {
        maxHours = totalDuration;
      }
      chartData.add(ActivityData(day, activities));
    });

    int numDays = dayWiseData.length;

    return {
      'data': chartData,
      'maxHours': maxHours,
      'numDays': numDays,
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();

    Set<String> allActivities = widget.activities
        .map((a) => a['activity_name'] as String)
        .toSet();

    int colorIndex = 0;
    for (String activity in allActivities) {
      _activityColors[activity] = _generateColor(colorIndex++);
      _selectedActivities[activity] = true;
    }



  }

  void _onBarTap(ChartPointDetails details, String activity) {
    String day = "Day ${details.pointIndex! + 1}";
    String activityName = activity;
    double duration = details.dataPoints![details.pointIndex!].y;

    showModalBottomSheet(
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
    var result = _generateChartData();
    List<ActivityData> chartData = result['data'];
    double maxHours = result['maxHours'];
    int totalDays = result['numDays'];

    double chartWidth = (maxHours * 40)+150; // each hour is 40px wide (adjust as needed)
    double chartHeight = max(MediaQuery.of(context).size.height-(45),totalDays * 50);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                height: chartHeight,
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
                    maximum: maxHours,
                    interval: maxHours/10,
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  legend: Legend(isVisible: false,position:LegendPosition.left),
                  tooltipBehavior: _tooltipBehavior,
                  series: _generateSeries(chartData),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            children: _selectedActivities.keys.map((activity) {
              final isSelected = _selectedActivities[activity] ?? true;
              final color = _activityColors[activity] ?? Colors.grey;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedActivities[activity] = !isSelected;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple.shade300 : Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? Colors.black : Colors.purple),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(activity),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  List<StackedBarSeries<ActivityData, String>> _generateSeries(List<ActivityData> data) {
    Set<String> allActivities = {};

    for (var entry in data) {
      allActivities.addAll(entry.activities.keys);
    }

    return allActivities.where((activity) => _selectedActivities[activity] ?? true).map((activity) {
      return StackedBarSeries<ActivityData, String>(
        name: activity,
        dataSource: data,
        color: _activityColors[activity],
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
