import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/service/relational_database.dart';

class CategoryMapper {
  /// Converts Database Entity → Domain Model
  static CategoryModel fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      title: entity.title,
      color: Color(entity.colorValue),
      icon:
          entity.iconCodePoint != null
              ? IconData(entity.iconCodePoint!, fontFamily: 'MaterialIcons')
              : null,
    );
  }

  /// Converts Domain Model → Database Companion (for insert)
  static CategoriesCompanion toCompanion(CategoryModel model) {
    return CategoriesCompanion(
      id:
          model.id != null
              ? drift.Value(model.id!)
              : const drift.Value.absent(),
      title: drift.Value(model.title),
      colorValue: drift.Value(model.color.value),
      iconCodePoint: drift.Value(model.icon?.codePoint),
      createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
    );
  }

  /// Converts Domain Model → Database Entity (for update)
  static Category toEntity(CategoryModel model) {
    if (model.id == null) {
      throw ArgumentError(
        'CategoryModel must have an id for update operations',
      );
    }

    return Category(
      id: model.id!,
      title: model.title,
      colorValue: model.color.value,
      iconCodePoint: model.icon?.codePoint,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Converts list of entities → list of models
  static List<CategoryModel> fromEntityList(List<Category> entities) {
    return entities.map((entity) => fromEntity(entity)).toList();
  }
}
