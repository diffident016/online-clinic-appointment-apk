import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/message.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/screens/common/appointment_details.dart';
import 'package:online_clinic_appointment/screens/common/change_password.dart';
import 'package:online_clinic_appointment/screens/patient/book_appointment.dart';
import 'package:online_clinic_appointment/screens/patient/patient_appointments.dart';
import 'package:online_clinic_appointment/screens/patient/patient_profile.dart';
import 'package:online_clinic_appointment/screens/patient/patient_record.dart';
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
        await storage.write(key: 'patientId', value: patient!.id.toString());
        setState(() {
          display = 'Update';
        });
      } else {
        Services.getPatientProfile().then((value) async {
          if (value.statusCode == 200) {
            Map parse = jsonDecode(value.body);

            if (List.from(parse["data"]).isNotEmpty) {
              patient = Patient.fromJson(List.from(parse["data"])[0]);
              await storage.write(
                  key: 'patientId', value: patient!.id.toString());

              setState(() {
                display = 'Update';
              });

              Services.savePatientProfile(patient!);
            }
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
                  title: Text(
                    'Hello, ${patient == null ? 'Patient' : patient!.firstname}',
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
                  height: 20,
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
                          'Schedule an appointment',
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
                      if (patient == null) {
                        ShowInfo.showToast(
                            "You need to setup your patient profile first.");
                        return;
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  PatientAppointments(patient: patient!))));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: textColor.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(
                          'Appointment history',
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
                      if (patient == null) {
                        ShowInfo.showToast(
                            "You need to setup your patient profile first.");
                        return;
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => PatientOnlyRecord())));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: textColor.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(
                          'My Records',
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
                      decoration: BoxDecoration(
                          border: Border.all(color: textColor.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(
                          'Talk to our chatbot',
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
                )
              ]),
      ),
    );
  }
}
