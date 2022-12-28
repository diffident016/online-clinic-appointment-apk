import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/screens/auth/login.dart';
import 'package:online_clinic_appointment/screens/patient/patient_home.dart';
import 'package:online_clinic_appointment/screens/staff/staff_home.dart';

class UserSelect extends StatefulWidget {
  const UserSelect({Key? key}) : super(key: key);

  @override
  _UserSelectState createState() => _UserSelectState();
}

class _UserSelectState extends State<UserSelect> {
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return Center(child: Text("error"));
    };

    return Scaffold(
      body: StreamBuilder(
        stream: UserAccount.currentUser(),
        builder: (context, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (data.hasError) {
            return const Login();
          } else if (data.hasData) {
            if (data.data == true) {
              final userType = UserAccount.user!.userType;
              if (userType == 'staff') {
                return const StaffHome();
              } else {
                return const PatientHome();
              }
            }
            return const Login();
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}
