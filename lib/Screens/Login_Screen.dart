import 'package:activity/Screens/SignUp_Screen.dart';
import 'package:activity/Screens/demoHome.dart';
import 'package:activity/Screens/mainScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController=TextEditingController();
  final _passwordController=TextEditingController();
  final FirebaseFirestore _firestore= FirebaseFirestore.instance;

  Future<void> _loginUser() async{
    if(_emailController.text.isEmpty||_passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all details")),);
      return;
    }

    try{
      QuerySnapshot snapshot=await _firestore
          .collection('userDetails')
          .where('email',isEqualTo: _emailController.text.trim())
          .where('password',isEqualTo: _passwordController.text.trim())
          .get();

      if(snapshot.docs.isNotEmpty){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful!")),);
        Get.to(()=>MainScreen());
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.purple, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Card(
            color: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      GestureDetector(
                        onTap: () {

                        },
                        child: const Text(
                          "Forget Password",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async{
                      await _loginUser();
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
                      "Login",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(()=>SignupScreen());
                    },
                    child: Text(
                      "Don't have a account Register",
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
    ));
  }
}
