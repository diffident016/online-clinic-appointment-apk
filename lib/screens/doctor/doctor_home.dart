import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/screens/common/dashboard.dart';
import 'package:online_clinic_appointment/screens/doctor/patient_record.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({Key? key}) : super(key: key);

  @override
  DoctorHomeState createState() => DoctorHomeState();
}

class DoctorHomeState extends State<DoctorHome> {
  int currentIndex = 0;
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
      body: Column(
        children: [
          ListTile(
            dense: true,
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: primaryColor.withOpacity(0.5)),
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
          SizedBox(
            height: size.height - (size.height * 0.23),
            width: double.infinity,
            child: IndexedStack(
              index: currentIndex,
              children: [Dashboard(), PatientRecord()],
            ),
          )
        ],
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
