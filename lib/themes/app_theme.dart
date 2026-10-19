import 'package:flutter/material.dart';

class AppTheme {
  //! tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 29, 23, 202), // Color semilla
        brightness: Brightness.light, // Tema claro
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 20, 66, 165), // Color del AppBar
        titleTextStyle: TextStyle(
          color: Colors.white, // Texto blanco para el AppBar
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        elevation: 0,
        backgroundColor: Colors.white, // Fondo del Drawer
      ),
      // En Flutter 3.47 el theme de cards es CardThemeData (CardTheme ya no existe)
      cardTheme: CardThemeData(
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87), // Estilo de texto
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );
  }
}
