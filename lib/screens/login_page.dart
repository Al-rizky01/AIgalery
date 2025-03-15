import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'MyHomePage.dart'; // Import halaman MyHomePage baru

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser(String email, String password) async {
  try {
    var bytes = utf8.encode(password);
    var hashedPassword = sha256.convert(bytes);

    // Menggunakan query untuk mencari user berdasarkan email
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userSnapshot = querySnapshot.docs.first;

      if (userSnapshot.get('password') == hashedPassword.toString()) {
        print("Login successful!");

        // Simpan userId ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userSnapshot.id);  // Simpan userId (bukan email)

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!")),
        );

        // Navigasi ke halaman MyHomePage setelah login berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()), 
        );
      } else {
        print("Invalid password!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid password!")),
        );
      }
    } else {
      print("User not found!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found!")),
      );
    }
  } catch (e) {
    print("Error logging in: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error logging in: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text;
                String password = _passwordController.text;
                loginUser(email, password); // Panggil fungsi login
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
