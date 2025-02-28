import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateReportStatus extends StatefulWidget {
  final String reportId;
  final String adminOrgId;

  const UpdateReportStatus({
    super.key,
    required this.reportId,
    required this.adminOrgId,
  });

  @override
  _UpdateReportStatusState createState() => _UpdateReportStatusState();
}

class _UpdateReportStatusState extends State<UpdateReportStatus> {
  final TextEditingController _statusController = TextEditingController();
  bool _isLoading = false;

  void _updateStatus(String newStatus) async {
    if (newStatus.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('organization')
        .doc(widget.adminOrgId)
        .collection('reports')
        .doc(widget.reportId)
        .update({"status": newStatus});

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Report Status"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _statusController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Enter Status",
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _updateStatus(_statusController.text),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.purple,
                      ),
                      child: const Text(
                        "Update Status",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _updateStatus("Resolved"),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text("Mark as Resolved"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
