import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:time_trace/model/activity_model.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/view_model/category_view_model.dart';

class ActivityDialog extends StatefulWidget {
  final Function(ActivityModel) onConfirm;
  final int? initialHour;
  final ActivityModel? activity;

  const ActivityDialog({
    super.key,
    required this.onConfirm,
    this.initialHour,
    this.activity,
  });

  @override
  State<ActivityDialog> createState() => _ActivityDialog();
}

class _ActivityDialog extends State<ActivityDialog> {
  final _titleController = TextEditingController();
  late int _selectedHour;
  CategoryModel? _selectedCategory;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour ?? DateTime.now().hour;

    if (widget.activity != null) {
      isEditing = true;

      _titleController.text = widget.activity!.title;
      _selectedCategory = widget.activity!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedHour,
              decoration: const InputDecoration(
                labelText: 'Hour',
                border: OutlineInputBorder(),
              ),
              items: List.generate(24, (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Text('${index.toString().padLeft(2, '0')}:00'),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedHour = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Consumer<CategoryViewModel>(
              builder: (context, value, child) {
                return Wrap(
                  spacing: 8,
                  children:
                      value.categories.map((category) {
                        return _buildCategoryChip(category);
                      }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        _selectedCategory != null) {
                      widget.onConfirm(
                        ActivityModel(
                          id: widget.activity?.id,
                          title: _titleController.text,
                          category: _selectedCategory!,
                          hour: _selectedHour,
                          date: DateTime.now(),
                        ),
                      );
                      context.pop();
                    }
                  },
                  child: Text(isEditing ? "OK" : "Add"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(CategoryModel category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(category.title),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
      selectedColor: category.color.withOpacity(0.3),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? category.color : Colors.grey[700],
      ),
      side: BorderSide(
        color: isSelected ? category.color : Colors.transparent,
        width: 2,
      ),
    );
  }
}
