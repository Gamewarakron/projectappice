import 'package:flutter/foundation.dart';

class AppConfig extends ChangeNotifier {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal() {
    if (kIsWeb) {
      _serverUrl = 'http://localhost/food_app_api';
    } else {
      _serverUrl = 'http://10.0.2.2/food_app_api';
    }
  }

  String _serverUrl = kIsWeb ? 'http://localhost/food_app_api' : 'http://10.0.2.2/food_app_api';
  String _geminiApiKey = '';
  bool _useAiFallbackMode = true;

  String get serverUrl => _serverUrl;
  String get geminiApiKey => _geminiApiKey;
  bool get useAiFallbackMode => _useAiFallbackMode;

  void updateSettings({
    String? serverUrl,
    String? geminiApiKey,
    bool? useAiFallbackMode,
  }) {
    if (serverUrl != null && serverUrl.trim().isNotEmpty) {
      String url = serverUrl.trim();
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
      _serverUrl = url;
    }
    if (geminiApiKey != null) {
      _geminiApiKey = geminiApiKey.trim();
    }
    if (useAiFallbackMode != null) {
      _useAiFallbackMode = useAiFallbackMode;
    }
    notifyListeners();
  }
}
