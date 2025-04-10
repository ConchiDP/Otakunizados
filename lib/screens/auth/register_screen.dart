import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otakunizados/widgets/auth_background.dart';
import 'package:provider/provider.dart';
import 'package:otakunizados/provider/login_provider.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();  // Nombre del usuario
  final Color azulOscuro = const Color(0xFF0D47A1);

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: const Text(
          'Crear cuenta',
          style: TextStyle(color: Colors.white),
        ),
      ),
      
      // Usamos el AuthBackground para el diseño visual
      body: AuthBackground(
        child: Column(
          children: [
            const SizedBox(height: 20),  // Espacio después de la AppBar
            const SizedBox(height: 30),

            // Nombre del usuario
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D47A1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email input
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D47A1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password input
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D47A1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Show loading indicator while registering
            loginProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azulOscuro,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      loginProvider.setLoading(true);

                      // Registramos al usuario
                      final errorMessage = await loginProvider.register(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        nameController.text.trim(),
                      );
                      loginProvider.setLoading(false);

                      if (errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)),
                        );
                      } else {
                        // Si la cuenta se creó con éxito, vamos al login
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cuenta creada con éxito')),
                        );
                        await Future.delayed(const Duration(seconds: 2));
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    child: const Text('Crear cuenta', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
            const SizedBox(height: 10),

            // Navigation back to login
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('¿Ya tienes cuenta? Iniciar sesión', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
