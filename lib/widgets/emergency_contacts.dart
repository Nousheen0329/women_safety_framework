import 'package:flutter/material.dart';

class EmergencyContacts extends StatelessWidget {
  final List<String> contacts;
  final Function(String) onAddContact;
  final Function(int) onRemoveContact;

  EmergencyContacts({
    required this.contacts,
    required this.onAddContact,
    required this.onRemoveContact,
  });

  final TextEditingController _contactController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Emergency Contacts",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(contacts[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => onRemoveContact(index),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    hintText: "Enter a new contact number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  onAddContact(_contactController.text.trim());
                  _contactController.clear();
                },
                child: Text("Add"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
