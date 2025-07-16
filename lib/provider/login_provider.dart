import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otakunizados/services/login_services.dart';

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Wrapper para manejar loading automáticamente en operaciones asíncronas
  Future<T> runWithLoading<T>(Future<T> Function() operation) async {
    setLoading(true);
    try {
      return await operation();
    } finally {
      setLoading(false);
    }
  }

  
  Future<String?> register(String email, String password, String name) async {
    try {
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      
      try {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error al agregar usuario en Firestore: $e");
        return 'Error al guardar los datos en Firestore'; 
      }

      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message; 
    } catch (e) {
      return 'Ha ocurrido un error inesperado';
    }
  }

  
  Future<String?> login(String email, String password) async {
    try {
      
      if (email.isEmpty || password.isEmpty) {
        return 'Por favor ingresa ambos campos';
      }

     
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

     
      if (userCredential.user != null) {
        return null; 
      } else {
        return 'No se pudo iniciar sesión. Por favor, intenta de nuevo.';
      }
    } on FirebaseAuthException catch (e) {
      return e.message; 
    } catch (e) {
      return 'Ha ocurrido un error inesperado: ${e.toString()}';
    }
  }

  
  Future<String?> signInWithGoogle() async {
    return await runWithLoading(() async {
      final user = await AuthManager.instance.signInWithGoogle();
      if (user != null) {
        
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        return null;
      } else {
        return 'No se pudo iniciar sesión con Google';
      }
    });
  }

  
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Error desconocido al restablecer la contraseña');
    } catch (e) {
      throw Exception('Ha ocurrido un error inesperado');
    }
  }
}

