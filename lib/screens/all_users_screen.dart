import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';

class AllUsersScreen extends StatelessWidget {
  const AllUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser =
        FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading users"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!.docs;

print("========== USERS ==========");
for (var doc in users) {
  print(doc.data());
}
print("===========================");

          print("Users Count: ${users.length}");

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              try {
                final data = users[index].data()
                    as Map<String, dynamic>;

                final email =
                    (data['email'] ?? '').toString();

                print("Email: $email");

                if (email.isEmpty) {
                  return const SizedBox();
                }

                print("Current User: $currentUser");
                print("User Email: $email");

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        email[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chat,
                      color: Colors.green,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            receiverEmail: email,
                          ),
                        ),
                      );
                    },
                  ),
                );
              } catch (e) {
                print("Error: $e");
                return const SizedBox();
              }
            },
          );
        },
      ),
    );
  }
}