import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = true,
    required AppBar appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            // Imagen pequeña de Otakunizados en el banner
            Image.asset(
              'assets/Otakunizados.jpg',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            // Título de la app
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          // Menú desplegable con las opciones
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Cerrar sesión') {
                // Acción para cerrar sesión
                Navigator.pushReplacementNamed(context, '/login');
              } else if (value == 'Perfil') {
                // Acción para navegar al perfil (si lo tienes implementado)
              } else if (value == 'Configuración') {
                // Acción para la configuración (si lo tienes implementado)
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Perfil', 'Configuración', 'Cerrar sesión'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
