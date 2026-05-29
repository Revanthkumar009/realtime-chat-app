import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../notification_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverEmail;

  const ChatScreen({
    super.key,
    required this.receiverEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  String get currentUser =>
      FirebaseAuth.instance.currentUser!.email!;

  String get chatRoomId {
    List<String> users = [
      currentUser,
      widget.receiverEmail,
    ];

    users.sort();

    return users.join("_");
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }

await FirebaseFirestore.instance
    .collection('chat_rooms')
    .doc(chatRoomId)
    .set({
  'lastMessage': messageController.text.trim(),
  'lastMessageTime': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': messageController.text.trim(),
      'sender': currentUser,
      'receiver': widget.receiverEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });

await FirebaseFirestore.instance
    .collection('chat_rooms')
    .doc(chatRoomId)
    .set({
  'lastMessage': messageController.text.trim(),
  'lastMessageTime': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));

    messageController.clear();

    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final messages =
                    snapshot.data!.docs;

if (messages.isNotEmpty) {
  final lastMessage = messages.last;

  if (lastMessage['sender'] != currentUser) {
    NotificationService.showNotification(
      lastMessage['sender'],
      lastMessage['text'],
    );
  }
}
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  if (scrollController
                      .hasClients) {
                    scrollController.animateTo(
                      scrollController
                          .position
                          .maxScrollExtent,
                      duration:
                          const Duration(
                        milliseconds: 300,
                      ),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  reverse: false,
                  controller:
                      scrollController,
                  padding:
                      const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder:
                      (context, index) {
                    final message =
                        messages[index];

                    final text =
                        message['text'];

                    final sender =
                        message['sender'];

                    bool isMe =
                        sender ==
                            currentUser;

                   Timestamp? timestamp;

            try {
                       timestamp =
                     message['timestamp'] as Timestamp?;
                         } catch (e) {
                  timestamp = null;
                 }
                    String time = '';

                    if (timestamp !=
                        null) {
                      time = DateFormat(
                        'hh:mm a',
                      ).format(
                        timestamp
                            .toDate(),
                      );
                    }

                    return Align(
                      alignment: isMe
                          ? Alignment
                              .centerRight
                          : Alignment
                              .centerLeft,
                      child: Container(
                        margin:
                            const EdgeInsets
                                .symmetric(
                          vertical: 5,
                        ),
                        padding:
                            const EdgeInsets
                                .all(12),
                        constraints:
                             BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width*0.7,
                        ),
                        decoration:
                            BoxDecoration(
                          color: isMe
                              ? Colors.blue
                              : Colors
                                  .grey
                                  .shade300,
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMe
                                  ? CrossAxisAlignment
                                      .end
                                  : CrossAxisAlignment
                                      .start,
                          children: [
                            Text(
                              text,
                              style:
                                  TextStyle(
                                color: isMe
                                    ? Colors
                                        .white
                                    : Colors
                                        .black,
                                fontSize:
                                    18,
                                    fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              time,
                              style:
                                  TextStyle(
                                fontSize:
                                    10,
                                color: isMe
                                    ? Colors
                                        .white70
                                    : Colors
                                        .black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding:
                const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        messageController,
                    decoration:
                        InputDecoration(
                      hintText:
                          "Type a message",
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),
                      ),
                    ),
                    onSubmitted:
                        (_) =>
                            sendMessage(),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                CircleAvatar(
                  child: IconButton(
                    onPressed:
                        sendMessage,
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}