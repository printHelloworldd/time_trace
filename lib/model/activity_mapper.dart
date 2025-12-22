import 'package:drift/drift.dart' as drift;
import 'package:time_trace/model/activity_model.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/service/relational_database.dart';

class ActivityMapper {
  /// Converts Database Entity → Domain Model
  /// Requires CategoryModel, because Activity entity contains only categoryId
  static ActivityModel fromEntity(Activity entity, CategoryModel category) {
    final dateParts = entity.date.split('-');
    final date = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    return ActivityModel(
      id: entity.id,
      title: entity.title,
      category: category,
      hour: entity.hour,
      date: date,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
    );
  }

  /// Converts Domain Model → Database Companion (for insert)
  static ActivitiesCompanion toCompanion(ActivityModel model) {
    if (model.category.id == null) {
      throw ArgumentError('Category must have an id to create Activity');
    }

    return ActivitiesCompanion(
      id:
          model.id != null
              ? drift.Value(model.id!)
              : const drift.Value.absent(),
      title: drift.Value(model.title),
      categoryId: drift.Value(model.category.id!),
      hour: drift.Value(model.hour),
      date: drift.Value(_formatDate(model.date)),
      timestamp: drift.Value(model.date.millisecondsSinceEpoch),
      createdAt: drift.Value(model.createdAt.millisecondsSinceEpoch),
    );
  }

  /// Converts Domain Model → Database Entity (for update)
  static Activity toEntity(ActivityModel model) {
    if (model.id == null) {
      throw ArgumentError(
        'ActivityModel must have an id for update operations',
      );
    }
    if (model.category.id == null) {
      throw ArgumentError('Category must have an id to update Activity');
    }

    return Activity(
      id: model.id!,
      title: model.title,
      categoryId: model.category.id!,
      hour: model.hour,
      date: _formatDate(model.date),
      timestamp: model.date.millisecondsSinceEpoch,
      createdAt: model.createdAt.millisecondsSinceEpoch,
    );
  }

  /// Formats date for storing in DB
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
