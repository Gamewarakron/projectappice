import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientBoundingBoxOverlay extends StatelessWidget {
  final List<Ingredient> ingredients;
  final Widget child;
  final Ingredient? selectedIngredient;
  final bool showBoxes;
  final Function(Ingredient)? onIngredientTap;

  const IngredientBoundingBoxOverlay({
    super.key,
    required this.ingredients,
    required this.child,
    this.selectedIngredient,
    this.showBoxes = true,
    this.onIngredientTap,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'meat':
        return const Color(0xFFEF4444); // Red
      case 'vegetable':
        return const Color(0xFF10B981); // Emerald Green
      case 'seafood':
        return const Color(0xFF3B82F6); // Blue
      case 'seasoning':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF8B5CF6); // Purple
    }
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentWidth = constraints.maxWidth;
        final parentHeight = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            child,

            if (showBoxes)
              ...ingredients.where((ing) => ing.box2d != null && ing.box2d!.length >= 4).map((ing) {
                final box = ing.box2d!;
                final ymin = box[0].clamp(0.0, 1.0);
                final xmin = box[1].clamp(0.0, 1.0);
                final ymax = box[2].clamp(0.0, 1.0);
                final xmax = box[3].clamp(0.0, 1.0);

                final left = xmin * parentWidth;
                final top = ymin * parentHeight;
                final boxWidth = (xmax - xmin) * parentWidth;
                final boxHeight = (ymax - ymin) * parentHeight;

                final isSelected = selectedIngredient != null &&
                    selectedIngredient!.name.trim().toLowerCase() == ing.name.trim().toLowerCase();

                final color = _getCategoryColor(ing.category);

                return Positioned(
                  left: left,
                  top: top,
                  width: boxWidth > 20 ? boxWidth : 80,
                  height: boxHeight > 20 ? boxHeight : 80,
                  child: GestureDetector(
                    onTap: () {
                      if (onIngredientTap != null) {
                        onIngredientTap!(ing);
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Bounding Box Rectangle / Ring
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.25)
                                : color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.amber : color,
                              width: isSelected ? 3.5 : 2.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                        ),

                        // Label Chip Overlay
                        Positioned(
                          top: -14,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.amber : color,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(ing.category),
                                  color: isSelected ? Colors.black87 : Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ing.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black87 : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
