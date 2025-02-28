import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'working_woman_details.dart';

class WorkingWomenList extends StatefulWidget {
  final String organizationId;

  const WorkingWomenList({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _WorkingWomenListState createState() => _WorkingWomenListState();
}

class _WorkingWomenListState extends State<WorkingWomenList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Working Women"),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('working_women')
            .where('organization_id', isEqualTo: widget.organizationId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No working women found."));
          }

          var workingWomen = snapshot.data!.docs;

          return ListView.builder(
            itemCount: workingWomen.length,
            itemBuilder: (context, index) {
              var woman = workingWomen[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purpleAccent,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(woman['name'] ?? 'Unknown'),
                  subtitle: Text(woman['email'] ?? 'No email'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkingWomanDetails(womanId: woman.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
