import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';

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
          title: Text(
            "ONCASS",
            style: TextStyle(
                color: primaryColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 24),
          )),
      body: SingleChildScrollView(
          child: Column(
        children: [
          ListTile(
            leading: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: primaryColor.withOpacity(0.5)),
            ),
            title: const Text(
              'Hello, Staff',
              style: TextStyle(color: textColor),
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
            height: 60,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 0;
                    });
                  },
                  child: Container(
                      width: size.width / 3,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: currentIndex == 0
                                      ? primaryColor
                                      : Colors.transparent,
                                  width: 3))),
                      child: Center(
                        child: Text(
                          'DASHBOARD',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color:
                                  currentIndex == 0 ? primaryColor : textColor),
                        ),
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  },
                  child: Container(
                      width: size.width / 3,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: currentIndex == 1
                                      ? primaryColor
                                      : Colors.transparent,
                                  width: 3))),
                      child: Center(
                        child: Text('STATISTICS',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: currentIndex == 1
                                    ? primaryColor
                                    : textColor)),
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 2;
                    });
                  },
                  child: Container(
                      width: size.width / 3,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: currentIndex == 2
                                      ? primaryColor
                                      : Colors.transparent,
                                  width: 3))),
                      child: Center(
                        child: Text('SCANNER',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: currentIndex == 2
                                    ? primaryColor
                                    : textColor)),
                      )),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
