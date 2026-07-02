import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _nameKey = 'user_display_name';

  // Simpan nama user ke penyimpanan lokal
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  // Ambil nama user saat aplikasi baru dibuka
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  // Hapus saat logout
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
  }
}
