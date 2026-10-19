import 'package:flutter/material.dart';

import '../themes/type_colors.dart';

//! Pill compacta con el color del tipo y el nombre en mayúsculas
class TypeChip extends StatelessWidget {
  final String type;

  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: typeColor(type),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
