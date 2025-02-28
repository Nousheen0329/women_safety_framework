import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_report_status.dart';

class AdminReportDetails extends StatelessWidget {
  final String reportId;
  final String adminOrgId;

  const AdminReportDetails({
    super.key,
    required this.reportId,
    required this.adminOrgId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('organization')
            .doc(adminOrgId)
            .collection('reports')
            .doc(reportId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Report not found."));
          }

          var reportData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Working Women Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow("Name:", reportData['name']),
                _buildDetailRow("Phone No:", reportData['phone_number']),
                _buildDetailRow("Email:", reportData['email']),
                _buildDetailRow("Employee ID:", reportData['employee_id']),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "Report Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow("Title:", reportData['title']),
                _buildDetailRow("Description:", reportData['description']),
                _buildDetailRow(
                    "Accused Details:", reportData['accused_details']),
                _buildDetailRow(
                    "Priority Level:", reportData['priority_level']),
                _buildDetailRow("Status:", reportData['status'],
                    color: Colors.red),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateReportStatus(
                            reportId: reportId,
                            adminOrgId: adminOrgId,
                          ),
                        ),
                      );
                    },
                    child: const Text("Update Status"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value,
      {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: " ${value ?? 'Not Available'}",
              style: TextStyle(fontWeight: FontWeight.normal, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
