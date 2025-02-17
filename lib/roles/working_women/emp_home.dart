import 'package:flutter/material.dart';
import 'package:women_safety_framework/roles/working_women/emp_signin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Logout"),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => EmpSignin()));
          },
        ),
      ),
    );
  }
}
