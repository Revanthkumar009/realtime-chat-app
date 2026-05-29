import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'all_users_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),

        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),

    floatingActionButton: FloatingActionButton(
  backgroundColor: Colors.blue,
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AllUsersScreen(),
      ),
    );
  },
  child: const Icon(
    Icons.person_add,
    color: Colors.white,
  ),
),

floatingActionButtonLocation:
    FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: Colors.blue.shade50,
            child: Text(
              "Logged in as\n$currentUser",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .orderBy(
                    'lastMessageTime',
                    descending: true,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error loading chats"),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final chatRooms = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final room =
                        chatRooms[index].data()
                            as Map<String, dynamic>;

                    final roomId =
                        chatRooms[index].id;

                    List<String> users =
                        roomId.split("_");

                    if (!users.contains(currentUser)) {
                      return const SizedBox();
                    }

                    String otherUser =
                        users.firstWhere(
                      (user) =>
                          user != currentUser,
                      orElse: () => '',
                    );

                    if (otherUser.isEmpty) {
                      return const SizedBox();
                    }

                    String lastMessage =
                        room['lastMessage'] ?? '';

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            otherUser[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          otherUser,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(
                          Icons.chat,
                          color: Colors.green,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatScreen(
                                receiverEmail:
                                    otherUser,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}