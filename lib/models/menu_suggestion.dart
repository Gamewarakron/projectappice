import 'dart:convert';

class MenuSuggestion {
  MenuSuggestion({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.missing,
    required this.steps,
    required this.time,
    required this.difficulty,
  });

  final String name;
  final String description;
  final List<String> ingredients; // วัตถุดิบที่ใช้ (พร้อมปริมาณ)
  final List<String> missing; // ต้องซื้อเพิ่ม
  final List<String> steps; // ขั้นตอนทำ
  final String time;
  final String difficulty;

  factory MenuSuggestion.fromJson(Map<String, dynamic> json) => MenuSuggestion(
        name: (json['name'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        ingredients: _stringList(json['ingredients']),
        missing: _stringList(json['missing']),
        steps: _stringList(json['steps']),
        time: (json['time'] ?? '-').toString(),
        difficulty: (json['difficulty'] ?? '-').toString(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'ingredients': ingredients,
        'missing': missing,
        'steps': steps,
        'time': time,
        'difficulty': difficulty,
      };

  static List<String> _stringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}

class MenuResult {
  MenuResult({
    required this.summary,
    required this.menus,
  });

  final String summary;
  final List<MenuSuggestion> menus;

  factory MenuResult.fromJsonText(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    return MenuResult.fromJson(json);
  }

  factory MenuResult.fromJson(Map<String, dynamic> json) {
    final rawMenus = json['menus'] as List<dynamic>? ?? const [];
    return MenuResult(
      summary: (json['summary'] ?? '').toString(),
      menus: rawMenus
          .map((e) => MenuSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'menus': menus.map((e) => e.toJson()).toList(),
      };
}
