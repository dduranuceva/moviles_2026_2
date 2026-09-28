import 'package:flutter/material.dart';

import '../../widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Principal')),
      drawer: const CustomDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Electiva profesional de Moviles 2026-2',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
