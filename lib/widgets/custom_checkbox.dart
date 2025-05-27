import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

class CustomCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  static const checkIcon = pw.IconData(0x2713);
  
  const CustomCheckbox({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(
                color: value ? const Color(0xFF3A98B9) : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              color: value ? const Color(0xFF3A98B9) : Colors.white,
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
