import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import 'recipe_detail_screen.dart';

class RecipeRecommendationScreen extends StatefulWidget {
  final List<String> userIngredients;

  const RecipeRecommendationScreen({
    super.key,
    required this.userIngredients,
  });

  @override
  State<RecipeRecommendationScreen> createState() =>
      _RecipeRecommendationScreenState();
}

class _RecipeRecommendationScreenState
    extends State<RecipeRecommendationScreen> {
  static const Color emerald = Color(0xFF10B981);
  final DatabaseService _dbService = DatabaseService();
  final AIService _aiService = AIService();

  bool _isLoading = true;
  List<Recipe> _allMatchedRecipes = [];
  String _filterMode = 'all'; // '100', 'partial', 'all'
  bool _isGeneratingAiRecipe = false;

  @override
  void initState() {
    super.initState();
    _loadMatchingRecipes();
  }

  Future<void> _loadMatchingRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipes =
          await _dbService.searchRecipesByIngredients(widget.userIngredients);

      if (mounted) {
        setState(() {
          _allMatchedRecipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateCustomAiRecipe() async {
    setState(() {
      _isGeneratingAiRecipe = true;
    });

    try {
      final aiRecipe =
          await _aiService.generateCustomRecipeFromAi(widget.userIngredients);

      if (mounted) {
        setState(() {
          _isGeneratingAiRecipe = false;
          _allMatchedRecipes.insert(0, aiRecipe);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รังสรรค์เมนูสร้างสรรค์จาก AI สำเร็จแล้ว!'),
            backgroundColor: emerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingAiRecipe = false;
        });
      }
    }
  }

  List<Recipe> get _displayedRecipes {
    if (_filterMode == '100') {
      return _allMatchedRecipes
          .where((r) => r.matchPercentage >= 100.0)
          .toList();
    } else if (_filterMode == 'partial') {
      return _allMatchedRecipes
          .where((r) => r.matchPercentage < 100.0 && r.matchPercentage >= 40.0)
          .toList();
    }
    return _allMatchedRecipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('คำนวณสูตรอาหารที่ทำได้'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Ingredients Summary Bar
          Container(
            color: emerald.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.soup_kitchen, color: emerald),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'วัตถุดิบของคุณ: ${widget.userIngredients.join(', ')}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Filters Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip('all', 'ทั้งหมด (${_allMatchedRecipes.length})'),
                  _buildTabChip(
                      '100',
                      'วัตถุดิบครบ 100% (${_allMatchedRecipes.where((r) => r.matchPercentage >= 100).length})'),
                  _buildTabChip(
                      'partial',
                      'วัตถุดิบใกล้เคียง (${_allMatchedRecipes.where((r) => r.matchPercentage < 100 && r.matchPercentage >= 40).length})'),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Main Body List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: emerald),
                        SizedBox(height: 16),
                        Text('กำลังคำนวณและดึงข้อมูลสูตรอาหาร...'),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Banner AI Recipe Generator Option
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome,
                                color: Colors.amber, size: 36),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'อยากลองเมนูแปลกใหม่ไหม?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ให้ AI คิดสูตรอาหารใหม่เฉพาะตัวให้คุณทันที',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isGeneratingAiRecipe
                                  ? null
                                  : _generateCustomAiRecipe,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: _isGeneratingAiRecipe
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black87,
                                      ),
                                    )
                                  : const Text(
                                      'สร้างด้วย AI',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      if (_displayedRecipes.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.search_off_outlined,
                                    size: 56, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                  'ไม่พบสูตรอาหารในเงื่อนไขนี้',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ลองเปลี่ยนตัวกรอง หรือกดปุ่ม "สร้างด้วย AI" ด้านบนเพื่อรังสรรค์เมนูใหม่',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._displayedRecipes
                            .map((recipe) => _buildRecipeCard(recipe)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String value, String label) {
    final isSelected = _filterMode == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        selectedColor: emerald,
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? emerald : Colors.transparent,
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _filterMode = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final isFullMatch = recipe.matchPercentage >= 100.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Banner Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: recipe.imageUrl.isNotEmpty
                      ? Image.network(
                          recipe.imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholderBanner(recipe),
                        )
                      : _buildPlaceholderBanner(recipe),
                ),

                // Match Percentage Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isFullMatch ? emerald : Colors.orange.shade800,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFullMatch ? Icons.check_circle : Icons.tune,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ตรงกัน ${recipe.matchPercentage.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (recipe.isAiGenerated)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'เมนู AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Recipe Metadata
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          recipe.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    recipe.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Missing Ingredients Warning (if applicable)
                  if (recipe.missingIngredients.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.orange.shade800),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'ขาดวัตถุดิบ: ${recipe.missingIngredients.join(', ')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTime + recipe.cookTime} นาที',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.bar_chart_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'ความยาก: ${recipe.difficulty}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'ดูขั้นตอนการทำ >',
                        style: TextStyle(
                          fontSize: 13,
                          color: emerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBanner(Recipe recipe) {
    return Container(
      height: 160,
      width: double.infinity,
      color: emerald.withValues(alpha: 0.15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 48, color: emerald),
            const SizedBox(height: 6),
            Text(
              recipe.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF065F46),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
