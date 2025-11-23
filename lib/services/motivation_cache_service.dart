import 'package:shared_preferences/shared_preferences.dart';

class MotivationCacheService {
  static const String _key = "motivational_message";

  // Guarda el mensaje
  Future<void> saveMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, message);
  }

  // Obtiene el mensaje
  Future<String?> getMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  // Borra el mensaje (cuando cierre sesión)
  Future<void> clearMessage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
