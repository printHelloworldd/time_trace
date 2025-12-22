import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String title;
  final Color color;
  final IconData? icon;

  CategoryModel({this.id, required this.title, required this.color, this.icon});

  CategoryModel copyWith({
    int? id,
    String? title,
    Color? color,
    IconData? icon,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() => 'CategoryModel(id: $id, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.title == title &&
        other.color.value == color.value;
  }

  @override
  int get hashCode => Object.hash(id, title, color.value);
}
