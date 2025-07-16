import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:otakunizados/provider/login_provider.dart'; // Asegúrate de que la ruta es correcta
import 'package:otakunizados/widgets/auth_background.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final Color azulOscuro = const Color(0xFF0D47A1);

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      // Aquí creamos el AppBar que contiene la flecha de retroceso
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(color: Colors.white),
        ),
      ),
      
      // Usamos el AuthBackground como contenedor del contenido
      body: AuthBackground(
        child: Column(
          children: [
            const SizedBox(height: 20),  // Espacio después de la AppBar
            const SizedBox(height: 30),

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
            const SizedBox(height: 30),

            // Show loading indicator while resetting the password
            loginProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azulOscuro,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      loginProvider.setLoading(true);
                      try {
                        await loginProvider.resetPassword(
                          emailController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Revisa tu correo para resetear la contraseña')),
                        );
                        await Future.delayed(const Duration(seconds: 2));
                        Navigator.pushReplacementNamed(context, '/login');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                        );
                      } finally {
                        loginProvider.setLoading(false);
                      }
                    },
                    child: const Text('Recuperar contraseña', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
            const SizedBox(height: 10),  // Espacio entre el botón y el texto

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

