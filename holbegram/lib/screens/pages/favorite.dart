import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Favorites',
                style: TextStyle(
                  fontFamily: 'Billabong',
                  fontSize: 36,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> userSnap) {
                  if (!userSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  List savedIds = (userSnap.data!.data()
                      as Map<String, dynamic>)['saved'] ?? [];

                  if (savedIds.isEmpty) {
                    return const Center(child: Text('No saved posts yet.'));
                  }

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('postId', whereIn: savedIds)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> postSnap) {
                      if (!postSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var posts = postSnap.data!.docs;
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          var doc = posts[index].data() as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                doc['postUrl'] ?? '',
                                fit: BoxFit.cover,
                                width: double.infinity,
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
          ],
        ),
      ),
    );
  }
}
