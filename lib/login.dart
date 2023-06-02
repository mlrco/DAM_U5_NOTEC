import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text.trim();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: '$username@example.com',
        password: password,
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No se encontró un usuario con ese nombre');
      } else if (e.code == 'wrong-password') {
        print('Contraseña incorrecta');
      } else {
        print('Error al iniciar sesión: ${e.message}');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar sesión'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Nombre de usuario'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
