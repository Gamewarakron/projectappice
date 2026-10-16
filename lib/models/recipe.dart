class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final String nutritionalInfo;
  final double matchPercentage;
  final List<String> missingIngredients;
  final bool isFavorite;
  final bool isAiGenerated;
  final String chefTip;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    this.category = 'อาหารทั่วไป',
    this.prepTime = 10,
    this.cookTime = 15,
    this.servings = 2,
    this.difficulty = 'ง่าย',
    this.imageUrl = '',
    required this.ingredients,
    required this.instructions,
    this.nutritionalInfo = 'ประมาณ 350-450 แคลอรี',
    this.matchPercentage = 100.0,
    this.missingIngredients = const [],
    this.isFavorite = false,
    this.isAiGenerated = false,
    this.chefTip = 'สามารถปรับเปลี่ยนปริมาณเครื่องปรุงได้ตามความชอบ',
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? instructions,
    String? nutritionalInfo,
    double? matchPercentage,
    List<String>? missingIngredients,
    bool? isFavorite,
    bool? isAiGenerated,
    String? chefTip,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      missingIngredients: missingIngredients ?? this.missingIngredients,
      isFavorite: isFavorite ?? this.isFavorite,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      chefTip: chefTip ?? this.chefTip,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String) return raw.split('\n').where((s) => s.trim().isNotEmpty).toList();
      return [];
    }

    return Recipe(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? json['name'] ?? 'สูตรอาหาร',
      description: json['description'] ?? '',
      category: json['category'] ?? 'อาหารไทย',
      prepTime: json['prep_time'] != null ? int.tryParse(json['prep_time'].toString()) ?? 10 : 10,
      cookTime: json['cook_time'] != null ? int.tryParse(json['cook_time'].toString()) ?? 15 : 15,
      servings: json['servings'] != null ? int.tryParse(json['servings'].toString()) ?? 2 : 2,
      difficulty: json['difficulty'] ?? 'ง่าย',
      imageUrl: json['image_url'] ?? '',
      ingredients: parseList(json['ingredients']),
      instructions: parseList(json['instructions']),
      nutritionalInfo: json['nutritional_info'] ?? 'ประมาณ 350-450 แคลอรี',
      matchPercentage: (json['match_percentage'] != null)
          ? (json['match_percentage'] as num).toDouble()
          : 100.0,
      missingIngredients: parseList(json['missing_ingredients']),
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1 || json['is_favorite'] == '1',
      isAiGenerated: json['is_ai_generated'] == true || json['is_ai_generated'] == 1 || json['is_ai_generated'] == '1',
      chefTip: json['chef_tip'] ?? 'ปรุงตามความชอบของคุณเพื่อรสชาติที่ดีที่สุด',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      'difficulty': difficulty,
      'image_url': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'nutritional_info': nutritionalInfo,
      'match_percentage': matchPercentage,
      'missing_ingredients': missingIngredients,
      'is_favorite': isFavorite,
      'is_ai_generated': isAiGenerated,
      'chef_tip': chefTip,
    };
  }
}
