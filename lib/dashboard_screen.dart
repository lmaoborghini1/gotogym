import 'package:flutter/material.dart';
import 'camera_screen.dart';

enum TrainingStatus {
  completed,
  dueToday,
  upcoming,
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _workedOutToday = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHome(),
      const Center(
        child: Text(
          "Gruppe",
          style: TextStyle(color: Colors.white),
        ),
      ),
      _buildProfile(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF111114),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1C1C22),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_rounded),
            label: "Gruppe",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // ================= HOME =================

  Widget _buildHome() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Heute",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),
            _statusCard(),
            const SizedBox(height: 25),
            _proofCard(),
            const SizedBox(height: 30),
            const Text(
              "Gym Gruppe",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            _memberTile("Alex", TrainingStatus.completed),
            _memberTile("Jana", TrainingStatus.dueToday),
            _memberTile("Tom", TrainingStatus.upcoming),
            _memberTile(
              "Du",
              _workedOutToday
                  ? TrainingStatus.completed
                  : TrainingStatus.dueToday,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(
            _workedOutToday
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            color: _workedOutToday ? Colors.green : Colors.amber,
          ),
          const SizedBox(width: 12),
          Text(
            _workedOutToday
                ? "Workout erledigt"
                : "Heute Training – noch kein Foto",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _proofCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A00E0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
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
              setState(() {
                _workedOutToday = true;
              });
            }
          },
          child: const Text(
            "Beweisfoto posten",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _memberTile(String name, TrainingStatus status) {
    String description;
    IconData icon;
    Color color;

    switch (status) {
      case TrainingStatus.completed:
        description = "Hat heute trainiert";
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case TrainingStatus.dueToday:
        description = "Heute Training – noch kein Foto";
        icon = Icons.schedule_rounded;
        color = Colors.amber;
        break;
      case TrainingStatus.upcoming:
        description = "Nächstes Training in 2 Tagen";
        icon = Icons.calendar_today_rounded;
        color = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage("assets/profile.jpg"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            icon,
            color: color,
          ),
        ],
      ),
    );
  }

  // ================= PROFILE =================

  Widget _buildProfile() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Profil",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
                SizedBox(width: 20),
                Text(
                  "Dein Name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1C1C22),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF2A2A32)),
    );
  }
}