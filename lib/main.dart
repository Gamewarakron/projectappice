import 'package:flutter/material.dart';
import 'data/app_settings.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  await settings.load();
  runApp(KitchenAIApp(settings: settings));
}

class KitchenAIApp extends StatelessWidget {
  const KitchenAIApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KitchenAI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: HomeScreen(settings: settings),
    );
  }
}
