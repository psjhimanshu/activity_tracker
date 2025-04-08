import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    {
      'activity_name': 'skeet',
      'start_time': DateTime(2025, 5, 6, 22, 0),
      'end_time': DateTime(2025, 5, 7, 3, 30),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Activities record ",
          style: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ActivityBarChart(activities: activities),
        ),
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
  DateTime _selectedMonth = DateTime.now();
  late List<DateTime> _availableMonths;
  int _currentMonthIndex = 0;
  DateTime get _currentMonth => _availableMonths[_currentMonthIndex];

  List<DateTime> _extractAvailableMonths(
      List<Map<String, dynamic>> activities) {
    final monthSet = <String, DateTime>{};

    for (var activity in activities) {
      DateTime start = activity['start_time'];
      DateTime firstOfMonth = DateTime(start.year, start.month);
      String key = "${start.year}-${start.month}";

      monthSet[key] = firstOfMonth;
    }

    final sorted = monthSet.values.toList()..sort((a, b) => a.compareTo(b));

    return sorted;
  }

  Color _generateColor(int index,
      [double saturation = 0.6, double value = 0.85]) {
    double hue = (index * 137.508) %
        360; // Golden angle in degrees for better distribution
    return HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
  }

  Map<String, dynamic> _generateChartData() {
    Map<String, Map<String, double>> dayWiseData = {};

    // Filter activities for the selected month and year
    final visibleActivities = widget.activities.where((a) {
      DateTime start = a['start_time'];
      DateTime end = a['end_time'];
      return (start.month == _selectedMonth.month &&
              start.year == _selectedMonth.year) ||
          (end.month == _selectedMonth.month &&
              end.year == _selectedMonth.year);
    }).toList();

    // Collect unique activity names for this month
    final activityNames =
        visibleActivities.map((a) => a['activity_name']).toSet();

    // Remove entries from _selectedActivities and _activityColors that aren't in this month
    _selectedActivities
        .removeWhere((key, value) => !activityNames.contains(key));
    _activityColors.removeWhere((key, value) => !activityNames.contains(key));

    // Update selected activities and assign colors if not already present
    int colorIndex = 0;
    for (var act in activityNames) {
      _selectedActivities.putIfAbsent(act, () => true);
      _activityColors.putIfAbsent(act, () => _generateColor(colorIndex++));
    }

    for (var activity in visibleActivities) {
      DateTime start = activity['start_time'];
      DateTime end = activity['end_time'];
      String activityName = activity['activity_name'];

      DateTime current = start;

      while (current.day != end.day ||
          current.month != end.month ||
          current.year != end.year) {
        DateTime endOfDay =
            DateTime(current.year, current.month, current.day, 23, 59, 59);
        double duration = double.parse(
            (endOfDay.difference(current).inMinutes / 60.0).toStringAsFixed(2));

        // Format label as "Apr-1"
        String label = DateFormat('MMM-d').format(current);
        dayWiseData[label] ??= {};
        dayWiseData[label]![activityName] =
            (dayWiseData[label]![activityName] ?? 0) + duration;

        current = DateTime(current.year, current.month, current.day + 1);
      }

      String finalLabel = DateFormat('MMM-d').format(end);
      double remainingDuration = double.parse(
          (end.difference(current).inMinutes / 60.0).toStringAsFixed(2));
      dayWiseData[finalLabel] ??= {};
      dayWiseData[finalLabel]![activityName] =
          (dayWiseData[finalLabel]![activityName] ?? 0) + remainingDuration;
    }

    List<ActivityData> chartData = [];
    double maxHours = 0;

    dayWiseData.forEach((label, activities) {
      double totalDuration =
          activities.values.fold(0, (sum, value) => sum + value);
      if (totalDuration > maxHours) {
        maxHours = totalDuration;
      }
      chartData.add(ActivityData(label, activities));
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

    Set<String> allActivities =
        widget.activities.map((a) => a['activity_name'] as String).toSet();

    int colorIndex = 0;
    for (String activity in allActivities) {
      _activityColors[activity] = _generateColor(colorIndex++);
      _selectedActivities[activity] = true;
    }

    _availableMonths = _extractAvailableMonths(widget.activities);
    _currentMonthIndex = _availableMonths.length - 1;
    _selectedMonth = _availableMonths[_currentMonthIndex];
  }

  void _onBarTap(ChartPointDetails details, String activity) {
    String day = "${details.dataPoints![0].x}";
    String activityName = activity;
    double duration = details.dataPoints![details.pointIndex!].y;

    showModalBottomSheet(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Activity Details"),
        content: Text(
            "$activityName on $day\nDuration: ${duration.toStringAsFixed(1)} hours"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    var result = _generateChartData();
    List<ActivityData> chartData = result['data'];
    double maxHours = result['maxHours'];
    int totalDays = result['numDays'];

    double chartWidth =
        (maxHours * 40) + 150; // each hour is 40px wide (adjust as needed)
    double chartHeight = totalDays * 100;

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
                    axisLine: const AxisLine(
                      color: Colors.white, // Make axis line more visible
                      width: 2, // Thicker line
                    ),
                    labelStyle: TextStyle(
                      color: Colors.white, // Label color
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                    majorTickLines: const MajorTickLines(
                      color: Colors.white, // Color of the small lines (ticks)
                      width: 1.5,
                      size: 6, // Length of the tick line
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    opposedPosition: true,
                    isVisible: false,
                    title: AxisTitle(text: 'Hours'),
                    minimum: 0,
                    maximum: maxHours,
                    interval: max(maxHours / 10, 1),
                    majorGridLines: MajorGridLines(width: 0),
                  ),
                  legend:
                      Legend(isVisible: false, position: LegendPosition.left),
                  tooltipBehavior: _tooltipBehavior,
                  series: _generateSeries(chartData),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        MonthSwitcher(
          availableMonths: _availableMonths,
          selectedMonth: _selectedMonth,
          onMonthChanged: (newMonth, newIndex) {
            setState(() {
              _selectedMonth = newMonth;
              _currentMonthIndex = newIndex;
            });
          },
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(
                builder: (context) {
                  final allSelected =
                      _selectedActivities.values.every((selected) => selected);
                  final toggleText =
                      allSelected ? "Deselect All" : "Select All";

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedActivities
                            .updateAll((key, value) => !allSelected);
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[300]!.withAlpha(80),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withAlpha(80), width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            allSelected ? Icons.clear_all : Icons.select_all,
                            size: 15,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            toggleText,
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ..._selectedActivities.keys.map((activity) {
                final isSelected = _selectedActivities[activity] ?? true;
                final color = isSelected
                    ? _activityColors[activity]
                    : _activityColors[activity]!.withAlpha(130);
                final border = Border.all(
                    color: isSelected
                        ? Colors.white.withAlpha(90)
                        : Colors.white.withAlpha(40),
                    width: 2);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedActivities[activity] = !isSelected;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: border,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: border),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            activity,
                            style: TextStyle(
                                fontWeight: FontWeight.w300, color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 1.0,
                                  color: Colors.black.withAlpha(150),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        )
      ],
    );
  }

  List<StackedBarSeries<ActivityData, String>> _generateSeries(
      List<ActivityData> data) {
    Set<String> allActivities = {};

    for (var entry in data) {
      allActivities.addAll(entry.activities.keys);
    }

    return allActivities
        .where((activity) => _selectedActivities[activity] ?? true)
        .map((activity) {
      return StackedBarSeries<ActivityData, String>(
        name: activity,
        dataSource: data,
        color: _activityColors[activity],
        yValueMapper: (ActivityData data, _) =>
            (data.activities[activity] ?? 0).toDouble(),
        xValueMapper: (ActivityData data, _) => data.label,
        dataLabelSettings: DataLabelSettings(
          showZeroValue: false,
          labelAlignment: ChartDataLabelAlignment.middle,
          isVisible: true, // Center labels inside bars
          textStyle:
              TextStyle(color: Colors.white, fontSize: 12), // Better contrast
        ),
          dataLabelMapper: (ActivityData data, _) {
            final duration = data.activities[activity];
            return duration != null ? "${duration.toStringAsFixed(1)}hr" : "";
          },
        onPointLongPress: (ChartPointDetails details) {
          _onBarTap(details, activity); // Your existing handler
        },
      );
    }).toList();
  }
}

class ActivityData {
  final String label;
  final Map<String, double> activities;

  ActivityData(this.label, this.activities);
}

// trial code for pageview for better months bar
class MonthSwitcher extends StatefulWidget {
  final List<DateTime> availableMonths;
  final DateTime selectedMonth;
  final Function(DateTime selectedMonth, int index) onMonthChanged;

  const MonthSwitcher({
    required this.availableMonths,
    required this.selectedMonth,
    required this.onMonthChanged,
    super.key,
  });

  @override
  State<MonthSwitcher> createState() => _MonthSwitcherState();
}

class _MonthSwitcherState extends State<MonthSwitcher> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.availableMonths.indexOf(widget.selectedMonth);
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 1.0);
  }

  void _goToPage(int newIndex) {
    if (newIndex >= 0 && newIndex < widget.availableMonths.length) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      widget.onMonthChanged(widget.availableMonths[newIndex], newIndex);
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: _currentIndex > 0
                ? Colors.white
                : Colors.grey,
          ),
          onPressed:
              _currentIndex > 0 ? () => _goToPage(_currentIndex - 1) : null,
        ),
        Expanded(
          child: SizedBox(
            height: 50,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.availableMonths.length,
              onPageChanged: (index) {
                widget.onMonthChanged(widget.availableMonths[index], index);
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final month = widget.availableMonths[index];
                return Center(
                  child: Text(
                    DateFormat('MMM yyyy').format(month),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: _currentIndex < widget.availableMonths.length - 1
                ? Colors.white
                : Colors.grey,
          ),
          onPressed: _currentIndex < widget.availableMonths.length - 1
              ? () => _goToPage(_currentIndex + 1)
              : null,
        ),
      ],
    );
  }
}
