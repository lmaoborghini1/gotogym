import 'package:flutter/material.dart';
import 'camera_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 20),

                /// HEADER
                const Text(
                  "Welcome back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Today is your workout day",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                /// STATUS CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: const [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "No workout yet today",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// CAMERA BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white, // Text + Icon Farbe
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
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
                          const SnackBar(
                            content: Text("Workout confirmed"),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      "Post proof photo",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                /// GROUP TITLE
                const Text(
                  "Challenge Group",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 15),

                /// MEMBERS
                const _MemberTile(name: "Alex", isHere: true),
                const _MemberTile(name: "Sam", isHere: false),
                const _MemberTile(name: "Chris", isHere: true),
                const _MemberTile(name: "You", isHere: false),

                const SizedBox(height: 30),

                /// COMMENT BUTTON
                Center(
                  child: TextButton(
                    onPressed: () {
                      _openComments(context);
                    },
                    child: const Text("Open Comments"),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
    currentIndex: 0,
    selectedItemColor: Colors.deepPurple,
    unselectedItemColor: Colors.grey,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.group),
        label: "Group",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: "Profile",
      )
    ]
      )
    );
  }

  /// Bottom Sheet Kommentare
  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [

                  /// Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const Text(
                    "Comments",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// COMMENT LIST
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: const [
                        ListTile(
                          title: Text("Alex"),
                          subtitle: Text("Leg day done 💪"),
                        ),
                        ListTile(
                          title: Text("Sam"),
                          subtitle: Text("Hard session today"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// INPUT FIELD
                  Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.send),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 24,
            backgroundColor:
                isHere ? Colors.green : Colors.grey.shade400,
            child: Text(
              name[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Icon(
            isHere
                ? Icons.check_circle
                : Icons.remove_circle_outline,
            color:
                isHere ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
}
