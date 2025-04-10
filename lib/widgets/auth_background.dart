import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Image.asset(
                'assets/Otakunizados.jpg',
                height: 150,
              ),
            ),
            const SizedBox(height: 40),
            child, // Aquí meteremos el contenido de cada pantalla
          ],
        ),
      ),
    );
  }
}
