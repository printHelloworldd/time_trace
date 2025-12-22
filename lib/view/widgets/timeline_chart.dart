import 'package:flutter/material.dart';
import 'package:time_trace/model/activity_model.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/config/theme/extension/app_colors.dart';
import 'package:time_trace/config/theme/extension/app_theme_extension.dart';
import 'package:time_trace/config/theme/theme_getter.dart';

class TimelineChart extends StatelessWidget {
  final List<ActivityModel> activities;
  final List<CategoryModel> categories;
  final Function(BuildContext, int) onHourTap;

  const TimelineChart({
    super.key,
    required this.activities,
    required this.onHourTap,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    final now = DateTime.now();
    final currentHour = now.hour;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 24,
              itemBuilder: (context, hour) {
                final activity =
                    activities.where((a) => a.hour == hour).firstOrNull;
                final isCurrentHour = hour == currentHour;

                return GestureDetector(
                  onTap: () => onHourTap(context, hour),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  activity != null
                                      ? activity.categoryColor
                                      : appColors.surfaceHighlight,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  isCurrentHour
                                      ? Border.all(
                                        color: appColors.background,
                                        width: 2,
                                      )
                                      : null,
                            ),
                            child: Center(
                              child:
                                  activity != null
                                      ? Icon(
                                        Icons.check,
                                        color: appColors.primary,
                                        size: 20,
                                      )
                                      : Icon(
                                        Icons.add,
                                        color: appColors.surface,
                                        size: 20,
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isCurrentHour
                                    ? appColors.primary
                                    : appColors.surfaceHighlight,
                            fontWeight:
                                isCurrentHour
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                categories.map((category) {
                  return _buildLegendItem(category.title, category.color);
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
