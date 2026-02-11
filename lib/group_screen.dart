import 'package:flutter/material.dart';
import 'camera_screen.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'GoToGym',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gruppeninfo
            const Text(
              'Gruppe: Gymbros',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Training heute um 18:00',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Status
            const Text(
              'Du warst heute\nnoch nicht da',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Hauptaktion
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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

                child: const Text(
                  'Beweisfoto senden',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Gruppenstatus
            const Text(
              'Heute dabei',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: const [
                  _MemberTile(name: 'Alex', isHere: true),
                  _MemberTile(name: 'Sam', isHere: false),
                  _MemberTile(name: 'Chris', isHere: true),
                  _MemberTile(name: 'Du', isHere: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String name;
  final bool isHere;

  const _MemberTile({
    required this.name,
    required this.isHere,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isHere ? Colors.green : Colors.grey,
            child: Text(
              name[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Icon(
            isHere ? Icons.check_circle : Icons.remove_circle,
            color: isHere ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
}
