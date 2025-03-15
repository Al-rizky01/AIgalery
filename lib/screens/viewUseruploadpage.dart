import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserUploadsPage extends StatelessWidget {
  final String userId;

  const UserUploadsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Uploads'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('upload')
            .where('userIdUploadters', isEqualTo: userId) // Filter berdasarkan userId pengguna yang login
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No uploads found.'));
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Grid dengan 2 kolom
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 3 / 4, // Atur rasio kotak grid
            ),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;
              final String imageUrl = data['url'] ?? '';
              final String title = data['title'] ?? 'No Title';

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: GridTile(
                    footer: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          )
                        : const Center(child: Text('No image')),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
