import 'package:flutter/material.dart';
import 'screens/inicio.1.dart';  

void main() {
  runApp(OtakunizadosApp());
}

class OtakunizadosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otakunizados',
      theme: ThemeData(
        primaryColor: Color(0xFF00BFFF),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: HomePage(),  // Aquí cargamos la pantalla de inicio
    );
  }
}
