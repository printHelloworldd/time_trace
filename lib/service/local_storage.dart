/// Абстрактный интерфейс для локального хранилища
/// Позволяет легко менять реализацию (Hive, SharedPreferences, etc.)
abstract class LocalStorage {
  /// Инициализация хранилища
  Future<void> init();

  /// Сохранить строку
  Future<void> setString(String key, String value);

  /// Получить строку
  Future<String?> getString(String key);

  /// Сохранить число
  Future<void> setInt(String key, int value);

  /// Получить число
  Future<int?> getInt(String key);

  /// Сохранить boolean
  Future<void> setBool(String key, bool value);

  /// Получить boolean
  Future<bool?> getBool(String key);

  /// Сохранить список строк
  Future<void> setStringList(String key, List<String> value);

  /// Получить список строк
  Future<List<String>?> getStringList(String key);

  /// Сохранить объект (JSON)
  Future<void> setObject<T>(String key, T value);

  /// Получить объект (JSON)
  Future<T?> getObject<T>(String key);

  /// Сохранить список объектов
  Future<void> setObjectList<T>(String key, List<T> value);

  /// Получить список объектов
  Future<List<T>?> getObjectList<T>(String key);

  /// Удалить значение по ключу
  Future<void> remove(String key);

  /// Очистить всё хранилище
  Future<void> clear();

  /// Проверить наличие ключа
  Future<bool> containsKey(String key);

  /// Получить все ключи
  Future<List<String>> getAllKeys();
}

/// Ключи для хранилища (для типобезопасности)
class StorageKeys {
  static const String isFirstLaunch = 'is_first_launch';
  static const String theme = 'theme';
  static const String language = 'language';
}
