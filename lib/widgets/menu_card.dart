import 'package:flutter/material.dart';
import '../models/menu_suggestion.dart';

class MenuCard extends StatefulWidget {
  const MenuCard({
    super.key,
    required this.menu,
    this.initiallyExpanded = false,
  });

  final MenuSuggestion menu;
  final bool initiallyExpanded;

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    final isFull = menu.missing.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Summary Row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          menu.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Missing / Full Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFull ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFull ? Colors.green.shade200 : Colors.orange.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFull ? Icons.check_circle : Icons.shopping_cart_outlined,
                              size: 13,
                              color: isFull ? Colors.green.shade800 : Colors.orange.shade800,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isFull ? 'ของครบ' : 'ซื้อเพิ่ม ${menu.missing.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isFull ? Colors.green.shade900 : Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (menu.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      menu.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        menu.time,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.bar_chart, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'ระดับ: ${menu.difficulty}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      Icon(
                        _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content (Ingredients & Steps)
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients Section
                  if (menu.ingredients.isNotEmpty) ...[
                    const Text(
                      'วัตถุดิบที่ใช้:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: menu.ingredients
                          .map((item) => Chip(
                                label: Text(item, style: const TextStyle(fontSize: 12)),
                                backgroundColor: Colors.grey.shade100,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Missing Items Section
                  if (menu.missing.isNotEmpty) ...[
                    Text(
                      'ของที่ต้องซื้อเพิ่ม (${menu.missing.length} อย่าง):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: menu.missing
                          .map((item) => Chip(
                                label: Text(item, style: const TextStyle(fontSize: 12)),
                                backgroundColor: Colors.orange.shade50,
                                side: BorderSide(color: Colors.orange.shade200),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Steps Section
                  if (menu.steps.isNotEmpty) ...[
                    const Text(
                      'ขั้นตอนการทำ:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: menu.steps.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: const Color(0xFF10B981),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  menu.steps[index],
                                  style: const TextStyle(fontSize: 13, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
