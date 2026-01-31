import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const GoToGymApp());
}

class GoToGymApp extends StatelessWidget {
  const GoToGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoToGym',
      home: HomeScreen(),
    );
  }
}
