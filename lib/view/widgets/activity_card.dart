// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:time_trace/model/activity_model.dart';
import 'package:time_trace/config/theme/extension/app_colors.dart';
import 'package:time_trace/config/theme/extension/app_theme_extension.dart';
import 'package:time_trace/config/theme/theme_getter.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final bool full;
  final int? overallHours;
  final Function() onPressed;
  final Function() onDelete;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onPressed,
    required this.onDelete,
    this.full = true,
    this.overallHours,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: appColors.primary.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: activity.categoryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      overallHours == null
                          ? Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: appColors.surfaceHighlight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${activity.hour.toString().padLeft(2, '0')}:00',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: appColors.surfaceHighlight,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          )
                          : Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: appColors.surfaceHighlight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$overallHours ${overallHours! < 2 ? "hour" : "hours"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: appColors.surfaceHighlight,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: activity.categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          activity.categoryName,
                          style: TextStyle(
                            fontSize: 11,
                            color: activity.categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (full)
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_rounded, color: Colors.red[600]),
              ),
          ],
        ),
      ),
    );
  }
}
