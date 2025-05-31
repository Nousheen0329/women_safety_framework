import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import '../../../reusable_widgets/buttons.dart';
import '../../../reusable_widgets/textStyles.dart';

class EmergencyContactsWidget extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  EmergencyContactsWidget({required this.secureStorage});

  @override
  _EmergencyContactsWidgetState createState() =>
      _EmergencyContactsWidgetState();
}

class _EmergencyContactsWidgetState extends State<EmergencyContactsWidget> {
  final TextEditingController _contactController = TextEditingController();
  List<String> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void dispose() {
    _contactController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    String? storedContacts =
    await widget.secureStorage.read(key: "emergency_contacts");
    if (storedContacts != null && storedContacts.isNotEmpty) {
      setState(() {
        _contacts = List<String>.from(jsonDecode(storedContacts));
      });
    }
  }

  void _addContact() {
    String newContact = _contactController.text.trim();
    if (newContact.isNotEmpty) {
      setState(() {
        _contacts.add(newContact);
      });
      _contactController.clear();
    }
  }

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  Future<void> _saveContacts() async {
    await widget.secureStorage.write(
        key: "emergency_contacts", value: jsonEncode(_contacts));
    Navigator.pop(context, _contacts);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildSectionTitle('Add and Delete\nEmergency Contacts'),
        SizedBox(
          width: MediaQuery.of(context).size.width-30,
          child: TextField(
            controller: _contactController,
            decoration: InputDecoration(
              labelText: "Add Emergency Contact",
              labelStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white
              ),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
        ),

        CustomButton(
          text: "Add Contact",
          onPressed: _addContact,
          icon: const Icon(Icons.add_ic_call_rounded),
        ),

        ListView.builder(
          shrinkWrap: true,
          itemCount: _contacts.length,
          itemBuilder: (context, index) => ListTile(
            title: normalText(_contacts[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteContact(index),
            ),
          ),
        ),
        CustomButton(
          text: "Save Changes",
          onPressed: _saveContacts,
          icon: const Icon(Icons.contacts_rounded),
        ),
      ],
    );
  }
}
