import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:otakunizados/provider/login_provider.dart';
import 'package:otakunizados/widgets/auth_background.dart'; // Importa el widget de fondo

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Color azulOscuro = const Color(0xFF0D47A1);

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return AuthBackground(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'Bienvenido a Otakunizados',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Campo para el correo electrónico
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

          // Campo para la contraseña
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

          // Botón para ingresar
          loginProvider.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulOscuro,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    final errorMessage = await loginProvider.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );

                    // Si hay error en el login, mostrar mensaje
                    if (errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    } else {
                      // Si el login es exitoso, redirigir al HomeScreen
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: const Text('Entrar', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),

          const SizedBox(height: 10),

          // Enlace para ir a la pantalla de olvido de contraseña
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forgot'),
            child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.white)),
          ),
          // Enlace para ir a la pantalla de registro
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('Crear cuenta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
