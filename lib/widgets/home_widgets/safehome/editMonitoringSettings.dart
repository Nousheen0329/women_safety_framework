import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:women_safety_framework/reusable_widgets/textStyles.dart';
import 'dart:convert';
import '../../../main.dart';
import '../../../utils/color_utils.dart';
import 'editEmergencyContacts.dart';
import 'editGeofencing.dart';
import 'selectLocationPage.dart';
import '../../../reusable_widgets/buttons.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import '../../../reusable_widgets/buttons.dart';
import '../../../reusable_widgets/textStyles.dart';

class EditMonitoringSettings extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  EditMonitoringSettings({required this.secureStorage});

  @override
  _MonitoringSettingWidgetState createState() =>
      _MonitoringSettingWidgetState();
}

class _MonitoringSettingWidgetState extends State<EditMonitoringSettings> {
  bool _batteryMonitoring = false;
  bool _gestureMonitoring = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    String? batterySetting = await widget.secureStorage.read(
        key: "battery_monitoring_enabled");
    String? gestureSetting = await widget.secureStorage.read(
        key: "gesture_monitoring_enabled");

    setState(() {
      _batteryMonitoring = batterySetting == "true";
      _gestureMonitoring = gestureSetting == "true";
    });
  }

  Future<void> _saveSettings() async {
    await widget.secureStorage.write(key: "battery_monitoring_enabled",
        value: _batteryMonitoring.toString());
    await widget.secureStorage.write(
        key: "gesture_monitoring_enabled", value: _gestureMonitoring.toString());
    if(_batteryMonitoring==false){
      stopBatteryMonitoring();
    }
    if(_gestureMonitoring==false){
      final service = FlutterBackgroundService();
      service.invoke("stop");
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Background Monitoring"),
          content:
          Text("Please restart the app for the changes to reflect. Gesture Monitoring requires the app to be running on the background. Please ensure that you do not delete the app from recent apps while using your phone. This may affect battery. If you do not need this, it can be disabled."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildSectionTitle('Background Monitoring'),
        SwitchListTile(
          title: normalText("Enable Battery Monitoring"),
          activeTrackColor: Colors.green[400],
          value: _batteryMonitoring,
          onChanged: (value) {
            setState(() {
              _batteryMonitoring = value;
            });
          },
        ),
        SwitchListTile(
          title: normalText("Enable Gesture Monitoring"),
          activeTrackColor: Colors.green[400],
          value: _gestureMonitoring,
          onChanged: (value) {
            setState(() {
              _gestureMonitoring = value;
            });
          },
        ),
        SizedBox(height: 10),
        CustomButton(
          text: 'Save Changes',
          onPressed: _saveSettings,
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }
}
