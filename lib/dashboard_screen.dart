import 'dart:io';
import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'group_detail_screen.dart';

enum TrainingStatus {
  completed,
  dueToday,
  upcoming,
}

class Member {
  final String name;
  final String image;
  final int streak;

  Member({
    required this.name,
    required this.image,
    required this.streak,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _workedOutToday = false;
  bool _streakLost = false;

  String? _lastWorkoutImagePath;
  DateTime? _lastWorkoutDate;
  String? _profileImagePath;
  String? _selectedGroupId;
  String? _selectedGroupName;

  List<int> _workoutDays = [];

  int _currentStreak = 0;
  int _bestStreak = 0;

  final List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _createUserDocumentIfNeeded();
    _loadAll();
  }
  
Future<void> _createUserDocumentIfNeeded() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .get();

  if (!doc.exists) {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "email": user.email,
      "username": user.email,
      "createdAt": Timestamp.now(),
    });
  }
}

Future<void> _checkMissedWorkoutDays() async {
  if (_lastWorkoutDate == null) return;

  final now = DateTime.now();
  final prefs = await SharedPreferences.getInstance();

  final difference = now.difference(_lastWorkoutDate!).inDays;

  if (difference > 1) {
    _currentStreak = 0;
    _streakLost = true;

    await prefs.setInt('currentStreak', 0);
  }
}

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    _workedOutToday = prefs.getBool('workedOutToday') ?? false;

    _profileImagePath = prefs.getString('profileImage');

    _selectedGroupId =
    prefs.getString('selectedGroupId');

_selectedGroupName =
    prefs.getString('selectedGroupName');

    _currentStreak = prefs.getInt('currentStreak') ?? 0;

    _bestStreak = prefs.getInt('bestStreak') ?? 0;

    final lastDateString = prefs.getString('lastWorkoutDate');

    if (lastDateString != null) {
      _lastWorkoutDate = DateTime.parse(lastDateString);
    }

    final savedDays = prefs.getStringList('workoutDays');

    if (savedDays != null) {
      _workoutDays = savedDays.map((e) => int.parse(e)).toList();
    }

await _checkMissedWorkoutDays();

Future<void> _checkWorkoutStatus() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .get();

  if (!doc.exists) return;

  final data =
      doc.data() as Map<String, dynamic>;

  if (data["lastWorkoutDate"] == null) return;

  final lastWorkout =
      (data["lastWorkoutDate"] as Timestamp)
          .toDate();

  final now = DateTime.now();

  final sameDay =
      lastWorkout.year == now.year &&
      lastWorkout.month == now.month &&
      lastWorkout.day == now.day;

  if (!sameDay) {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({
      "workedOutToday": false,
    });
  }
}

await _checkWorkoutStatus();
    setState(() {});
  }

  Future<void> _saveWorkoutDays() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'workoutDays',
      _workoutDays.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', pickedFile.path);

      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHome(),
      _buildGroup(),
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
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_rounded), label: "Gruppe"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  // ================= HOME =================

Widget _buildGroup() {
  return Scaffold(
    backgroundColor: const Color(0xFF111114),

    floatingActionButton: FloatingActionButton(
  backgroundColor: const Color(0xFF4A00E0),
  child: const Icon(Icons.add),
  onPressed: () {
    _showCreateGroupDialog();
  },
),

    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Groups",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Your Groups",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
  child: FutureBuilder<QuerySnapshot>(
    future: FirebaseFirestore.instance
        .collection("group_members")
        .where(
          "userId",
          isEqualTo:
              FirebaseAuth.instance.currentUser!.uid,
        )
        .get(),
    builder: (context, memberSnapshot) {

      if (!memberSnapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final memberships =
          memberSnapshot.data!.docs;

      if (memberships.isEmpty) {
        return const Center(
          child: Text(
            "No groups yet",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        );
      }

      final groupIds = memberships
          .map(
            (e) =>
                (e.data() as Map<String, dynamic>)
                    ["groupId"] as String,
          )
          .toList();

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("groups")
            .where(
              FieldPath.documentId,
              whereIn: groupIds,
            )
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final groups =
              snapshot.data!.docs;

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {

              final group =
                  groups[index].data()
                      as Map<String, dynamic>;

              return GestureDetector(
                onTap: () async {
  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setString(
    "selectedGroupId",
    groups[index].id,
  );

  await prefs.setString(
    "selectedGroupName",
    group["name"],
  );

  setState(() {
    _selectedGroupId = groups[index].id;
    _selectedGroupName = group["name"];
  });

  if (!context.mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => GroupDetailScreen(
        groupId: groups[index].id,
        groupName: group["name"],
      ),
    ),
  );
},

                child: Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  padding:
                      const EdgeInsets.all(16),
                  decoration:
                      _cardDecoration(),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.group,
                        color: Colors.white,
                      ),

                      const SizedBox(
                        width: 15,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              group["name"] ??
                                  "No Name",
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  ),
),
            const SizedBox(height: 20),

            const Center(
              child: Text(
                "Don't finish last today.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
void _showCreateGroupDialog() {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1C1C22),

        title: const Text(
          "Create Group",
          style: TextStyle(color: Colors.white),
        ),

        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Group Name",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {
              final groupRef =
    await FirebaseFirestore.instance
        .collection("groups")
        .add({
  "name": controller.text.trim(),
  "createdBy":
      FirebaseAuth.instance.currentUser!.uid,
  "createdAt": Timestamp.now(),
});

await FirebaseFirestore.instance
    .collection("group_members")
    .add({
  "groupId": groupRef.id,
  "userId":
      FirebaseAuth.instance.currentUser!.uid,
  "joinedAt": Timestamp.now(),
});

              if (!context.mounted) return;

              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      );
    },
  );
}
  Widget _buildHome() {
    List<Member> members = [];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
  _selectedGroupName ?? "No Group Selected",
  style: const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  "$_currentStreak day streak",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _statusCard(),
            const SizedBox(height: 25),
            _proofCard(),
            const SizedBox(height: 30),
            const Text(
              "Gym Group",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            if (_selectedGroupId != null)
  SizedBox(
    height: 150,
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("group_members")
          .where(
            "groupId",
            isEqualTo: _selectedGroupId,
          )
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final members = snapshot.data!.docs;

members.sort((a, b) {
  final aData =
      a.data() as Map<String, dynamic>;

  final bData =
      b.data() as Map<String, dynamic>;

  return 0;
});

        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {

            final member =
                members[index].data()
                    as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(member["userId"])
                  .get(),
              builder: (context, userSnapshot) {

                if (!userSnapshot.hasData ||
                    userSnapshot.data!.data() == null) {
                  return const SizedBox();
                }

                final userData =
                    userSnapshot.data!.data()
                        as Map<String, dynamic>;

                final status =
    userData["workedOutToday"] == true
        ? TrainingStatus.completed
        : TrainingStatus.dueToday;

return _memberTile(
  userData["username"] ?? "Unknown",
  status,
  userData["streak"] ?? 0,
  0,
  "assets/profile.jpg",
);
              },
            );
          },
        );
      },
    ),
  ),
const SizedBox(height: 30),

const SizedBox(height: 30),

const Text(
  "Still no proof",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  ),
),

const SizedBox(height: 15),

if (_selectedGroupId != null)
  StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("group_members")
        .where(
          "groupId",
          isEqualTo: _selectedGroupId,
        )
        .snapshots(),
    builder: (context, snapshot) {

      if (!snapshot.hasData) {
        return const SizedBox();
      }

      final members = snapshot.data!.docs;

      return Column(
        children: members.map((memberDoc) {

          final member =
              memberDoc.data()
                  as Map<String, dynamic>;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(member["userId"])
                .get(),
            builder: (context, userSnapshot) {

              if (!userSnapshot.hasData ||
                  userSnapshot.data!.data() == null) {
                return const SizedBox();
              }

              final userData =
                  userSnapshot.data!.data()
                      as Map<String, dynamic>;

              if (userData["workedOutToday"] == true) {
  return const SizedBox();
}

              return Card(
                color: const Color(0xFF1C1C22),
                child: ListTile(
                  leading: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  title: Text(
                    userData["username"] ?? "Unknown",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      );
    },
  ),
            const SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: () => _openComments(context),
                child: const Text(
                  "Open comments",
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
                ? "Workout completed"
                : "Workout due today –",
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
          ),
          onPressed: () async {
            final imagePath = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CameraScreen(),
              ),
            );

            if (imagePath != null) {
              final now = DateTime.now();
              final prefs = await SharedPreferences.getInstance();
              final file = File(imagePath);

final storageRef = FirebaseStorage.instance
    .ref()
    .child(
      "proofs/${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

await storageRef.putFile(file);

final imageUrl =
    await storageRef.getDownloadURL();

              if (_lastWorkoutDate != null) {
                final difference = now.difference(_lastWorkoutDate!).inDays;

                if (difference == 1) {
                  _currentStreak++;
                } else if (difference > 1) {
                  _currentStreak = 1;
                }
              } else {
                _currentStreak = 1;
              }

              if (_currentStreak > _bestStreak) {
                _bestStreak = _currentStreak;
              }

              await prefs.setInt('currentStreak', _currentStreak);
              await prefs.setInt('bestStreak', _bestStreak);

             await FirebaseFirestore.instance
    .collection("users")
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .update({
  "streak": _currentStreak,
  "bestStreak": _bestStreak,
  "workedOutToday": true,
  "lastWorkoutDate": Timestamp.now(),
});

final selectedGroupId =
    prefs.getString("selectedGroupId");

if (selectedGroupId != null) {
  await FirebaseFirestore.instance
      .collection("group_posts")
      .add({
    "groupId": selectedGroupId,
    "userId":
        FirebaseAuth.instance.currentUser!.uid,
    "imageUrl": imageUrl,
    "createdAt": Timestamp.now(),
  });
}

              await prefs.setString('lastWorkoutDate', now.toIso8601String());
              await prefs.setBool('workedOutToday', true);

              setState(() {
                _workedOutToday = true;
                _lastWorkoutImagePath = imagePath;
                _lastWorkoutDate = now;
              });
              ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text("🔥 +1 Day"),
    duration: Duration(seconds: 2),
  ),
);
            }
          },
          child: const Text(
            "Post proof",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _memberTile(
    String name,
    TrainingStatus status,
    int streak,
    int rank,
    String image,
  ) {
    String description;
    IconData icon;
    Color color;

    switch (status) {
      case TrainingStatus.completed:
        description = "Worked out today";
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;

      case TrainingStatus.dueToday:
        description = "Workout due today –";
        icon = Icons.schedule_rounded;
        color = Colors.amber;
        break;

      case TrainingStatus.upcoming:
        description = "Next workout on Friday";
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
          if (rank > 0)
  Text(
    "#$rank",
    style: const TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
    ),
  ),

          CircleAvatar(
            radius: 22,
            backgroundImage: name == "Du"
    ? (_profileImagePath != null
        ? FileImage(File(_profileImagePath!))
        : const AssetImage("assets/profile.jpg")
            as ImageProvider)
    : AssetImage(image),
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

          // 🔥 Status Icon + Streak
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "$streak",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= PROFILE =================

  Widget _buildProfile() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profil",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : const AssetImage("assets/profile.jpg")
                            as ImageProvider,
                  ),
                  const SizedBox(width: 20),
                  FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get(),
  builder: (context, snapshot) {
    if (!snapshot.hasData ||
    snapshot.data!.data() == null) {
  return const Text(
    "No Username",
    style: TextStyle(color: Colors.white),
  );
}

final data =
    snapshot.data!.data()
        as Map<String, dynamic>;
    return Text(
      data["username"] ?? "No Name",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  },
),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _sectionTitle("Account"),
            _profileTile(Icons.image_outlined, "Change profile picture",
                onTap: _pickProfileImage),
            const SizedBox(height: 30),
            _sectionTitle("Workout"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isSelected = _workoutDays.contains(day);

                return FilterChip(
                  label:
                      Text(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _workoutDays.add(day);
                      } else {
                        _workoutDays.remove(day);
                      }
                    });
                    _saveWorkoutDays();
                  },
                );
              }),
            ),
            const SizedBox(height: 30),

_profileTile(
  Icons.logout_rounded,
  "Logout",
  onTap: () async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  },
),
          ],
          
        ),
      ),
    );
    
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String text, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(text, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // ================= COMMENTS =================

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C22),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Comments",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
  child: _comments.isEmpty
      ? const Center(
          child: Text(
            "No comments so far. Be the first to comment!",
            style: TextStyle(color: Colors.grey),
          ),
        )
      : ListView.builder(
          itemCount: _comments.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Text(
                _comments[index],
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Type your comment...",
                          hintStyle:
                              const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor:
                              const Color(0xFF111114),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF4A00E0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        final text =
                            _commentController.text.trim();
                        if (text.isNotEmpty) {
                          setState(() {
                            _comments.add(text);
                            _commentController.clear();
                          });
                        }
                      },
                      child: const Text("Send"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
