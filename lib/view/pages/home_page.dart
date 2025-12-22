import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_trace/model/activity_model.dart';
import 'package:time_trace/view/widgets/activity_card.dart';
import 'package:time_trace/view/widgets/activity_dialog.dart';
import 'package:time_trace/view/widgets/timeline_chart.dart';
import 'package:time_trace/view_model/activity_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // static const String appGroupId = "group.timeTrace";
  // static const String iOSWidgetName = "TimelineChart";
  // static const String androidWidgetName = "TimelineChart";
  // static const String dataKey = "timeline_chart";

  // Future<void> saveWidgetData(Object data) async {
  //   await HomeWidget.saveWidgetData(dataKey, data);
  // }

  // Future<void> updateWidget() async {
  //   await HomeWidget.updateWidget(
  //     iOSName: iOSWidgetName,
  //     androidName: androidWidgetName,
  //   );
  // }

  void _addActivity(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ActivityDialog(
            onConfirm: (activity) {
              context.read<ActivityViewModel>().addActivity(
                title: activity.title,
                hour: activity.hour,
                category: activity.category,
              );
            },
          ),
    );
  }

  void _editActivity(BuildContext context, ActivityModel activity) {
    showDialog(
      context: context,
      builder:
          (context) => ActivityDialog(
            activity: activity,
            onConfirm: (activity) {
              context.read<ActivityViewModel>().updateActivity(activity);
            },
          ),
    );
  }

  void _addActivityAtHour(BuildContext context, int hour) {
    showDialog(
      context: context,
      builder:
          (context) => ActivityDialog(
            initialHour: hour,
            onConfirm: (activity) {
              if (activity.id != null) {
                context.read<ActivityViewModel>().updateActivity(activity);
              } else {
                context.read<ActivityViewModel>().addActivity(
                  title: activity.title,
                  hour: hour,
                  category: activity.category,
                );
              }
            },
          ),
    );
  }

  Future<void> _deleteActivity(
    BuildContext context,
    ActivityModel activity,
  ) async {
    final ActivityViewModel viewModel = context.read<ActivityViewModel>();

    if (activity.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete activity?'),
            content: Text(
              'Are you sure you want to delete "${activity.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await viewModel.deleteActivity(activity.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My day'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Consumer<ActivityViewModel>(
              builder: (context, value, child) {
                return TimelineChart(
                  activities: value.todayActivities,
                  categories: [],
                  onHourTap: _addActivityAtHour,
                );
              },
            ),
            Consumer<ActivityViewModel>(
              builder: (context, value, child) {
                if (value.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (value.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value.error ??
                            "Something went wrong. Try again later or contact support",
                      ),
                    ),
                  );
                }

                if (value.todayActivities.isEmpty) {
                  return Expanded(
                    child: const Center(
                      child: Text(
                        'No activities',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: value.todayActivities.length,
                    itemBuilder: (context, index) {
                      final List<ActivityModel> activities =
                          value.todayActivities;
                      final ActivityModel activity = activities[index];

                      return ActivityCard(
                        activity: activity,
                        onPressed: () => _editActivity(context, activity),
                        onDelete: () => _deleteActivity(context, activity),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addActivity(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
