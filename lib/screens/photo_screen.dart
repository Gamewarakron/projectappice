import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/ai_service.dart';
import '../data/gemini_client.dart';
import '../models/ingredient.dart';
import '../models/photo_analysis.dart';
import '../widgets/error_box.dart';
import '../widgets/ingredient_bounding_box_overlay.dart';
import 'ingredients_screen.dart';

/// หน้า "ถ่ายรูป" → ส่งรูปให้ AI → แสดงของที่เห็นพร้อมวงตำแหน่ง → ต่อยอดเป็นเมนู
class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key, required this.ai});

  final AiService ai;

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final _picker = ImagePicker();
  Uint8List? _imageBytes; // รูปที่เลือก (เป็น bytes พร้อมส่ง)
  String _mimeType = 'image/jpeg';
  bool _loading = false;
  String? _error;
  PhotoAnalysis? _result;
  FoundItem? _selectedItem;
  bool _showBoxes = true;

  /// เปิดกล้องหรือคลังรูป แล้วย่อรูปให้เล็กลงก่อนส่ง (ประหยัดเน็ตและโควตา)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (file == null) return; // ผู้ใช้กดยกเลิก
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _mimeType = file.mimeType ?? _guessMime(file.name);
      _result = null;
      _error = null;
      _selectedItem = null;
    });
  }

  static String _guessMime(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  /// ส่งรูปไปให้ AI วิเคราะห์
  Future<void> _analyze() async {
    final bytes = _imageBytes;
    if (bytes == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _selectedItem = null;
    });

    try {
      final result = await widget.ai.analyzePhoto(bytes, mimeType: _mimeType);
      if (!mounted) return;
      setState(() => _result = result);
    } on AiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'อ่านคำตอบของ AI ไม่ได้: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// เอาชื่อของที่ AI เห็น ไปเปิดหน้า "เมนูจากวัตถุดิบ"
  void _suggestMenus() {
    final names = _result?.itemNames ?? const [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IngredientsScreen(
          ai: widget.ai,
          initialIngredients: names,
        ),
      ),
    );
  }

  String _guessCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('หมู') || n.contains('ไก่') || n.contains('เนื้อ') || n.contains('ไข่')) {
      return 'meat';
    }
    if (n.contains('กุ้ง') || n.contains('ปลา') || n.contains('หมึก')) {
      return 'seafood';
    }
    if (n.contains('ซอส') || n.contains('น้ำปลา') || n.contains('พริกเผา') || n.contains('เต้าเจี้ยว')) {
      return 'seasoning';
    }
    return 'vegetable';
  }

  @override
  Widget build(BuildContext context) {
    final sizeKb = _imageBytes == null
        ? null
        : (_imageBytes!.lengthInBytes / 1024).round();

    final ingredientsForOverlay = _result?.items
            .map((item) => Ingredient(
                  id: item.name,
                  name: item.name,
                  category: _guessCategory(item.name),
                  box2d: item.box2d,
                ))
            .toList() ??
        [];

    final selectedIngredient = _selectedItem != null
        ? Ingredient(
            id: _selectedItem!.name,
            name: _selectedItem!.name,
            category: _guessCategory(_selectedItem!.name),
            box2d: _selectedItem!.box2d,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ถ่ายรูปวัตถุดิบ'),
        actions: [
          if (_result != null)
            IconButton(
              icon: Icon(
                _showBoxes ? Icons.visibility : Icons.visibility_off,
                color: _showBoxes ? const Color(0xFF10B981) : Colors.grey,
              ),
              tooltip: 'เปิด/ปิด กรอบ AI Bounding Box',
              onPressed: () {
                setState(() {
                  _showBoxes = !_showBoxes;
                });
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- พื้นที่แสดงรูปพร้อม AI Bounding Box Overlay ----
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageBytes == null
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined,
                              size: 56, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('ยังไม่ได้เลือกรูป',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : IngredientBoundingBoxOverlay(
                      ingredients: ingredientsForOverlay,
                      selectedIngredient: selectedIngredient,
                      showBoxes: _showBoxes,
                      onIngredientTap: (ing) {
                        final found = _result?.items.firstWhere(
                          (i) => i.name.trim().toLowerCase() == ing.name.trim().toLowerCase(),
                          orElse: () => FoundItem(name: ing.name, amount: '', note: ''),
                        );
                        setState(() {
                          _selectedItem = found;
                        });
                      },
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    ),
            ),
          ),
          if (sizeKb != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'ขนาดรูปที่จะส่ง: $sizeKb KB ($_mimeType)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _loading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('ถ่ายรูป'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _loading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('เลือกจากคลัง'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          FilledButton.icon(
            onPressed: (_imageBytes == null || _loading) ? null : _analyze,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_loading ? 'AI กำลังดูรูป...' : 'ให้ AI วิเคราะห์รูป'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              ),
            ),
          if (_error != null) ErrorBox(message: _error!, onRetry: _analyze),
          if (_result != null) ..._buildResult(_result!),
        ],
      ),
    );
  }

  List<Widget> _buildResult(PhotoAnalysis r) => [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI เห็นอะไรในรูป',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(r.description),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (r.items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('ไม่พบวัตถุดิบในรูปนี้'),
          )
        else
          ...r.items.map(
            (it) {
              final isSelected = _selectedItem == it;
              return Card(
                elevation: isSelected ? 3 : 1,
                color: isSelected ? Colors.amber.shade50 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Colors.amber : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text(
                    it.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    [it.amount, it.note]
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                  ),
                  trailing: const Icon(Icons.center_focus_strong, size: 16, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      _selectedItem = isSelected ? null : it;
                    });
                  },
                ),
              );
            },
          ),
        if (r.items.isNotEmpty) ...[
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _suggestMenus,
            icon: const Icon(Icons.restaurant_menu),
            label: Text('แนะนำเมนูจากของ ${r.items.length} อย่างนี้'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ];
}
