import 'package:flutter/material.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/service/category_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryService categoryService;

  CategoryViewModel({required this.categoryService}) {
    init();
  }

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  // Map<String, int> _categoryStats = {};

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  // Map<String, int> get categoryStats => _categoryStats;

  Future<void> init() async {
    loadCategories();
  }

  /// Loads categories for today
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await categoryService.getAllCategories();
      _error = null;
    } catch (e) {
      _error = 'Failed to load categories: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCategory({
    required String title,
    required Color color,
    IconData? icon,
  }) async {
    try {
      final category = CategoryModel(title: title, color: color, icon: icon);

      await categoryService.addCategory(category);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await categoryService.updateCategory(category);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await categoryService.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> isCategoryUsed(int id) {
    return categoryService.isCategoryUsed(id);
  }
}
