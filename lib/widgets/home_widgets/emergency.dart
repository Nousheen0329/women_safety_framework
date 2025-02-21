import 'package:flutter/material.dart';
import 'package:women_safety_framework/widgets/home_widgets/emergencies/policeemergency.dart';

import 'emergencies/AmbulanceEmergency.dart';
import 'emergencies/ArmyEmergency.dart';
import 'emergencies/FirebrigadeEmergency.dart';

class Emergency extends StatelessWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.25,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceEmergency(),
          AmbulanceEmergency(),
          FirebrigadeEmergency(),
          ArmyEmergency(),
        ],
      ),
    );
  }
}
