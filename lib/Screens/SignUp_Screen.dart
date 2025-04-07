import 'package:activity/Screens/Login_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController=TextEditingController();

  final _emailController=TextEditingController();

  final _passwordController=TextEditingController();

  final _confirm_P_Controller=TextEditingController();

  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  Future<void> _saveUsertoFirebase() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty ||
        _passwordController.text.isEmpty || _confirm_P_Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }
    if (_passwordController.text != _confirm_P_Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      await _firestore.collection('userDetails').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful!")),
      );
      Get.to(() => LoginScreen());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirm_P_Controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyanAccent, Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Card(
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.white70,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white))),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.white70,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white))),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.password,
                            color: Colors.white70,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white70)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white)),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _confirm_P_Controller,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.password,
                            color: Colors.white70,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white70)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white)),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async{
                          await _saveUsertoFirebase();
                          Get.to(()=>LoginScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          "Sign UP",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(()=>LoginScreen());
                        },
                        child: Text(
                          "Already have an account",
                          style: TextStyle(
                              color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )

    );


  }
}
