// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/config/theme/extension/app_colors.dart';
import 'package:time_trace/config/theme/extension/app_theme_extension.dart';
import 'package:time_trace/config/theme/theme_getter.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final Function() onPressed;
  final Function() onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onPressed,
    required this.onDelete,
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
                color: category.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                category.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

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
