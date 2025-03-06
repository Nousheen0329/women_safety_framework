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
  final TextEditingController _statusMessageController =
      TextEditingController();
  bool _isLoading = false;

  void _updateStatusMessage() async {
    if (_statusMessageController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('organization')
        .doc(widget.adminOrgId)
        .collection('reports')
        .doc(widget.reportId)
        .update({
      "status": "In Progress",
      "status_message": _statusMessageController.text,
    });

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Status updated successfully")),
    );
  }

  void _markAsResolved() async {
    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('organization')
        .doc(widget.adminOrgId)
        .collection('reports')
        .doc(widget.reportId)
        .update({
      "status": "Resolved",
    });

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report marked as Resolved")),
    );
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
              controller: _statusMessageController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Enter Status Message",
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
                      onPressed: _updateStatusMessage,
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
        onPressed: _markAsResolved,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text("Mark as Resolved"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
