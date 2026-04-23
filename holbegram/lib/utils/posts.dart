import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/pages/methods/post_storage.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _toggleSave(String postId, List savedList) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid);
    if (savedList.contains(postId)) {
      await userRef.update({
        'saved': FieldValue.arrayRemove([postId]),
      });
    } else {
      await userRef.update({
        'saved': FieldValue.arrayUnion([postId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnap) {
        List savedList = [];
        if (userSnap.hasData && userSnap.data!.exists) {
          savedList = (userSnap.data!.data() as Map<String, dynamic>)['saved'] ?? [];
        }
        return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').orderBy('datePublished', descending: true).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error ${snapshot.error}'));
            }
            if (snapshot.hasData) {
              var data = snapshot.data!.docs;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  var doc = data[index].data() as Map<String, dynamic>;
                  bool isSaved = savedList.contains(doc['postId']);
                  return SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsetsGeometry.lerp(
                        const EdgeInsets.all(8),
                        const EdgeInsets.all(8),
                        10,
                      ),
                      height: 540,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: (doc['profImage'] != null && doc['profImage'].isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(doc['profImage']),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    ),
                                  ),
                                ),
                                Text(doc['username'] ?? ''),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.more_horiz),
                                  onPressed: () async {
                                    await PostStorage().deletePost(
                                      doc['postId'] ?? '',
                                      doc['postId'] ?? '',
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Post Deleted')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            child: Text(doc['caption'] ?? ''),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 350,
                            height: 350,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.grey[200],
                              image: (doc['postUrl'] != null && doc['postUrl'].isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(doc['postUrl']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      (doc['likes'] as List).contains(currentUid)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: (doc['likes'] as List).contains(currentUid)
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                    onPressed: () async {
                                      final postRef = FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(doc['postId']);
                                      if ((doc['likes'] as List).contains(currentUid)) {
                                        await postRef.update({
                                          'likes': FieldValue.arrayRemove([currentUid]),
                                        });
                                      } else {
                                        await postRef.update({
                                          'likes': FieldValue.arrayUnion([currentUid]),
                                        });
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                                  color: isSaved ? Colors.red : Colors.black,
                                ),
                                onPressed: () => _toggleSave(doc['postId'] ?? '', savedList),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
