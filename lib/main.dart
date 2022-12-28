import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/screens/auth/login.dart';
import 'package:online_clinic_appointment/screens/auth/sign_up.dart';
import 'package:online_clinic_appointment/screens/patient/patient_home.dart';
import 'package:online_clinic_appointment/user_select.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ONCASS',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          backgroundColor: backgroundColor,
          appBarTheme: appBarTheme),
      
      home: UserSelect(),
    );
  }
}
