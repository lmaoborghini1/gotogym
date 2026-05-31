import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  bool isLogin = true;
  bool loading = false;

  Future<void> submit() async {
    try {
      setState(() {
        loading = true;
      });

      if (isLogin) {
        final userCredential =
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
  email: emailController.text.trim(),
  password: passwordController.text.trim(),
);
      
     } else {
  final userCredential =
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
    email: emailController.text.trim(),
    password: passwordController.text.trim(),
  );

  await FirebaseFirestore.instance
      .collection("users")
      .doc(userCredential.user!.uid)
      .set({
    "username": usernameController.text.trim(),
    "email": emailController.text.trim(),
    "streak": 0,
    "bestStreak": 0,
    "createdAt": Timestamp.now(),
  });
}
      Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => DashboardScreen(),
  ),
);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Error"),
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111114),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "gotogym",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

if (!isLogin)
  TextField(
    controller: usernameController,
    style: const TextStyle(color: Colors.white),
    decoration: const InputDecoration(
      hintText: "Username",
      hintStyle: TextStyle(color: Colors.grey),
    ),
  ),

              TextField(
                controller: emailController,
                
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "E-Mail",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(isLogin ? "Login" : "Create Account"),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin
                      ? "Create new account"
                      : "Already have an account?",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}