import 'package:drift/drift.dart';
import 'package:time_trace/model/category_mapper.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/service/relational_database.dart';

class CategoryService {
  final RelationalDatabase database;

  CategoryService({required this.database});

  Future<List<CategoryModel>> getAllCategories() async {
    final entities = await database.select(database.categories).get();
    return CategoryMapper.fromEntityList(entities);
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    final entity =
        await (database.select(database.categories)
          ..where((c) => c.id.equals(id))).getSingleOrNull();

    return entity != null ? CategoryMapper.fromEntity(entity) : null;
  }

  Future<int> addCategory(CategoryModel model) async {
    final companion = CategoryMapper.toCompanion(model);
    return await database.into(database.categories).insert(companion);
  }

  Future<bool> updateCategory(CategoryModel model) async {
    final entity = CategoryMapper.toEntity(model);
    return await database.update(database.categories).replace(entity);
  }

  /// ATTENTION: Associated activities must be processed before deletion.
  Future<int> deleteCategory(int id) async {
    // You can add a check for the presence of activities with this category.
    return await (database.delete(database.categories)
      ..where((c) => c.id.equals(id))).go();
  }

  Future<bool> isCategoryUsed(int categoryId) async {
    final count =
        await (database.selectOnly(database.activities)
              ..addColumns([database.activities.id.count()])
              ..where(database.activities.categoryId.equals(categoryId)))
            .getSingle();

    return (count.read(database.activities.id.count()) ?? 0) > 0;
  }

  Stream<List<CategoryModel>> watchAllCategories() {
    return database
        .select(database.categories)
        .watch()
        .map((entities) => CategoryMapper.fromEntityList(entities));
  }
}
