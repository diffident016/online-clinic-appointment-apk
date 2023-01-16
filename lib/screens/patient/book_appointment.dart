import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/screens/patient/form_1.dart';
import 'package:online_clinic_appointment/screens/patient/form_2.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

import '../../models/schedule.dart';

class BookAppointment extends StatefulWidget {
  final Patient patient;
  final VoidCallback updateAppointment;
  const BookAppointment(
      {Key? key, required this.patient, required this.updateAppointment})
      : super(key: key);

  @override
  BookAppointmentState createState() => BookAppointmentState();
}

class BookAppointmentState extends State<BookAppointment> {
  int currentIndex = 0;
  Appointment? _appointment;
  DateTime? _selectedDay;
  DateTime? _selectedTime;
  bool valid = false;

  late List<bool> available;
  List<Schedule>? schedules;

  void updateIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Appointment getAppointment() {
    return _appointment!;
  }

  void setAppointment(Appointment appointment) {
    _appointment = appointment;
  }

  Future getSchedules() {
    return Services.getSchedules().then((response) {
      Map parsed = json.decode(response.body);

      if (response.statusCode == 200) {
        schedules = List.from(parsed["data"])
            .map((doc) => Schedule.fromJson(doc))
            .toList();

        checkAvailableSlot();
      } else {
        ShowInfo.showToast(parsed["error"]["message"]);
      }
    }).timeout(const Duration(seconds: 15), onTimeout: () {
      ShowInfo.showToast("Unable to communicate with the server.");
    });
  }

  Future finalSchedCheck() async {
    final String toCompare = DateFormat("yyyy-MM-dd").format(_selectedDay!) +
        DateFormat.Hms().format(_selectedTime!);

    bool check = true;

    await getSchedules().whenComplete(() {
      if ((schedules!
              .firstWhereOrNull((sched) => sched.comparator == toCompare)) !=
          null) {
        check = false;
      } else {
        check = true;
      }
    }).timeout(const Duration(seconds: 15), onTimeout: () {
      ShowInfo.showToast("Unable to communicate with the server.");
    });

    return check;
  }

  void checkAvailableSlot() async {
    if (schedules == null) {
      await getSchedules().timeout(const Duration(seconds: 15), onTimeout: () {
        ShowInfo.showToast("Unable to communicate with the server.");
        return;
      });
    }

    if (schedules == null) {
      setState(() {
        available = List.generate(schedTime.length, (i) => true);
      });

      return;
    }

    DateTime temp = DateTime.now();

    if (_selectedDay != null) {
      temp = _selectedDay!;
    }

    for (int i = 0; i < schedTime.length; i++) {
      setState(() {
        available[i] = true;
      });

      final String toCompare = DateFormat("yyyy-MM-dd").format(temp) +
          DateFormat.Hms().format(schedTime[i]);
      if ((schedules!
              .firstWhereOrNull((sched) => sched.comparator == toCompare)) !=
          null) {
        setState(() {
          available[i] = false;
          if (_selectedTime == schedTime[i]) {
            _selectedTime = null;
          }
        });
      }
    }
  }

  void selectDateTime(DateTime? selectedDate, DateTime? selectedTime) {
    if (mounted) {
      setState(() {
        _selectedDay = selectedDate;
        _selectedTime = selectedTime;
      });
    }

    checkAvailableSlot();
  }

  @override
  void initState() {
    super.initState();
    available = List.generate(schedTime.length, (i) => true);
    getSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: GestureDetector(
              onTap: () {
                if (currentIndex > 0) {
                  updateIndex(currentIndex - 1);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: const Icon(
                Icons.arrow_back,
                size: 22,
                color: Colors.white,
              )),
          automaticallyImplyLeading: false,
          title: const Text(
            'Book Appointment',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: currentIndex,
          children: [
            Form1(
                patient: widget.patient,
                updateIndex: (int index) {
                  updateIndex(index);
                },
                setAppointment: (Appointment appointment) {
                  setAppointment(appointment);
                },
                selectDateTime: (DateTime? date, DateTime? time) {
                  selectDateTime(date, time);
                },
                available: available,
                selectedTime: _selectedTime,
                selectedDay: _selectedDay),
            Form2(
              updateIndex: (int index) {
                updateIndex(index);
              },
              getAppointment: getAppointment,
              finalSchedCheck: finalSchedCheck,
              checkAvailableSlot: () {
                checkAvailableSlot();
              },
              updateAppointment: () {
                widget.updateAppointment();
              },
            )
          ],
        ));
  }
}
