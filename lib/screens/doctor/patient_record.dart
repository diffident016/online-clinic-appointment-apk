import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:collection/collection.dart';
import 'package:online_clinic_appointment/models/doctor.dart';
import 'package:online_clinic_appointment/models/record.dart';
import 'package:online_clinic_appointment/screens/doctor/patient_card.dart';
import 'package:online_clinic_appointment/screens/doctor/record_view.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

class PatientRecord extends StatefulWidget {
  final Doctor? doctor;
  const PatientRecord({Key? key, this.doctor}) : super(key: key);

  @override
  PatientRecordState createState() => PatientRecordState();
}

class PatientRecordState extends State<PatientRecord> {
  final TextEditingController _searchInput = TextEditingController();

  List<Appointment> appointments = [];
  List<Appointment> searched = [];
  List<Record> records = [];

  int fetchState = 0;
  int recordFetch = 0;
  bool clickBtn = false;
  bool isSearching = false;
  bool isOpening = false;
  int selectedIndex = 0;
  bool fromSearch = false;

  @override
  void initState() {
    super.initState();

    fetchAppointments();
  }

  void searchPatients(String query) {
    final suggestions = appointments.where((app) {
      final patientname =
          '${app.patient.lastname}, ${app.patient.firstname}, ${app.patient.midname}'
              .toLowerCase();
      final input = query.toLowerCase();

      return patientname.contains(input);
    }).toList();

    setState(() {
      searched = suggestions;
    });
  }

  void getRecords() {
    setState(() {
      recordFetch = 0;
    });
    try {
      final patient = fromSearch
          ? searched[selectedIndex].patient
          : appointments[selectedIndex].patient;

      Services.getRecords(patient.id!).then((value) {
        if (value.statusCode == 200) {
          Map parse = json.decode(value.body);

          records =
              List.from(parse["data"]).map((e) => Record.fromJson(e)).toList();

          if (records.isEmpty) {
            setState(() {
              recordFetch = 2;
            });
          } else {
            setState(() {
              recordFetch = 1;
            });
          }
        } else {
          setState(() {
            recordFetch = -1;
          });
        }
      });
    } on Exception catch (_) {
      setState(() {
        recordFetch = -1;
      });
      return;
    }
  }

  void fetchAppointments() {
    setState(() {
      fetchState = 0;
    });
    try {
      Services.getAllAppointments().then((value) {
        if (value.statusCode == 200) {
          Map parse = json.decode(value.body);

          appointments = List.from(parse["data"])
              .map((e) => Appointment.fromJson(e))
              .toList();

          if (appointments.isEmpty) {
            setState(() {
              fetchState = 2;
            });
            return;
          }

          final newGroup =
              groupBy(appointments, ((Appointment ap) => ap.patient.id))
                  .entries
                  .toList();

          appointments.clear();

          for (var e in newGroup) {
            List<Appointment> group = e.value;
            group.sort((a, b) => a.schedule.date.compareTo(b.schedule.date));
            appointments.add(group[0]);
          }

          setState(() {
            fetchState = 1;
          });
        }
      });
    } on Exception catch (_) {
      setState(() {
        fetchState = -1;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: false,
                      controller: _searchInput,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          hintText: "Search patient's name",
                          isCollapsed: true,
                          isDense: true,
                          suffixIconConstraints:
                              BoxConstraints.tight(const Size(35, 18)),
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 10, 10, 10),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10)),
                          suffixIcon: !isSearching
                              ? null
                              : GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      isSearching = false;
                                      clickBtn = false;
                                      _searchInput.clear();
                                    });
                                  },
                                  child: const Icon(Icons.close, size: 18))),
                      onChanged: (value) {
                        if (clickBtn && value.isNotEmpty) {
                          searchPatients(_searchInput.text);
                        }
                      },
                      onTap: () {
                        setState(() {
                          isSearching = true;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (_searchInput.text.isEmpty) {
                          ShowInfo.showToast("Type something in search bar");
                          return;
                        }

                        fetchAppointments();

                        searchPatients(_searchInput.text);

                        setState(() {
                          clickBtn = true;
                        });
                      },
                      child: Container(
                        width: 45,
                        height: 40,
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                buildLabel(),
                style: TextStyle(
                    color: primaryColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 5,
              ),
              fetchState != 1 ? statusBuilder() : buildDisplay(size)
            ]),
      ),
    );
  }

  String buildLabel() {
    if (clickBtn) {
      return 'SEARCH RESULT';
    } else if (isOpening) {
      return "PATIENT'S DETAILS";
    } else {
      return 'RECENT PATIENTS';
    }
  }

  Widget buildDisplay(Size size) {
    if (clickBtn) {
      return searched.isEmpty
          ? const Center(child: Text('No patients found'))
          : SingleChildScrollView(
              child: SizedBox(
                height: size.height * 0.6,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: searched.length,
                    shrinkWrap: true,
                    itemBuilder: ((context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                fromSearch = true;
                                selectedIndex = index;
                                FocusScope.of(context).unfocus();
                                clickBtn = false;
                                isSearching = false;
                                getRecords();
                                isOpening = true;
                                _searchInput.text = "";
                              });
                            },
                            child: PatientCard(
                              appointment: searched[index],
                            ),
                          ),
                        ))),
              ),
            );
    } else if (isOpening) {
      return RecordView(
        patient: fromSearch
            ? searched[selectedIndex].patient
            : appointments[selectedIndex].patient,
        fetchState: recordFetch,
        doctor: widget.doctor!,
        records: records,
        refreshRecords: () {
          getRecords();
        },
      );
    } else {
      return SingleChildScrollView(
        child: SizedBox(
          height: size.height * 0.6,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: appointments.length,
              shrinkWrap: true,
              itemBuilder: ((context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          fromSearch = false;
                          selectedIndex = index;
                          FocusScope.of(context).unfocus();
                          clickBtn = false;
                          isSearching = false;
                          getRecords();
                          isOpening = true;
                          _searchInput.text = "";
                        });
                      },
                      child: PatientCard(
                        appointment: appointments[index],
                      ),
                    ),
                  ))),
        ),
      );
    }
  }

  Widget statusBuilder() {
    if (fetchState == 2) {
      return const Center(child: Text('No recent patients'));
    } else if (fetchState == -1) {
      return const Center(child: Text('An error occurred'));
    } else {
      return SizedBox(
        height: 60,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                )),
            SizedBox(
              width: 10,
            ),
            Text(
              'Loading, please wait...',
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
      );
    }
  }
}
