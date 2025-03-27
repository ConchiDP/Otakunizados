import 'package:flutter/material.dart';

void main() {
  runApp(OtakunizadosApp());
}

class OtakunizadosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otakunizados',
      theme: ThemeData(
        primaryColor: Color(0xFF00BFFF), // otaku-blue
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/Otakunizados.jpg',
          height: 40,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00BFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Iniciar Sesión'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
          ],
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo
        Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/anime.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color.fromRGBO(0, 0, 0, 0.658), // Color negro con opacidad
                BlendMode.darken,
              ),
            ),
          ),
        ),
        // Contenido de la sección de héroe
        Container(
          padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
          child: Column(
            children: [
              // Imagen del logo ajustada
              Image.asset(
                'assets/images/logo.png',
                width: MediaQuery.of(context).size.width * 0.5, // Ajusta el logo para que no se desborde
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30),
              // Texto con descripción
              Text(
                'Donde tu mundo otaku cobra vida.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32, // Reducido para ajustarse mejor
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Descubre las últimas noticias, estrenos, eventos y conecta con otros fans como tú.',
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.8), // Blanco con opacidad
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [// Botón para explorar
                 Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                     style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,  // Fondo negro
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      child: Text(
                        'Registrarse',
                        style: TextStyle(color: Colors.white),  // Texto blanco
                        ),
                         ),
                         ),
                         ],
                         )
            ],
          ),
        ),
      ],
    );
  }
}