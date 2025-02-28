import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportDetails extends StatefulWidget {
  final String userId;

  const ReportDetails({super.key, required this.userId});

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _accusedDetailsController =
      TextEditingController();
  String _priority = "Low";
  bool _isLoading = false;

  Future<void> _submitReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('working_women')
          .doc(widget.userId)
          .get();

      if (!userSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User details not found!")),
        );
        return;
      }

      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      String organizationId = userData["organization_id"];
      String reportId =
          FirebaseFirestore.instance.collection('reports').doc().id;

      Map<String, dynamic> reportData = {
        "report_id": reportId,
        "user_id": widget.userId,
        "name": userData["name"],
        "phone_number": userData["phone_number"],
        "email": userData["email"],
        "employee_id": userData["employee_id"],
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "accused_details": _accusedDetailsController.text.trim(),
        "priority_level": _priority,
        "status": "Pending",
        "created_at": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("organization")
          .doc(organizationId)
          .collection("reports")
          .doc(reportId)
          .set(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report submitted successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting report: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Report"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Report Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _accusedDetailsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Accused Person Details (if known)",
                  alignLabelWithHint: true,
                  hintText:
                      "Enter any details you know (name, ID, phone, etc.)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Priority Level",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: ["Low", "Medium", "High"].map((level) {
                  return Row(
                    children: [
                      Radio<String>(
                        value: level,
                        groupValue: _priority,
                        onChanged: (value) {
                          setState(() {
                            _priority = value!;
                          });
                        },
                      ),
                      Text(level),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Report",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
