class Ingredient {
  final String id;
  final String name;
  final String category; // 'meat', 'vegetable', 'seasoning', 'seafood', 'other'
  final String quantity;
  final String unit;
  final double confidence; // AI confidence score 0.0 - 1.0
  final bool isDetected;
  final List<double>? box2d; // Normalized [ymin, xmin, ymax, xmax] 0.0 - 1.0

  Ingredient({
    required this.id,
    required this.name,
    this.category = 'other',
    this.quantity = '1',
    this.unit = 'ส่วน',
    this.confidence = 1.0,
    this.isDetected = true,
    this.box2d,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? category,
    String? quantity,
    String? unit,
    double? confidence,
    bool? isDetected,
    List<double>? box2d,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      confidence: confidence ?? this.confidence,
      isDetected: isDetected ?? this.isDetected,
      box2d: box2d ?? this.box2d,
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    List<double>? parsedBox;
    if (json['box_2d'] != null && json['box_2d'] is List) {
      parsedBox = (json['box_2d'] as List).map((e) => (e as num).toDouble()).toList();
    }

    return Ingredient(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? 'other',
      quantity: json['quantity']?.toString() ?? '1',
      unit: json['unit'] ?? 'ส่วน',
      confidence: (json['confidence'] != null) ? (json['confidence'] as num).toDouble() : 1.0,
      isDetected: json['is_detected'] ?? true,
      box2d: parsedBox,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'confidence': confidence,
      'is_detected': isDetected,
      'box_2d': box2d,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          name.trim().toLowerCase() == other.name.trim().toLowerCase();

  @override
  int get hashCode => name.trim().toLowerCase().hashCode;
}
