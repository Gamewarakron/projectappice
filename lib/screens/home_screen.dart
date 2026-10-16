import 'package:flutter/material.dart';
import '../data/app_settings.dart';
import 'ingredients_screen.dart';
import 'photo_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.restaurant_menu, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text('KINRAIDee', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'ตั้งค่าระบบ',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(settings: settings),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Warning Banner if API Key is not set and demo mode is OFF
              if (!settings.ready) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.amber.shade900, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ยังไม่ได้ตั้งค่า Gemini API key',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ไปที่หน้าตั้งค่าเพื่อใส่ Key หรือเปิดโหมดสาธิตก่อนใช้งาน',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(settings: settings),
                            ),
                          );
                        },
                        child: const Text('ไปตั้งค่า'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Hero Welcome Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.amber, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'เชฟ AI ประจำบ้านคุณ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'พิมพ์วัตถุดิบที่มี หรือถ่ายรูปของในตู้เย็น แล้วให้ Gemini AI ช่วยคิดเมนูและสอนทำทีละขั้นตอน!',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Feature Card 1: Ingredients Input
              _buildFeatureCard(
                context,
                title: 'พิมพ์วัตถุดิบที่มี',
                subtitle: 'เช่น ไข่, หมูสับ, กระเทียม แล้วให้ AI คิดเมนู 3 รายการ',
                icon: Icons.edit_note_rounded,
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IngredientsScreen(ai: settings.aiService),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Feature Card 2: Photo Analysis
              _buildFeatureCard(
                context,
                title: 'ถ่ายรูปวัตถุดิบในตู้เย็น',
                subtitle: 'ถ่ายรูปวัตถุดิบบนโต๊ะหรือตู้เย็น ให้ AI ดูว่ามีอะไรบ้างแล้วแนะนำเมนู',
                icon: Icons.camera_enhance_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoScreen(ai: settings.aiService),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Feature Card 3: Settings
              _buildFeatureCard(
                context,
                title: 'ตั้งค่าระบบ & API Key',
                subtitle: 'ใส่ Gemini API Key หรือเปิดใช้งานโหมดสาธิต (Demo Mode)',
                icon: Icons.settings_outlined,
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(settings: settings),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
