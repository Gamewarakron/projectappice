import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_bounding_box_overlay.dart';
import 'recipe_recommendation_screen.dart';

class IngredientDetectionScreen extends StatefulWidget {
  final XFile imageFile;
  final List<Ingredient> initialIngredients;

  const IngredientDetectionScreen({
    super.key,
    required this.imageFile,
    required this.initialIngredients,
  });

  @override
  State<IngredientDetectionScreen> createState() =>
      _IngredientDetectionScreenState();
}

class _IngredientDetectionScreenState
    extends State<IngredientDetectionScreen> {
  static const Color emerald = Color(0xFF10B981);
  late List<Ingredient> _ingredients;
  final TextEditingController _addController = TextEditingController();
  String _selectedCategoryFilter = 'all';
  Ingredient? _selectedIngredient;
  bool _showBoundingBoxes = true;
  bool _isImageExpanded = false;

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.initialIngredients);
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final text = _addController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _ingredients.add(
          Ingredient(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: text,
            category: _selectedCategoryFilter == 'all' ? 'other' : _selectedCategoryFilter,
            confidence: 1.0,
            isDetected: false,
          ),
        );
        _addController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      final removed = _ingredients.removeAt(index);
      if (_selectedIngredient == removed) {
        _selectedIngredient = null;
      }
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'meat':
        return Icons.kebab_dining;
      case 'vegetable':
        return Icons.eco;
      case 'seafood':
        return Icons.set_meal;
      case 'seasoning':
        return Icons.rice_bowl;
      default:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'meat':
        return const Color(0xFFEF4444);
      case 'vegetable':
        return const Color(0xFF10B981);
      case 'seafood':
        return const Color(0xFF3B82F6);
      case 'seasoning':
        return const Color(0xFFF59E0B);
      default:
        return Colors.purple.shade400;
    }
  }

  List<Ingredient> get _filteredIngredients {
    if (_selectedCategoryFilter == 'all') {
      return _ingredients;
    }
    return _ingredients
        .where((ing) => ing.category.toLowerCase() == _selectedCategoryFilter)
        .toList();
  }

  Widget _buildImageWidget() {
    if (kIsWeb) {
      return Image.network(
        widget.imageFile.path,
        fit: BoxFit.contain,
      );
    }
    return Image.file(
      File(widget.imageFile.path),
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('วัตถุดิบที่ตรวจพบ (AI Object Detection)'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _showBoundingBoxes ? Icons.visibility : Icons.visibility_off,
              color: _showBoundingBoxes ? emerald : Colors.grey,
            ),
            tooltip: 'เปิด/ปิด กรอบ AI Bounding Box',
            onPressed: () {
              setState(() {
                _showBoundingBoxes = !_showBoundingBoxes;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Image Preview Container - Fits original uploaded image 100% without cropping
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isImageExpanded ? 380 : 220,
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: IngredientBoundingBoxOverlay(
                        ingredients: _ingredients,
                        selectedIngredient: _selectedIngredient,
                        showBoxes: _showBoundingBoxes,
                        onIngredientTap: (ing) {
                          setState(() {
                            _selectedIngredient = ing;
                          });
                        },
                        child: _buildImageWidget(),
                      ),
                    ),
                  ),
                ),

                // Expand / Collapse Toggle Button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isImageExpanded = !_isImageExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isImageExpanded
                                ? Icons.unfold_less
                                : Icons.unfold_more,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isImageExpanded ? 'ย่อขนาดภาพ' : 'ขยายภาพดูเต็มจอ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Text(
                  'ตรวจพบ ${_ingredients.length} รายการ',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_selectedIngredient != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedIngredient = null;
                      });
                    },
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('ล้างการเลือก', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Add New Ingredient Input Field
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: InputDecoration(
                      hintText: 'เพิ่มวัตถุดิบ เช่น กระเทียม, ซอสถั่วเหลือง...',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: emerald),
                      ),
                    ),
                    onSubmitted: (_) => _addIngredient(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addIngredient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('เพิ่ม'),
                ),
              ],
            ),
          ),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('all', 'ทั้งหมด (${_ingredients.length})'),
                _buildFilterChip('meat', 'เนื้อสัตว์'),
                _buildFilterChip('vegetable', 'ผัก/สมุนไพร'),
                _buildFilterChip('seafood', 'อาหารทะเล'),
                _buildFilterChip('seasoning', 'เครื่องปรุง'),
              ],
            ),
          ),

          // List of Ingredients
          Expanded(
            child: _filteredIngredients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'ไม่มีรายการวัตถุดิบในหมวดหมู่นี้',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: _filteredIngredients.length,
                    itemBuilder: (context, index) {
                      final item = _filteredIngredients[index];
                      final origIndex = _ingredients.indexOf(item);
                      final catColor = _getCategoryColor(item.category);
                      final isSelected = _selectedIngredient == item;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? Colors.amber : Colors.transparent,
                            width: isSelected ? 2 : 0,
                          ),
                        ),
                        color: isSelected ? Colors.amber.shade50 : Colors.white,
                        elevation: isSelected ? 3 : 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() {
                              _selectedIngredient = isSelected ? null : item;
                              _isImageExpanded = true; // Auto expand image to see box!
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(item.category),
                                    color: catColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: item.isDetected
                                                  ? emerald.withValues(alpha: 0.1)
                                                  : Colors.blue.withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item.isDetected
                                                  ? 'AI Detect ${(item.confidence * 100).toInt()}%'
                                                  : 'เพิ่มเอง',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: item.isDetected
                                                    ? const Color(0xFF047857)
                                                    : Colors.blue.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          if (item.box2d != null) ...[
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.center_focus_strong,
                                              size: 14,
                                              color: isSelected ? Colors.amber.shade900 : Colors.grey,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              'กดเพื่อดูตำแหน่ง',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isSelected ? Colors.amber.shade900 : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.redAccent),
                                  onPressed: () => _removeIngredient(origIndex),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _ingredients.isEmpty
                    ? null
                    : () {
                        final stringList =
                            _ingredients.map((e) => e.name).toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeRecommendationScreen(
                              userIngredients: stringList,
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.search, size: 22),
                label: const Text(
                  'คำนวณหาสูตรอาหารที่ทำได้ (Find Recipes)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedCategoryFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        selectedColor: emerald,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? emerald : Colors.grey.shade300,
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategoryFilter = value;
          });
        },
      ),
    );
  }
}
