import 'package:flutter/material.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111114),

      appBar: AppBar(
        backgroundColor: const Color(0xFF111114),
        title: Text(groupName),
      ),

      body: Center(
        child: Text(
          groupName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}