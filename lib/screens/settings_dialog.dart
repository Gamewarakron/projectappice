import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/app_config.dart';
import '../services/database_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  static const Color emerald = Color(0xFF10B981);
  final AppConfig _config = AppConfig();
  final DatabaseService _dbService = DatabaseService();

  late TextEditingController _urlController;
  late TextEditingController _apiKeyController;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _config.serverUrl);
    _apiKeyController = TextEditingController(text: _config.geminiApiKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    _config.updateSettings(
      serverUrl: _urlController.text,
      geminiApiKey: _apiKeyController.text,
    );

    final connected = await _dbService.checkServerConnection();

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = connected;
        _testResult = connected
            ? 'เชื่อมต่อ XAMPP MySQL Backend สำเร็จ!'
            : 'ไม่พบ XAMPP MySQL Server ที่ URL นี้ (กรุณาตรวจสอบว่าเริ่ม MySQL ใน XAMPP แล้ว)';
      });
    }
  }

  void _saveSettings() {
    _config.updateSettings(
      serverUrl: _urlController.text,
      geminiApiKey: _apiKeyController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกการตั้งค่าเรียบร้อยแล้ว'),
        backgroundColor: emerald,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(Icons.settings, color: emerald),
          SizedBox(width: 8),
          Text(
            'ตั้งค่าระบบ & Database',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. XAMPP / MySQL API Endpoint:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: kIsWeb ? 'http://localhost/food_app_api' : 'http://10.0.2.2/food_app_api',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 6),
            
            // Quick URL Preset Buttons
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ActionChip(
                  label: const Text('Localhost (Web/Mac)', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.grey.shade100,
                  onPressed: () {
                    setState(() {
                      _urlController.text = 'http://localhost/food_app_api';
                    });
                  },
                ),
                ActionChip(
                  label: const Text('Android Emulator', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.grey.shade100,
                  onPressed: () {
                    setState(() {
                      _urlController.text = 'http://10.0.2.2/food_app_api';
                    });
                  },
                ),
                ActionChip(
                  label: const Text('IP เครือข่าย (192.168.x.x)', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.grey.shade100,
                  onPressed: () {
                    setState(() {
                      _urlController.text = 'http://192.168.1.100/food_app_api';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              '2. Google Gemini AI API Key (Optional):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'ใส่ API Key สำหรับ AI Detection & Recipes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '* หากไม่ระบุ แอปจะใช้ Smart Vision Engine และ AI Generator จำลองในการประมวลผล',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            // Test Connection Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_alt, size: 18),
                label: Text(_isTesting
                    ? 'กำลังทดสอบเชื่อมต่อ...'
                    : 'ทดสอบเชื่อมต่อ XAMPP Server'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: emerald,
                  side: const BorderSide(color: emerald),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            if (_testResult != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _testSuccess
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle : Icons.info,
                      color: _testSuccess
                          ? Colors.green.shade700
                          : Colors.orange.shade800,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _testSuccess
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: emerald,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}
