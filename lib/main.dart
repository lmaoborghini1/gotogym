import 'package:flutter/material.dart';

void main() {
  runApp(const GoToGymApp());
}

class GoToGymApp extends StatelessWidget {
  const GoToGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoToGym',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoToGym'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // kommt später
          },
          child: const Text('CLICK HERE'),
        ),
      ),
    );
  }
}
