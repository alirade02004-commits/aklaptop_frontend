import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userCont = TextEditingController();
  final passCont = TextEditingController();
  final String apiUrl = "https://campus-backend-1-jxul.onrender.com";

  Future<void> register() async {
    if (userCont.text.isEmpty || passCont.text.isEmpty) return;

    final response = await http.post(
      Uri.parse("$apiUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": userCont.text, "password": passCont.text}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! Please Login.")));
      Navigator.pop(context); // Go back to login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: User might already exist")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 70, color: Colors.blue),
            TextField(controller: userCont, decoration: const InputDecoration(labelText: "New Username")),
            TextField(controller: passCont, decoration: const InputDecoration(labelText: "New Password"), obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: register, child: const Text("REGISTER")),
          ],
        ),
      ),
    );
  }
}
