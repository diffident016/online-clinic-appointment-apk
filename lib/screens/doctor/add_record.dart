import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/doctor.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/models/record.dart';
import 'package:online_clinic_appointment/widgets/buttons.dart';
import 'package:online_clinic_appointment/widgets/loading_dialog.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

class AddRecord extends StatefulWidget {
  final Doctor doctor;
  final Patient patient;
  final VoidCallback refreshRecords;
  const AddRecord(
      {Key? key,
      required this.doctor,
      required this.patient,
      required this.refreshRecords})
      : super(key: key);

  @override
  AddRecordState createState() => AddRecordState();
}

class AddRecordState extends State<AddRecord> {
  Appointment? appointment;

  final TextEditingController _diagnosis = TextEditingController();
  final TextEditingController _prescription = TextEditingController();

  bool valid = false;

  void checkValidity() {
    if (_diagnosis.text.isNotEmpty && _prescription.text.isNotEmpty) {
      setState(() {
        valid = true;
      });
    } else {
      setState(() {
        valid = false;
      });
    }
  }

  Future getLatestAppointment() async {
    final route = "filters[patient][id]=${widget.patient.id}";

    bool res = false;
    Map parse;

    await Services.getAppointments(route).then((value) => {
          if (value.statusCode == 200)
            {
              parse = jsonDecode(value.body),
              appointment = Appointment.fromJson(List.from(parse["data"]).last),
              if (appointment != null) {res = true} else {res = false}
            },
          false
        });

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back,
              size: 22,
              color: Colors.white,
            )),
        automaticallyImplyLeading: false,
        title: const Text(
          'Add Record',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "DIAGNOSIS",
              style: TextStyle(
                  color: primaryColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                autofocus: false,
                maxLines: 4,
                controller: _diagnosis,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please type your diagnosis';
                  }
                  return null;
                },
                onChanged: (value) {
                  checkValidity();
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Type your diagnosis...',
                  hintStyle: TextStyle(
                    color: textColor.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(15, 12, 20, 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: textColor.withOpacity(0.4), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: textColor.withOpacity(0.4), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Text(
              "PRESCRIPTION",
              style: TextStyle(
                  color: primaryColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                autofocus: false,
                maxLines: 4,
                controller: _prescription,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please type your prescription';
                  }
                  return null;
                },
                onChanged: (value) {
                  checkValidity();
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Type your prescription...',
                  hintStyle: TextStyle(
                    color: textColor.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(15, 12, 20, 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: textColor.withOpacity(0.4), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: textColor.withOpacity(0.4), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Buttons(
                type: 1,
                textColor: Colors.white,
                color: valid ? primaryColor : availableSlot,
                label: 'SAVE RECORD',
                onClick: () {
                  FocusScope.of(context).unfocus();
                  if (valid) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const LoadingDialog(
                            message: 'Saving record, please wait...');
                      },
                    );
                    getLatestAppointment().then((value) {
                      if (value) {
                        final record = Record(
                            diagnosis: _diagnosis.text,
                            prescription: _prescription.text,
                            note: "No note",
                            appointment: appointment!,
                            patient: widget.patient,
                            doctor: widget.doctor);

                        Services.addRecord(record: record).then((value) {
                          Navigator.of(context).pop();
                          if (value.statusCode == 200) {
                            ShowInfo.showToast('Record has been save.');
                            widget.refreshRecords();
                            Navigator.of(context).pop();
                          } else {
                            ShowInfo.showToast('Failed to save record.');
                          }
                        });
                      } else {
                        ShowInfo.showToast(
                            "Something went wrong, please try again later.");
                      }
                    });
                  }
                })
          ]),
        ),
      ),
    );
  }
}
