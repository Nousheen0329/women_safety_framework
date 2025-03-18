import 'dart:async';
import 'dart:convert';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'fetchWorkplaceDetails.dart';

class SOSService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static ValueNotifier<bool> _sosCanceledNotifier = ValueNotifier(false);

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification Tapped");
        _sosCanceledNotifier.value = true;  // ✅ Update ValueNotifier instead
        print("value of _sosCanceled ${_sosCanceledNotifier.value}");
        Fluttertoast.showToast(msg: "SOS alert canceled.");
      },
    );
  }

  static Future<void> sendSOSAlert() async {
    _sosCanceledNotifier.value = false; // ✅ Reset notifier before starting
    _showSOSNotification();

    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(seconds: 1));

      print("value of _sosCanceled ${_sosCanceledNotifier.value}");
      if (_sosCanceledNotifier.value) {
        print("SOS Canceled before sending.");
        return; // ✅ Stop execution if canceled
      }
    }

    print("Sending SOS...");
    await _sendSOSMessages();
  }

  static Future<void> _sendSOSMessages() async {
    print("Sending SOS...");

    String? storedContacts = await _storage.read(key: "emergency_contacts");
    String? workplaceContactsData = await _storage.read(key: "workplace_emergency_contacts");

    List<String> workplaceContacts = workplaceContactsData != null
        ? List<String>.from(jsonDecode(workplaceContactsData))
        : [];

    List<String> contacts = storedContacts != null && storedContacts.isNotEmpty
        ? List<String>.from(jsonDecode(storedContacts))
        : [];

    if (contacts.isEmpty) {
      Fluttertoast.showToast(msg: "No emergency contacts added.");
      return;
    }

    bool isAtWorkplace = await checkIfAtWorkplace();
    List<String> recipients = contacts;
    if (isAtWorkplace) recipients.addAll(workplaceContacts);

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    String locationUrl = "https://www.google.com/maps?q=${position.latitude},${position.longitude}";

    String message = "You have received an SOS. This is an emergency alert. My location: $locationUrl.\n";

    for (String contact in recipients) {
      SmsStatus result = await BackgroundSms.sendMessage(phoneNumber: contact, message: message);
      Fluttertoast.showToast(msg: result == SmsStatus.sent
          ? "SOS alert sent to $contact"
          : "Alert not sent to $contact, please try again");
      await Future.delayed(Duration(milliseconds: 5000)); // Delay between messages
    }
  }

  static Future<void> _showSOSNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sos_channel', 'SOS Alert',
      channelDescription: 'Alerts for emergency situations',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'SOS Alert',
      ongoing: true, // Keeps the notification active until user action
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // Notification ID
      'SOS Alert',
      'An SOS will be sent in 10 seconds. Tap to cancel.',
      notificationDetails,
      payload: "cancel_sos",
    );
  }
}
