import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_report_details.dart';

class AdminReportsList extends StatelessWidget {
  final String adminOrgId;

  const AdminReportsList({super.key, required this.adminOrgId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports List"),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('organization')
            .doc(adminOrgId)
            .collection('reports')
            .where("status", isNotEqualTo: "Resolved")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No reports available."));
          }

          var reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              var reportData = reports[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(reportData['title']),
                  subtitle: Text("Status: ${reportData['status_message']}"),
                  trailing: reportData['status'] == "Pending"
                      ? const Icon(Icons.warning, color: Colors.red)
                      : const Icon(Icons.autorenew, color: Colors.green),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminReportDetails(
                          reportId: reports[index].id,
                          adminOrgId: adminOrgId,
                        ),
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
