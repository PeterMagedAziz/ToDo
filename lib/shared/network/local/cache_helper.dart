import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences sharedPreferences;

  static cacheInit() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> putBoolean({
    String key,
    bool value,
  }) async {
    return await sharedPreferences.setBool(key, value);
  }

  static dynamic getData({
    String key,
  }) {
    return sharedPreferences.get(key);
  }

  static Future<bool> saveData({
    String key,
    dynamic value,
  }) async {
    if (value is String) return await sharedPreferences.setString(key, value);
    if (value is int) return await sharedPreferences.setInt(key, value);
    if (value is bool) return await sharedPreferences.setBool(key, value);

    return await sharedPreferences.setDouble(key, value);
  }

  static Future<bool> removeData({
    String key,
  }) async {
    return await sharedPreferences.remove(key);
  }
}
