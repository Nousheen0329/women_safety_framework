import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_status.dart';

class ReportList extends StatelessWidget {
  final String userId;

  const ReportList({super.key, required this.userId});

  Future<String?> getOrganizationId() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('working_women')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc['organization_id'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Status"),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<String?>(
        future: getOrganizationId(),
        builder: (context, orgSnapshot) {
          if (orgSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!orgSnapshot.hasData || orgSnapshot.data == null) {
            return const Center(child: Text("Organization not found."));
          }

          String organizationId = orgSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('organization')
                .doc(organizationId)
                .collection('reports')
                .where("user_id", isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No reports found."));
              }

              var reports = snapshot.data!.docs;

              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  var reportData =
                      reports[index].data() as Map<String, dynamic>;
                  bool isResolved = reportData['status'] == "Resolved";

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(reportData['title']),
                      subtitle: Text("Status: ${reportData['status_message']}"),
                      trailing: isResolved
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportStatusScreen(
                              reportData: reportData,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
