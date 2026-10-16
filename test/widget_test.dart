import 'package:flutter_test/flutter_test.dart';
import 'package:projectappice/data/app_settings.dart';
import 'package:projectappice/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('KitchenAIApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettings();
    await settings.save(demoMode: true);

    await tester.pumpWidget(KitchenAIApp(settings: settings));
    await tester.pumpAndSettle();

    expect(find.text('KitchenAI'), findsOneWidget);
    expect(find.text('พิมพ์วัตถุดิบที่มี'), findsOneWidget);
    expect(find.text('ถ่ายรูปวัตถุดิบในตู้เย็น'), findsOneWidget);
  });
}
