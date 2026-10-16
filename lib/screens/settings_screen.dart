import 'package:flutter/material.dart';
import '../data/app_settings.dart';
import '../data/gemini_client.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _keyCtrl;
  late bool _demo;
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;

  @override
  void initState() {
    super.initState();
    _keyCtrl = TextEditingController(text: widget.settings.apiKey);
    _demo = widget.settings.demoMode;
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  /// ส่งคำถามสั้น ๆ เพื่อเช็กว่า key ใช้ได้
  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });

    // บันทึกค่าที่พิมพ์ไว้ก่อน แล้วค่อยสร้าง service จากค่าล่าสุด
    await widget.settings.save(apiKey: _keyCtrl.text, demoMode: _demo);

    try {
      final reply = await widget.settings.aiService.ping();
      if (!mounted) return;
      setState(() {
        _testOk = true;
        _testResult = reply;
      });
    } on AiException catch (e) {
      if (!mounted) return;
      setState(() {
        _testOk = false;
        _testResult = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testOk = false;
        _testResult = 'เกิดข้อผิดพลาด: $e';
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    await widget.settings.save(apiKey: _keyCtrl.text, demoMode: _demo);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกการตั้งค่าเรียบร้อยแล้ว'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่าระบบ & Gemini API Key')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '1. Gemini API Key:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keyCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'ใส่ API Key ที่ได้จาก aistudio.google.com/apikey',
              prefixIcon: Icon(Icons.key),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '* สมัครและขอ API Key ฟรีได้ที่ aistudio.google.com/apikey',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 24),

          // Demo Mode Switch
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: SwitchListTile(
              title: const Text(
                'โหมดสาธิต (Demo Mode)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'ตอบข้อมูลจำลอง ไม่ต้องใช้เน็ตหรือ API key',
                style: TextStyle(fontSize: 12),
              ),
              value: _demo,
              activeThumbColor: Colors.amber.shade800,
              onChanged: (val) {
                setState(() {
                  _demo = val;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Test Button
          OutlinedButton.icon(
            onPressed: _testing ? null : _test,
            icon: _testing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_alt),
            label: Text(_testing ? 'กำลังทดสอบ...' : 'ทดสอบการเชื่อมต่อ'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          if (_testResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _testOk ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _testOk ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _testOk ? Icons.check_circle : Icons.error,
                    color: _testOk ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _testResult!,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            _testOk ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('บันทึกการตั้งค่า'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
