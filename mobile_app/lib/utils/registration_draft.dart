import 'package:shared_preferences/shared_preferences.dart';
import '../models/registration_data.dart';

class RegistrationDraft {
  static const _key = 'registration_draft';

  static Future<void> save(RegistrationData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, data.toJson());
  }

  static Future<RegistrationData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    return RegistrationData.fromJson(json);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
