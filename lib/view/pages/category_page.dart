import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/view/widgets/category_card.dart';
import 'package:time_trace/view_model/category_view_model.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Consumer<CategoryViewModel>(
            builder: (context, value, child) {
              if (value.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (value.categories.isEmpty) {
                return Center(child: Text("No categories"));
              }

              return ListView.builder(
                itemCount: value.categories.length,
                itemBuilder: (context, index) {
                  final List<CategoryModel> categories = value.categories;
                  final CategoryModel category = categories[index];

                  return CategoryCard(
                    category: category,
                    onPressed: () => _editCategory(context, category),
                    onDelete: () => _deleteCategory(context, category),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCategory(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addCategory(BuildContext context) async {
    await _showCategoryDialog(context);
  }

  Future<void> _editCategory(
    BuildContext context,
    CategoryModel category,
  ) async {
    await _showCategoryDialog(context, category: category);
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    CategoryModel? category,
  }) async {
    final CategoryViewModel viewModel = context.read<CategoryViewModel>();

    final isEditing = category != null;
    final titleController = TextEditingController(text: category?.title);
    Color selectedColor = category?.color ?? Colors.blue;
    IconData? selectedIcon = category?.icon;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(isEditing ? 'Edit category' : 'New category'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'Example: Work',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Color'),
                          trailing: CircleAvatar(
                            backgroundColor: selectedColor,
                          ),
                          onTap: () async {
                            final color = await showDialog<Color>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Select color'),
                                    content: SingleChildScrollView(
                                      child: BlockPicker(
                                        pickerColor: selectedColor,
                                        onColorChanged: (color) {
                                          Navigator.pop(context, color);
                                        },
                                      ),
                                    ),
                                  ),
                            );
                            if (color != null) {
                              setState(() => selectedColor = color);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CategoryViewModel>().addCategory(
                          title: titleController.text,
                          color: selectedColor,
                        );

                        context.pop();
                      },
                      child: Text(isEditing ? 'Save' : 'Add'),
                    ),
                  ],
                ),
          ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final newCategory = CategoryModel(
        id: category?.id,
        title: titleController.text,
        color: selectedColor,
        icon: selectedIcon,
      );

      if (isEditing) {
        await viewModel.updateCategory(newCategory);
      } else {
        await viewModel.addCategory(
          title: titleController.text,
          color: selectedColor,
        );
      }
    }
  }

  Future<IconData?> _showIconPicker(BuildContext context) async {
    final icons = [
      Icons.work,
      Icons.home,
      Icons.sports,
      Icons.school,
      Icons.restaurant,
      Icons.local_hospital,
      Icons.shopping_cart,
      Icons.directions_car,
      Icons.flight,
      Icons.hotel,
      Icons.movie,
      Icons.music_note,
      Icons.book,
      Icons.computer,
      Icons.phone,
    ];

    return await showDialog<IconData>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select icon'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.pop(context, icons[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icons[index], size: 32),
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    CategoryModel category,
  ) async {
    final CategoryViewModel viewModel = context.read<CategoryViewModel>();

    if (category.id == null) return;

    final isUsed = await viewModel.isCategoryUsed(category.id!);

    if (isUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You cannot delete a category that is used in activities.',
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete category?'),
            content: Text(
              'Are you sure you want to delete "${category.title}"?',
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
      await viewModel.deleteCategory(category.id!);
    }
  }
}
