import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupName;
  final String groupId;

  const GroupDetailScreen({
    super.key,
    required this.groupName,
    required this.groupId,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  String? ownerId;
  @override
void initState() {
  super.initState();
  _loadOwner();
}
void _showInviteDialog() {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1C1C22),

        title: const Text(
          "Invite Member",
          style: TextStyle(color: Colors.white),
        ),

        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Username",
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
              final username =
                  controller.text.trim();

              final result =
                  await FirebaseFirestore.instance
                      .collection("users")
                      .where(
                        "username",
                        isEqualTo: username,
                      )
                      .get();

              if (result.docs.isEmpty) {
                return;
              }

              final userId =
                  result.docs.first.id;

              final existingMember =
    await FirebaseFirestore.instance
        .collection("group_members")
        .where("groupId",
            isEqualTo: widget.groupId)
        .where("userId",
            isEqualTo: userId)
        .get();

if (existingMember.docs.isNotEmpty) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content: Text(
        "User is already in the group",
      ),
    ),
  );

  return;
}

await FirebaseFirestore.instance
    .collection("group_members")
    .add({
  "groupId": widget.groupId,
  "userId": userId,
  "joinedAt": Timestamp.now(),
});

if (!context.mounted) return;

Navigator.pop(context);

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      "Member invited successfully",
    ),
  ),
);

              if (!context.mounted) return;

              Navigator.pop(context);
            },
            child: const Text("Invite"),
          ),
        ],
      );
    },
  );
}
Future<void> _loadOwner() async {
  final groupDoc = await FirebaseFirestore.instance
      .collection("groups")
      .doc(widget.groupId)
      .get();

  if (!groupDoc.exists) return;

  final data =
      groupDoc.data() as Map<String, dynamic>;

  setState(() {
    ownerId = data["createdBy"];
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111114),

      appBar: AppBar(
  backgroundColor: const Color(0xFF111114),
  title: Text(widget.groupName),

  actions: [
  IconButton(
    icon: const Icon(Icons.person_add),
    onPressed: () {
      _showInviteDialog();
    },
  ),
],
),

      body: Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        widget.groupName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 30),

      const Text(
        "Members",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      const SizedBox(height: 15),

      Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("group_members")
        .where("groupId", isEqualTo: widget.groupId)
        .snapshots(),
    builder: (context, snapshot) {

      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final members = snapshot.data!.docs;

      if (members.isEmpty) {
        return const Center(
          child: Text(
            "No members",
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {

          final member =
              members[index].data()
                  as Map<String, dynamic>;

          return Card(
            color: const Color(0xFF1C1C22),
            child: ListTile(
              leading: Icon(
  member["userId"] == ownerId
      ? Icons.workspace_premium
      : Icons.person,
  color: member["userId"] == ownerId
      ? Colors.amber
      : Colors.white,
),
              title: FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection("users")
      .doc(member["userId"])
      .get(),
  builder: (context, userSnapshot) {

    if (!userSnapshot.hasData ||
        userSnapshot.data!.data() == null) {
      return const Text(
        "Loading...",
        style: TextStyle(color: Colors.white),
      );
    }

    final userData =
        userSnapshot.data!.data()
            as Map<String, dynamic>;

    return Text(
      userData["username"] ?? "Unknown",
      style: const TextStyle(
        color: Colors.white,
      ),
    );
  },
),
            ),
          );
        },
      );
    },
  ),
),
    ],
  ),
),
    );
  }
}