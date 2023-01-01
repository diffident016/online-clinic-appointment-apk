import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/screens/common/dashboard.dart';
import 'package:online_clinic_appointment/screens/staff/statistics.dart';
import 'package:online_clinic_appointment/screens/staff/scanner.dart';

class StaffHome extends StatefulWidget {
  const StaffHome({Key? key}) : super(key: key);

  @override
  StaffHomeState createState() => StaffHomeState();
}

class StaffHomeState extends State<StaffHome> {
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
            leading: Icon(
              Icons.account_circle_rounded,
              color: primaryColor.withOpacity(0.8),
              size: 42,
            ),
            title: const Text(
              'Hello, Staff',
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
                buildTabs(1, currentIndex, size, label: "STATISTICS",
                    onClick: () {
                  setState(() {
                    currentIndex = 1;
                  });
                }),
                buildTabs(2, currentIndex, size, label: "SCANNER", onClick: () {
                  setState(() {
                    currentIndex = 2;
                  });
                }),
              ],
            ),
          ),
          SizedBox(
            height: size.height - (size.height * 0.23),
            width: double.infinity,
            child: IndexedStack(
              index: currentIndex,
              children: [Dashboard(), Statistics(), Scanner()],
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
          width: size.width / 3,
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
