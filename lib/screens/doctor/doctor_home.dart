import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/doctor.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/screens/common/change_password.dart';
import 'package:online_clinic_appointment/screens/common/dashboard.dart';
import 'package:online_clinic_appointment/screens/doctor/patient_record.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({Key? key}) : super(key: key);

  @override
  DoctorHomeState createState() => DoctorHomeState();
}

class DoctorHomeState extends State<DoctorHome> {
  int currentIndex = 0;
  late FlutterSecureStorage storage;

  Doctor? doctor;

  void getDoctor() async {
    try {
      final json = await storage.read(key: 'doctor');

      if (json != null) {
        setState(() {
          doctor = Doctor.fromLocalJson(jsonDecode(json));
        });
      } else {
        Services.getDoctor(UserAccount.user!.id!).then((value) {
          if (value.statusCode == 200) {
            Map parse = jsonDecode(value.body);

            setState(() {
              doctor = Doctor.fromJson(List.from(parse["data"])[0]);
            });

            Services.saveDoctor(doctor!);
          }
        });
      }
    } on Exception catch (_) {
      ShowInfo.showToast('An error occurred');
    }
  }

  @override
  void initState() {
    storage = const FlutterSecureStorage();
    super.initState();
    getDoctor();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 50,
          title: Text(
            "ONCASS",
            style: TextStyle(
                color: primaryColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 24),
          )),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              leading: PopupMenuButton(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                onSelected: (value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const ChangePassword())));
                },
                padding: const EdgeInsets.all(0),
                position: PopupMenuPosition.under,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Update Password'),
                  )
                ],
                icon: Icon(
                  Icons.account_circle_rounded,
                  color: primaryColor.withOpacity(0.8),
                  size: 46,
                ),
              ),
              title: const Text(
                'Hello, Doc',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
              trailing: GestureDetector(
                onTap: () {
                  UserAccount.logout();
                },
                child: Icon(
                  Icons.logout,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildTabs(0, currentIndex, size, label: "DASHBOARD",
                      onClick: () {
                    setState(() {
                      currentIndex = 0;
                    });
                  }),
                  buildTabs(1, currentIndex, size, label: "PATIENT RECORD",
                      onClick: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  })
                ],
              ),
            ),
            IndexedStack(
              index: currentIndex,
              children: [
                SizedBox(
                    height: size.height - (size.height * 0.23),
                    width: double.infinity,
                    child: const Dashboard()),
                SizedBox(
                    height: size.height - (size.height * 0.23),
                    width: double.infinity,
                    child: PatientRecord(
                      doctor: doctor,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildTabs(int index, int currentIndex, Size size,
      {required String label, required VoidCallback onClick}) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
          width: size.width / 2,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: currentIndex == index
                          ? primaryColor
                          : Colors.transparent,
                      width: 3))),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: currentIndex == index ? primaryColor : textColor),
            ),
          )),
    );
  }
}
