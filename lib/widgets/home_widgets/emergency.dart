import 'package:flutter/material.dart';
import 'package:women_safety_framework/reusable_widgets/emergencyCard.dart';


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
          EmergencyCard(
              title: 'Active Emergency',
              information: 'In case of danger, call',
              number: '100',
              hyphenated: '1-0-0',
              imagePath: 'assets/army.png'),
          EmergencyCard(
              title: 'Ambulance',
              information: 'For medical help, call',
              number: '108',
              hyphenated: '1-0-8',
              imagePath: 'assets/ambulance.png'),
          EmergencyCard(
              title: 'Fire and Rescue',
              information: 'In case of fire danger, call',
              number: '101',
              hyphenated: '1-0-1',
              imagePath: 'assets/flame.png'),
          EmergencyCard(
              title: 'Women & Child',
              information: 'National Helpline',
              number: '181',
              hyphenated: '1-8-1',
              imagePath: 'assets/logo.png')
        ],
      ),
    );
  }
}
