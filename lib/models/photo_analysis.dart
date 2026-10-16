import 'dart:convert';

class FoundItem {
  FoundItem({
    required this.name,
    required this.amount,
    required this.note,
    this.box2d,
  });

  final String name;
  final String amount;
  final String note;
  final List<double>? box2d; // Normalized [ymin, xmin, ymax, xmax] 0.0 - 1.0

  factory FoundItem.fromJson(Map<String, dynamic> json) {
    List<double>? parsedBox;
    if (json['box_2d'] != null && json['box_2d'] is List) {
      parsedBox = (json['box_2d'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    return FoundItem(
      name: (json['name'] ?? '').toString(),
      amount: (json['amount'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      box2d: parsedBox,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'note': note,
        'box_2d': box2d,
      };
}

class PhotoAnalysis {
  PhotoAnalysis({
    required this.description,
    required this.items,
  });

  final String description;
  final List<FoundItem> items;

  List<String> get itemNames =>
      items.map((e) => e.name).where((e) => e.isNotEmpty).toList();

  factory PhotoAnalysis.fromJsonText(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    return PhotoAnalysis.fromJson(json);
  }

  factory PhotoAnalysis.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return PhotoAnalysis(
      description: (json['description'] ?? '').toString(),
      items: rawItems
          .map((e) => FoundItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'items': items.map((e) => e.toJson()).toList(),
      };
}
