import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// For Storing data such as token etc..
class SecurePreference {
  static final SecurePreference _instance = SecurePreference._internal();
  factory SecurePreference() => _instance;

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SecurePreference._internal();

  Future<void> setString(String key, String value) async {
    if (key.isNotEmpty) {
      await _storage.write(key: key, value: value);
    }
  }

  Future<String> getString(String key, {String defaultValue = ''}) async {
    return key.isNotEmpty ? (await _storage.read(key: key)) ?? defaultValue : defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    if (key.isNotEmpty) {
      await _storage.write(key: key, value: value.toString());
    }
  }

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    if (key.isEmpty) return defaultValue;
    String? value = await _storage.read(key: key);
    return int.tryParse(value ?? '') ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    if (key.isNotEmpty) {
      await _storage.write(key: key, value: value.toString());
    }
  }

  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    if (key.isEmpty) return defaultValue;
    String? value = await _storage.read(key: key);
    return double.tryParse(value ?? '') ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    if (key.isNotEmpty) {
      await _storage.write(key: key, value: value.toString());
    }
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    if (key.isEmpty) return defaultValue;
    String? value = await _storage.read(key: key);
    return value?.toLowerCase() == 'true' ? true : defaultValue;
  }

  Future<void> remove(String key) async {
    if (key.isNotEmpty) {
      await _storage.delete(key: key);
    }
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return key.isNotEmpty && (await _storage.read(key: key)) != null;
  }

  Future<void> set(String key, dynamic value) async {
    if (key.isNotEmpty) {
      switch (value) {
        case String _:
          await setString(key, value);
          break;
        case int _:
          await setInt(key, value);
          break;
        case double _:
          await setDouble(key, value);
          break;
        case bool _:
          await setBool(key, value);
          break;
        default:
          throw Exception('Unsupported data type');
      }
    }
  }

  Future<dynamic> get(String key, dynamic defaultVal) async {
    if (key.isEmpty) return defaultVal;
    switch (defaultVal) {
      case String _:
        return await getString(key, defaultValue: defaultVal);
      case int _:
        return await getInt(key, defaultValue: defaultVal);
      case double _:
        return await getDouble(key, defaultValue: defaultVal);
      case bool _:
        return await getBool(key, defaultValue: defaultVal);
      default:
        throw Exception('Unsupported data type');
    }
  }

  Future<void> clearAllExcept(String keyToKeep, dynamic value) async {
    if (keyToKeep.isNotEmpty) {
      await clear();
      await set(keyToKeep, value);
    }
  }
}


