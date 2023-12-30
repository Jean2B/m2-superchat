import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superchat/constants.dart';
import 'package:superchat/pages/profile_page.dart';
import 'package:superchat/pages/sign_in_page.dart';
import 'package:superchat/widgets/stream_listener.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? selectedUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamListener<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      listener: (user) {
        if (user == null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignInPage()),
                  (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(kAppTitle),
          backgroundColor: theme.colorScheme.primary,
          actions: [
            IconButton(
              icon: Image.network('https://picsum.photos/seed/${FirebaseAuth.instance.currentUser!.uid}/100/100'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
        body: Row(
          children: [
            // Liste des utilisateurs à gauche
            Expanded(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var users = snapshot.data!.docs.where((user) {
                    final userData = user.data() as Map<String, dynamic>;
                    final userID = userData['id'];
                    final displayName = userData['displayName'];
                    return userID != null && displayName != null;
                  }).toList();

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage('https://picsum.photos/seed/${user['id']}/100/100'),
                        ),
                        title: Text(user['displayName']),
                        onTap: () {
                          setState(() {
                            selectedUserId = user['id'];
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Messages à droite
            Expanded(
              flex: 2,
              child: MessagesPage(userId: selectedUserId ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesPage extends StatefulWidget {
  final String userId;

  const MessagesPage({required this.userId});

  @override
  MessagesPageState createState() => MessagesPageState();
}

class MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Column(
          children: [
      Expanded(
      child: FutureBuilder<List<DocumentSnapshot>>(
          future: getMessages(),
      builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Pas de message'));
          }

          // Affichage des messages envoyés et reçus
          return ListView.builder(
            itemCount: snapshot.data!.length,
            reverse: true,
            itemBuilder: (context, index) {
              DocumentSnapshot message = snapshot.data![index];
              bool msgFrom = message['from'] == FirebaseAuth.instance.currentUser!.uid;

              Color bubbleColor = msgFrom ? Colors.blue[200]! : Colors.grey[300]!;
              CrossAxisAlignment alignment = msgFrom ? CrossAxisAlignment.end : CrossAxisAlignment.start;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: msgFrom ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: alignment,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(msgFrom ? 18.0 : 0.0),
                                topRight: Radius.circular(msgFrom ? 0.0 : 18.0),
                                bottomLeft: Radius.circular(18.0),
                                bottomRight: Radius.circular(18.0),
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                message['content'],
                                style: TextStyle(color: msgFrom ? Colors.white : Colors.black),
                              ),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy HH:mm').format(
                                  message['timestamp'].toDate()
                                ).toString(),
                                style: TextStyle(color: msgFrom ? Colors.white70 : Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
      },
      ),
      ),
            // Envoi de message
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrivez votre message...',
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () => sendMessage(),
                    child: Text('Envoyer'),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }

  // Ajout de message
  Future<void> sendMessage() async {
    String messageContent = _messageController.text.trim();
    if (messageContent.isNotEmpty) {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      String userId = widget.userId;

      await FirebaseFirestore.instance.collection('messages').add({
        'content': messageContent,
        'from': currentUserId,
        'to': userId,
        'timestamp': Timestamp.now(),
      });

      _messageController.clear();

      // Rafraîchir les messages
      setState(() {});
    }
  }


  // Obtention des messages
  Future<List<DocumentSnapshot>> getMessages() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Requête des messages reçus
    QuerySnapshot msgenvoi = await FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: widget.userId)
        .where('to', isEqualTo: currentUserId)
        .get();

    // Requête des messages envoyés
    QuerySnapshot msgrecus = await FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: currentUserId)
        .where('to', isEqualTo: widget.userId)
        .get();

    List<DocumentSnapshot> messages = [];
    messages.addAll(msgenvoi.docs);
    messages.addAll(msgrecus.docs);

    // Tri par date
    messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return messages;
  }
}