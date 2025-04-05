import 'dart:developer';

import 'package:hive_ce/hive.dart';

class HiveStorageService {
  static const String _boxName = 'offline_first_api_data_box';
  static const int _maxKeyLength = 200;

  /// Generates a safe key using a simple hash if the key exceeds 200 characters
  String _normalizeKey(String key) {
    if (key.length <= _maxKeyLength) return key;

    // Simple custom hash (sum of code units + length)
    final hash = key.codeUnits.fold(0, (prev, e) => prev + e) + key.length;
    final shortened = key.substring(0, 150); // Truncate to avoid overflow
    return '${shortened}_$hash';
  }

  Future<void> saveData(String key, dynamic value) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_normalizeKey(key), value);
  }

  Future<T?> getData<T>(String key) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_normalizeKey(key));
    if (raw == null) return null;
    try {
      if (T is Map<String, dynamic> && raw is Map) {
        return Map<String, dynamic>.from(raw) as T;
      } else {
        return raw as T;
      }
    } catch (e, s) {
      log('Error casting Hive data for key "$key": $e : $s');
      return null;
    }
  }

  Stream<T?> watch<T>(String key) async* {
    final box = await Hive.openBox(_boxName);
    final normalizedKey = _normalizeKey(key);

    final current = box.get(normalizedKey);
    if (current != null) {
      try {
        if (T is Map<String, dynamic> && current is Map) {
          yield Map<String, dynamic>.from(current) as T;
        } else {
          yield current as T;
        }
      } catch (e, s) {
        log('Error casting initial Hive value for key "$key": $e :: $s');
        yield null;
      }
    } else {
      yield null;
    }

    yield* box.watch(key: normalizedKey).map((event) {
      final value = event.value;
      try {
        if (T is Map<String, dynamic> && value is Map) {
          return Map<String, dynamic>.from(value) as T;
        } else {
          return value as T;
        }
      } catch (e, s) {
        log('Error casting watched Hive value for key "$key": $e :: $s');
        return null;
      }
    });
  }

  // Future<void> deleteData(String key) async {
  //   final box = await Hive.openBox(_boxName);
  //   await box.delete(_normalizeKey(key));
  // }

  // Future<void> clearAll() async {
  //   final box = await Hive.openBox(_boxName);
  //   await box.clear();
  // }
}
