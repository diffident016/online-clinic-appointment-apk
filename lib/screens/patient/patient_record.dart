import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:collection/collection.dart';
import 'package:online_clinic_appointment/models/doctor.dart';
import 'package:online_clinic_appointment/models/record.dart';
import 'package:online_clinic_appointment/screens/patient/record_view.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

import '../../models/patient.dart';

class PatientOnlyRecord extends StatefulWidget {
  const PatientOnlyRecord({Key? key}) : super(key: key);

  @override
  PatientRecordState createState() => PatientRecordState();
}

class PatientRecordState extends State<PatientOnlyRecord> {
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

  late FlutterSecureStorage storage;

  Patient? patient;

  @override
  void initState() {
    super.initState();
    storage = const FlutterSecureStorage();
    getRecords();
  }

  void getRecords() async {
    setState(() {
      recordFetch = 0;
    });
    try {
      var patientIdFromStorage = await storage.read(key: 'patientId');
      int patientId = int.parse(patientIdFromStorage.toString());
      Services.getRecords(patientId).then((value) {
        if (value.statusCode == 200) {
          Map parse = jsonDecode(value.body);

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

  @override
  Widget build(BuildContext context) {
    // return Text("Patient Records");
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
          'My Records',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: PatientRecordView(
              fetchState: recordFetch,
              records: records,
              refreshRecords: () {
                getRecords();
              },
            )),
      ),
    );
  }
}
