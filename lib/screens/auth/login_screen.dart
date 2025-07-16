import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:otakunizados/provider/login_provider.dart';
import 'package:otakunizados/widgets/auth_background.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Color azulOscuro = const Color(0xFF0D47A1);
  bool _obscurePassword = true;

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

          
          TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0D47A1)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
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

                    
                    if (errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    } else {
                      
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: const Text('Entrar', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),

          const SizedBox(height: 20),

          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: azulOscuro,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () async {
              final errorMessage = await loginProvider.signInWithGoogle();
              if (errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: const Text('Continuar con Google', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),

          const SizedBox(height: 10),

          
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forgot'),
            child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.white)),
          ),
         
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('Crear cuenta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

