import 'package:flutter/material.dart';
import 'package:background_sms/background_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class SafeHome extends StatefulWidget {
  final List<String> contacts;
  final Function(List<String>) updateContacts; // Callback function to update contacts

  SafeHome({Key? key, required this.contacts, required this.updateContacts}) : super(key: key);

  @override
  _SafeHomeState createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  final TextEditingController _contactController = TextEditingController(); // Declare the controller

  @override
  void dispose() {
    _contactController.dispose(); // Dispose controller to free resources
    super.dispose();
  }

  // Method to get current location
  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Request SMS permission
  Future<void> requestSMSPermission() async {
    if (await Permission.sms.isDenied) {
      await Permission.sms.request();
    }
  }

  // Send SOS alert with location
  Future<void> sendSOSAlert(Position position) async {
    String locationUrl = "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
    String message = "I am in danger! Please help. My location: $locationUrl";

    for (String contact in widget.contacts) {
      SmsStatus result = await BackgroundSms.sendMessage(phoneNumber: contact, message: message);

      if (result == SmsStatus.sent) {
        print("SMS sent successfully to $contact");
      } else {
        print("Failed to send SMS to $contact");
      }

      await Future.delayed(Duration(milliseconds: 5000)); // Add delay
    }

    Fluttertoast.showToast(msg: "SOS alerts sent!");
  }

  // Add a new contact
  void _addContact() {
    String newContact = _contactController.text.trim();
    if (newContact.isNotEmpty) {
      setState(() {
        List<String> updatedContacts = List.from(widget.contacts)..add(newContact);
        widget.updateContacts(updatedContacts);
        _contactController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            await requestSMSPermission();
            Position position = await _getCurrentLocation();
            sendSOSAlert(position);
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text("Send Location alert"),

                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/route.jpg', fit: BoxFit.cover, height: 180),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: "Add Emergency Contact",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addContact,
                child: Text("Add Contact"),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.contacts.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(widget.contacts[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  List<String> updatedContacts = List.from(widget.contacts)..removeAt(index);
                  widget.updateContacts(updatedContacts);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
