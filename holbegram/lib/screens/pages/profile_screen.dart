import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> userSnap) {
            if (!userSnap.hasData || !userSnap.data!.exists || userSnap.data!.data() == null) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Profile', style: TextStyle(fontFamily: 'Billabong', fontSize: 36)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                  const Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            var user = userSnap.data!.data() as Map<String, dynamic>;

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid', isEqualTo: currentUid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> postSnap) {
                int postCount = 0;
                List<QueryDocumentSnapshot> posts = [];
                if (postSnap.hasData) {
                  posts = postSnap.data!.docs;
                  postCount = posts.length;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontFamily: 'Billabong',
                              fontSize: 36,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.exit_to_app),
                            onPressed: _logout,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: (user['photoUrl'] != null &&
                                    user['photoUrl'].isNotEmpty)
                                ? NetworkImage(user['photoUrl'])
                                : null,
                            child: (user['photoUrl'] == null ||
                                    user['photoUrl'].isEmpty)
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _statColumn(postCount.toString(), 'posts'),
                                _statColumn(
                                  (user['followers'] as List).length.toString(),
                                  'followers',
                                ),
                                _statColumn(
                                  (user['following'] as List).length.toString(),
                                  'following',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        user['username'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          var post = posts[index].data() as Map<String, dynamic>;
                          final url = post['postUrl'] ?? '';
                          if (url.isEmpty) return const SizedBox();
                          return Image.network(url, fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _statColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
