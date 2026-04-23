import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/pages/methods/post_storage.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
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
                                  image: DecorationImage(
                                    image: NetworkImage(doc['profImage'] ?? ''),
                                    fit: BoxFit.cover,
                                  ),
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
                          image: DecorationImage(
                            image: NetworkImage(doc['postUrl'] ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                onPressed: () {},
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
                            icon: const Icon(Icons.bookmark_border),
                            onPressed: () {},
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
  }
}
