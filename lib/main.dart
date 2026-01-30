import 'package:flutter/material.dart';
import 'camera_screen.dart';

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
          onPressed: () async {
  final imagePath = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CameraScreen(),
    ),
  );

  if (imagePath != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status: DA')),
    );
  }
},

          child: const Text('CLICK HERE'),
        ),
      ),
    );
  }
}
