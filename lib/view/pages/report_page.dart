import 'dart:collection';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_trace/model/activity_model.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/config/theme/theme_getter.dart';
import 'package:time_trace/view/widgets/activity_card.dart';
import 'package:time_trace/view/widgets/indicator.dart';
import 'package:time_trace/view/widgets/weekly_activity_chart.dart';
import 'package:time_trace/view_model/activity_view_model.dart';
import 'package:time_trace/view_model/category_view_model.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int touchedIndex = -1;

  static const Map<String, String> intervals = {
    "daily": "Daily",
    "weekly": "Weekly",
  };

  String selectedInterval = "Daily";

  LinkedHashMap<ActivityModel, int> _getTopDailyActivities(
    List<ActivityModel> allActivities,
  ) {
    final Map<String, int> statsByTitle = {};
    final Map<String, ActivityModel> activityByTitle = {};

    for (var activity in allActivities) {
      statsByTitle[activity.title] = (statsByTitle[activity.title] ?? 0) + 1;
      activityByTitle[activity.title] = activity;
    }

    return LinkedHashMap.fromEntries(
      (statsByTitle.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .take(3)
          .map((entry) => MapEntry(activityByTitle[entry.key]!, entry.value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report"),
        centerTitle: true,
        forceMaterialTransparency: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            DropdownButton(
              value: selectedInterval,
              items: [
                DropdownMenuItem(
                  value: intervals["daily"],
                  child: Text("Daily"),
                ),
                DropdownMenuItem(
                  value: intervals["weekly"],
                  child: Text("Weekly"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    selectedInterval = value;
                  }
                });
              },
            ),
            const SizedBox(height: 32),
            selectedInterval == "Daily"
                ? Expanded(child: _buildDailyReport(context))
                : _buildWeeklyReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyReport() {
    return Consumer2<ActivityViewModel, CategoryViewModel>(
      builder: (context, activityVM, categoryVM, child) {
        return WeeklyActivityChart(
          weeklyStats: activityVM.weeklyCategoryStats,
          categories: categoryVM.categories,
        );
      },
    );
  }

  Widget _buildDailyReport(BuildContext context) {
    final TextTheme textTheme = context.theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Consumer2<ActivityViewModel, CategoryViewModel>(
        builder: (context, activityVM, categoryVM, child) {
          return Column(
            children: <Widget>[
              _buildDailyChart(
                activityVM.categoryStatsForToday,
                activityVM.todayActivities.length,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    categoryVM.categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Indicator(
                          color: category.color,
                          text: category.title,
                          isSquare: true,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    "Top 3 daily activities",
                    style: textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTopDailyActivities(
                _getTopDailyActivities(activityVM.todayActivities),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDailyChart(
    Map<CategoryModel, int> categoryStats,
    int activitiesCount,
  ) {
    if (categoryStats.isEmpty) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height / 4,
        child: Center(child: Text("No data. Add some activity for today")),
      );
    } else {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height / 4,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 0,
            centerSpaceRadius: 40,
            sections:
                categoryStats.entries.indexed.map((indexedEntry) {
                  final CategoryModel category = indexedEntry.$2.key;
                  final double value =
                      indexedEntry.$2.value / activitiesCount * 100;

                  String valueString = value.toStringAsFixed(2);
                  if (valueString.endsWith(".00")) {
                    valueString = valueString.split(".").removeAt(0);
                  }

                  int index = indexedEntry.$1;
                  final isTouched = index == touchedIndex;
                  final fontSize = isTouched ? 25.0 : 16.0;
                  final radius = isTouched ? 60.0 : 50.0;
                  const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

                  return PieChartSectionData(
                    color: category.color,
                    value: value,
                    title: "$valueString%",
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      shadows: shadows,
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    }
  }

  Widget _buildTopDailyActivities(
    LinkedHashMap<ActivityModel, int> activities,
  ) {
    if (activities.isEmpty) {
      return SizedBox(child: Row(children: [Text("No activities for today")]));
    } else {
      return Expanded(
        child: ListView(
          children:
              activities.entries.map((entry) {
                return ActivityCard(
                  activity: entry.key,
                  overallHours: entry.value,
                  full: false,
                  onPressed: () {},
                  onDelete: () {},
                );
              }).toList(),
        ),
      );
    }
  }
}
