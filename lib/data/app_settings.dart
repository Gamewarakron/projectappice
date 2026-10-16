import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_config.dart';
import 'ai_service.dart';
import 'gemini_client.dart';

class AppSettings extends ChangeNotifier {
  static const _keyApiKey = 'gemini_api_key';
  static const _keyDemo = 'demo_mode';

  String _apiKey = kDevApiKey;
  bool _demoMode = false;
  bool _loaded = false;

  String get apiKey => _apiKey;
  bool get demoMode => _demoMode;
  bool get loaded => _loaded;
  bool get hasApiKey => _apiKey.trim().isNotEmpty;

  /// พร้อมใช้ AI หรือยัง (มี key หรือเปิดโหมดสาธิต)
  bool get ready => demoMode || hasApiKey;

  /// สร้าง AiService ตามการตั้งค่าปัจจุบัน
  AiService get aiService =>
      _demoMode ? DemoAiService() : GeminiAiService(GeminiClient(apiKey: _apiKey));

  /// โหลดการตั้งค่าจาก shared_preferences
  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString(_keyApiKey) ?? kDevApiKey;
      _demoMode = prefs.getBool(_keyDemo) ?? false;
    } catch (_) {}
    _loaded = true;
    notifyListeners();
  }

  /// บันทึกการตั้งค่าลง shared_preferences
  Future<void> save({String? apiKey, bool? demoMode}) async {
    if (apiKey != null) _apiKey = apiKey.trim();
    if (demoMode != null) _demoMode = demoMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyApiKey, _apiKey);
      await prefs.setBool(_keyDemo, _demoMode);
    } catch (_) {}

    notifyListeners();
  }
}
