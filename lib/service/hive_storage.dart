// lib/data/datasources/local/hive_storage.dart

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import 'local_storage.dart';

class HiveStorage implements LocalStorage {
  static const String _boxName = 'app_storage';
  Box? _box;

  @override
  Future<void> init() async {
    // Инициализация Hive
    await Hive.initFlutter();

    // Регистрация адаптеров (если нужно)
    // Hive.registerAdapter(UserAdapter());

    // Открытие бокса
    _box = await Hive.openBox(_boxName);
  }

  Box get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'HiveStorage не инициализирован. Вызовите init() перед использованием.',
      );
    }
    return _box!;
  }

  @override
  Future<void> setString(String key, String value) async {
    await box.put(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return box.get(key) as String?;
  }

  @override
  Future<void> setInt(String key, int value) async {
    await box.put(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return box.get(key) as int?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await box.put(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return box.get(key) as bool?;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await box.put(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = box.get(key);
    if (value == null) return null;
    return List<String>.from(value as List);
  }

  @override
  Future<void> setObject<T>(String key, T value) async {
    final jsonString = jsonEncode(value);
    await box.put(key, jsonString);
  }

  @override
  Future<T?> getObject<T>(String key) async {
    final jsonString = box.get(key) as String?;
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as T;
  }

  @override
  Future<void> setObjectList<T>(String key, List<T> value) async {
    final jsonString = jsonEncode(value);
    await box.put(key, jsonString);
  }

  @override
  Future<List<T>?> getObjectList<T>(String key) async {
    final jsonString = box.get(key) as String?;
    if (jsonString == null) return null;
    final list = jsonDecode(jsonString) as List;
    return list.cast<T>();
  }

  @override
  Future<void> remove(String key) async {
    await box.delete(key);
  }

  @override
  Future<void> clear() async {
    await box.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return box.containsKey(key);
  }

  @override
  Future<List<String>> getAllKeys() async {
    return box.keys.map((key) => key.toString()).toList();
  }
}
