import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Método para crear una nueva cuenta
  Future<String?> register(String email, String password, String name) async {
    try {
      // Crear el usuario en Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar los detalles del usuario en Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error al agregar usuario en Firestore: $e");
        return 'Error al guardar los datos en Firestore'; // Retornamos un mensaje específico si falla
      }

      return null; // Si todo sale bien, no hay mensaje de error
    } on FirebaseAuthException catch (e) {
      return e.message; // Si hay un error en el registro, devolveremos el mensaje
    } catch (e) {
      return 'Ha ocurrido un error inesperado';
    }
  }

  // Método para hacer login
  Future<String?> login(String email, String password) async {
    try {
      // Verificar si el correo y la contraseña no están vacíos
      if (email.isEmpty || password.isEmpty) {
        return 'Por favor ingresa ambos campos';
      }

      // Intentamos hacer login con el correo y la contraseña proporcionados
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar si el usuario ha iniciado sesión correctamente
      if (userCredential.user != null) {
        return null; // Si todo es exitoso, no hay error
      } else {
        return 'No se pudo iniciar sesión. Por favor, intenta de nuevo.';
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // Devolvemos el mensaje de error si ocurre un error en Firebase
    } catch (e) {
      return 'Ha ocurrido un error inesperado: ${e.toString()}';
    }
  }

  // Método para restablecer la contraseña
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Si no hay errores, retornamos null
    } on FirebaseAuthException catch (e) {
      return e.message; // Devolvemos el mensaje de error si ocurre algún problema
    } catch (e) {
      return 'Ha ocurrido un error inesperado';
    }
  }
}
