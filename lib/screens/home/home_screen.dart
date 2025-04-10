import 'package:flutter/material.dart';
import 'package:otakunizados/widgets/app_scaffold.dart'; // Importar AppScaffold

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bienvenido', // Título que aparece en el AppBar
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            const Text('Otakunizados', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          // Menú desplegable con las opciones
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Cerrar sesión') {
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
body: Container(
        color: Colors.white, // El fondo de toda la pantalla será blanco
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título con el fondo blanco y el texto dentro
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white, // Fondo blanco solo para el área de texto
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '¡Bienvenido a Otakunizados!',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Donde tu mundo otaku cobra vida.',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Botón Noticias
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D47A1), // Color azul similar al login
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Acción para ir a la pantalla de Noticias
                },
                child: const Text(
                  'Noticias',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              // Botón Calendario
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D47A1), // Color azul similar al login
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Acción para ir a la pantalla de Calendario
                },
                child: const Text(
                  'Calendario',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              // Botón Eventos
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D47A1), // Color azul similar al login
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Acción para ir a la pantalla de Eventos
                },
                child: const Text(
                  'Eventos',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}