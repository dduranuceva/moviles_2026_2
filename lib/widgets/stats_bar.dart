import 'package:flutter/material.dart';

//! Fila de stat: label + valor + barra de progreso con color según valor
class StatsBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;

  const StatsBar({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 255,
  });

  // color de la barra según el valor (rojo bajo, naranja medio, verde alto)
  Color get _barColor {
    if (value < 50) {
      return Colors.red.shade400;
    }
    if (value < 100) {
      return Colors.orange.shade400;
    }
    return Colors.green.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // nombre del stat con ancho fijo para alinear las barras
          SizedBox(
            width: 120,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          // valor numérico
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // barra de progreso
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
