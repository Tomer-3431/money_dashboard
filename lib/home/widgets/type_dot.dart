import 'package:flutter/material.dart';
import 'package:money_dashboard/model/entry_type.dart';

/// Small colored circle that represents an entry's type.
class TypeDot extends StatelessWidget {
  const TypeDot({
    super.key,
    required this.type,
    required this.isIncome,
    this.size = 14,
  });

  final int type;
  final bool isIncome;
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: typeName(type: type, isIncome: isIncome),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: typeColor(context, type),
            shape: BoxShape.circle,
          ),
        ),
      );
}
