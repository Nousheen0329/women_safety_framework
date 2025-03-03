import 'package:flutter/material.dart';

class ReportStatusScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const ReportStatusScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    Color statusMessageColor =
        (reportData['status'] == "Resolved") ? Colors.green : Colors.red;

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
            const Text(
              "Status:",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              reportData['status'],
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusMessageColor,
                ),
                children: [
                  const TextSpan(text: "Status Message: "),
                  TextSpan(
                    text:
                        reportData['status_message'] ?? "No message available",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
