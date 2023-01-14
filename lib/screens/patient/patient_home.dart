import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_clinic_appointment/api/chatbot.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/message.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/screens/common/appointment_details.dart';
import 'package:online_clinic_appointment/screens/patient/book_appointment.dart';
import 'package:online_clinic_appointment/screens/patient/patient_profile.dart';
import 'package:online_clinic_appointment/widgets/chat_box.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  PatientHomeState createState() => PatientHomeState();
}

class PatientHomeState extends State<PatientHome> {
  String? username;
  Patient? patient;
  Appointment? appointment;

  bool fetching = true;
  late FlutterSecureStorage storage;

  String display = 'Setup';

  List<Message> messages = [];

  @override
  void initState() {
    username = UserAccount.user!.username;

    storage = const FlutterSecureStorage();
    getPatientProfile();
    getAppointment();
    super.initState();
  }

  void getPatientProfile() async {
    try {
      final json = await storage.read(key: 'patient');

      if (json != null) {
        patient = Patient.fromLocalJson(jsonDecode(json));
        setState(() {
          display = 'Edit';
        });
      } else {
        Services.getPatientProfile().then((value) {
          if (value.statusCode == 200) {
            Map parse = jsonDecode(value.body);

            patient = Patient.fromJson(List.from(parse["data"])[0]);

            setState(() {
              display = 'Edit';
            });

            Services.savePatientProfile(patient!);
          }
        });
      }
    } on Exception catch (_) {
      ShowInfo.showToast('An error occurred');
    }
  }

  void getAppointment() async {
    final json = await storage.read(key: 'appointment');

    if (json != null) {
      setState(() {
        appointment = Appointment.fromLocalJson(jsonDecode(json));
      });
    }

    if (mounted) {
      setState(() {
        fetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
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
        body: fetching
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Center(child: CircularProgressIndicator())],
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ListTile(
                  leading: Icon(
                    Icons.account_circle_rounded,
                    color: primaryColor.withOpacity(0.8),
                    size: 46,
                  ),
                  title: Text(
                    'Hello, $username',
                    style: const TextStyle(color: textColor),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Patient Profile',
                    style: TextStyle(color: primaryColor.withOpacity(0.8)),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PatientProfile(
                                    patient: patient,
                                    getPatientProfile: () {
                                      getPatientProfile();
                                    },
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: textColor.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(
                          '$display your patient profile',
                          style: TextStyle(
                              color: textColor.withOpacity(0.6), fontSize: 14),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Patient Options',
                    style: TextStyle(color: primaryColor.withOpacity(0.8)),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      if (patient == null) {
                        ShowInfo.showToast(
                            "You need to setup your patient profile first.");
                        return;
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => BookAppointment(
                                    patient: patient!,
                                    updateAppointment: () {
                                      getAppointment();
                                    },
                                  ))));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: textColor.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(
                          'Book an appointment',
                          style: TextStyle(
                              color: textColor.withOpacity(0.6), fontSize: 14),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      if (appointment == null) {
                        ShowInfo.showToast(
                            "You don't have any appointment yet.");
                        return;
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => AppoinmentDetails(
                                    appointment: appointment!,
                                  ))));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: textColor.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(
                          'Appointment details',
                          style: TextStyle(
                              color: textColor.withOpacity(0.6), fontSize: 14),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
        floatingActionButton: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isDismissible: false,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  child: ChatBox(
                      saveMessages: (List<Message> messages) {
                        this.messages = messages;
                      },
                      messages: messages),
                ),
              ),
            );
          },
          child: Container(
            width: 56,
            height: 80,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: primaryColor),
            child: Icon(
                size: 38, Icons.contact_support_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
