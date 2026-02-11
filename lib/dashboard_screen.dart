import 'package:flutter/material.dart';
import 'group_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deine Gruppen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GroupTile(
            name: 'Gymbros',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GroupScreen(),
                ),
              );
            },
          ),
          _GroupTile(
            name: 'Push Pull Squad',
            onTap: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _GroupTile({
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
