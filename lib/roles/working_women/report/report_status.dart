import 'package:flutter/material.dart';

class ReportStatusScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const ReportStatusScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reportData['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Description:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(reportData['description']),
            const SizedBox(height: 10),
            const Text(
              "Accused Person Details:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(reportData['accused_details']),
            const SizedBox(height: 10),
            Text(
              "Status: ${reportData['status']}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
