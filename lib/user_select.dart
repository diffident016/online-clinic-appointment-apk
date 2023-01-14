import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/screens/auth/login.dart';
import 'package:online_clinic_appointment/screens/auth/sign_up.dart';
import 'package:online_clinic_appointment/screens/doctor/doctor_home.dart';
import 'package:online_clinic_appointment/screens/patient/patient_home.dart';
import 'package:online_clinic_appointment/screens/staff/staff_home.dart';

class UserSelect extends StatefulWidget {
  const UserSelect({Key? key}) : super(key: key);

  @override
  UserSelectState createState() => UserSelectState();
}

class UserSelectState extends State<UserSelect> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: UserAccount.currentUser(),
        builder: (context, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (data.hasError) {
            return const Login();
          } else if (data.hasData) {
            if (data.data == 1) {
              final userType = UserAccount.user!.userType;
              if (userType == 'staff') {
                return const StaffHome();
              } else if (userType == 'doctor') {
                return const DoctorHome();
              } else {
                return const PatientHome();
              }
            } else if (data.data == 2) {
              return const SignUp();
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
