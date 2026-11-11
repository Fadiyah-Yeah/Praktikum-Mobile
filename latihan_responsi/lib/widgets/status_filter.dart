
import 'package:flutter/material.dart';

class StatusFilter extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelected;

  const StatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onSelected,
  });

  static const List<String> statuses = [
    'All',
    'Alive',
    'Dead',
    'Unknown',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final isSelected = selectedStatus == status;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                status == 'All' ? 'Semua' : status,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF302522),
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(status),
              backgroundColor: const Color(0xFFFCEED6),
              selectedColor: const Color(0xFFA3C86D),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFA3C86D)
                    : const Color(0xFFDCC6A9),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
