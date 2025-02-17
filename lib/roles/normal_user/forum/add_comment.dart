import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:women_safety_framework/utils/color_utils.dart';

class ForumPostScreen extends StatefulWidget {
  final String postId;
  final String content;

  const ForumPostScreen(
      {super.key, required this.postId, required this.content});

  @override
  _ForumPostScreenState createState() => _ForumPostScreenState();
}

class _ForumPostScreenState extends State<ForumPostScreen> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment() async {
    String comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('forum_posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'anonymousName': "Anonymous User",
      'content': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Post Details",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: hexStringToColor("9546C4")),
      body: Column(
        children: [
          // Post content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Anonymous User",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(widget.content),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Comments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('forum_posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No comments yet."));
                }

                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> comment =
                        doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Anonymous User"),
                      subtitle: Text(comment['content']),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // Comment input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: Color.fromRGBO(149, 70, 176, 1)),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
