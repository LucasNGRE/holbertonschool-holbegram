import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String postId;
  final String uid;
  final String username;
  final String description;
  final String postUrl;
  final String profImage;
  final dynamic likes;

  const Posts({
    required this.postId,
    required this.uid,
    required this.username,
    required this.description,
    required this.postUrl,
    required this.profImage,
    required this.likes,
  });

  static Posts fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Posts(
      postId: snapshot['postId'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      description: snapshot['description'],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
      likes: snapshot['likes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'uid': uid,
        'username': username,
        'description': description,
        'postUrl': postUrl,
        'profImage': profImage,
        'likes': likes,
      };
}
