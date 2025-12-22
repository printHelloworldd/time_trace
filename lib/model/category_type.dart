import 'package:flutter/material.dart';

enum CategoryType {
  useful,
  necessary,
  useless;

  String toDbString() {
    return name;
  }

  static CategoryType fromDbString(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CategoryType.necessary,
    );
  }

  Color get color {
    switch (this) {
      case CategoryType.useful:
        return Colors.green;
      case CategoryType.necessary:
        return Colors.blue;
      case CategoryType.useless:
        return Colors.red;
    }
  }

  String get displayName {
    switch (this) {
      case CategoryType.useful:
        return 'Полезно';
      case CategoryType.necessary:
        return 'Необходимость';
      case CategoryType.useless:
        return 'Бесполезно';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoryType.useful:
        return Icons.trending_up;
      case CategoryType.necessary:
        return Icons.task_alt;
      case CategoryType.useless:
        return Icons.trending_down;
    }
  }
}
