import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    getUserInfo();
    return Scaffold(appBar: AppBar(
        title: Text('Profil'),
    ),
    body: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage('https://picsum.photos/seed/${FirebaseAuth.instance.currentUser!.uid}/100/100'),
          ),
          Padding(
              padding: const EdgeInsets.all(16),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
          ),
          ),
          Padding(
              padding: const EdgeInsets.all(16),
          child: TextField(
            controller: bioController,
            decoration: InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
          ),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateUserInfo(context);
            },
            child: Text('Modifier'),
          ),
          Spacer(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
          Spacer()
        ]
    ),
    );
  }

  // Voir la base de données
  Future<void> getData() async {
    CollectionReference collection = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await collection.get();
    var data = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(data);

    collection = FirebaseFirestore.instance.collection('messages');
    querySnapshot = await collection.get();
    data = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(data);
  }

  // Infos de l'utilisateur
  Future<void> getUserInfo() async {
    var db = FirebaseFirestore.instance;
    CollectionReference collection = db.collection('users');
    QuerySnapshot querySnapshot = await collection.where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    var dataList = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(dataList);

    if (dataList.isNotEmpty && dataList[0] is Map<String, dynamic>) {
      Map<String, dynamic> data = dataList[0] as Map<String, dynamic>;
      nameController.text = data['displayName'] ?? '';
      bioController.text = data['bio'] ?? '';
    }
  }

  // Update
  Future<void> updateUserInfo(context) async {
    var db = FirebaseFirestore.instance;
    CollectionReference collection = db.collection('users');
    QuerySnapshot querySnapshot = await collection.where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;

      await collection.doc(documentId).update({
        'displayName': nameController.text,
        'bio': bioController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil modifié'))
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue'))
      );
    }
  }
}
