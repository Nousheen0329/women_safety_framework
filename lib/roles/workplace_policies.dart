import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class WorkplacePolicies extends StatefulWidget {
  final String organizationId;
  final bool isAdmin;
  const WorkplacePolicies({
    Key? key,
    required this.organizationId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<WorkplacePolicies> createState() => _WorkplacePoliciesState();
}

class _WorkplacePoliciesState extends State<WorkplacePolicies> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _deleteFile(String documentId, String filePath) async {
    try {
      await _supabase.storage.from('workplace_policies').remove([filePath]);

      await _firestore
          .collection('organization')
          .doc(widget.organizationId)
          .collection('workplace_policies')
          .doc(documentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $error')),
      );
    }
  }

  void _viewPDF(String pdfUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(pdfUrl: pdfUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workplace Policies')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('organization')
            .doc(widget.organizationId)
            .collection('workplace_policies')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No workplace policies uploaded.'));
          }

          var files = snapshot.data!.docs;

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              var file = files[index];

              Map<String, dynamic>? fileData =
                  file.data() as Map<String, dynamic>?;

              if (fileData == null ||
                  !fileData.containsKey('name') ||
                  !fileData.containsKey('pdfUrl') ||
                  !fileData.containsKey('filePath')) {
                return const SizedBox(); // Skip rendering if data is missing
              }

              String fileName = fileData['name'] ?? 'Unknown';
              String fileUrl = fileData['pdfUrl'] ?? '';
              String filePath = fileData['filePath'] ?? '';

              return Card(
                child: ListTile(
                  title: Text(fileName),
                  trailing: widget.isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFile(file.id, filePath),
                        )
                      : null,
                  onTap: () => _viewPDF(fileUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;
  const PDFViewerScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workplace Policies')),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
