import 'package:flutter/material.dart';
import 'package:time_trace/model/category_model.dart';

class ActivityModel {
  final int? id;
  final String title;
  final CategoryModel category;
  final int hour;
  final DateTime date;
  final DateTime createdAt;

  ActivityModel({
    this.id,
    required this.title,
    required this.category,
    required this.hour,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get categoryColor => category.color;

  String get categoryName => category.title;

  IconData? get categoryIcon => category.icon;

  String get formattedHour {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  String get formattedDate {
    const months = [
      '',
      'january',
      'fabruary',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  ActivityModel copyWith({
    int? id,
    String? title,
    CategoryModel? category,
    int? hour,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      hour: hour ?? this.hour,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ActivityModel(id: $id, title: $title, category: $category, hour: $hour)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityModel &&
        other.id == id &&
        other.title == title &&
        other.category == category &&
        other.hour == hour;
  }

  @override
  int get hashCode => Object.hash(id, title, category, hour);
}
