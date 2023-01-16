import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/screens/common/appointment_details.dart';

class PatientAppointments extends StatefulWidget {
  final Patient patient;
  const PatientAppointments({Key? key, required this.patient})
      : super(key: key);

  @override
  PatientAppointmentsState createState() => PatientAppointmentsState();
}

class PatientAppointmentsState extends State<PatientAppointments> {
  List<Appointment> appointments = [];

  int fetchState = 0;

  @override
  void initState() {
    super.initState();

    getAppointments();
  }

  void getAppointments() async {
    final route = "filters[patient][id]=${widget.patient.id}";

    await Services.getAppointments(route).then((value) {
      if (value.statusCode == 200) {
        final parse = jsonDecode(value.body);

        appointments = List.from(parse["data"])
            .map((e) => Appointment.fromJson(e))
            .toList();

        if (appointments.isEmpty) {
          setState(() {
            fetchState = 2;
          });
        } else {
          setState(() {
            fetchState = 1;
          });
        }
      }
    }).onError((error, stackTrace) {
      setState(() {
        fetchState = -1;
      });
    });
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
          'Appointments',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: fetchState != 1
          ? statusBuilder()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Your Appointments:',
                      style: TextStyle(
                          color: primaryColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  ListView.builder(
                      itemCount: appointments.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: ((context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: appointmentsBuilder(appointments[index]),
                        );
                      })),
                ],
              ),
            ),
    );
  }

  Widget appointmentsBuilder(Appointment appointment) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AppoinmentDetails(appointment: appointment)));
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          dense: true,
          leading: Icon(
            Icons.description_outlined,
            color: primaryColor.withOpacity(0.8),
            size: 42,
          ),
          title: Text(
            "Appt. ID: ${appointment.app_code}",
            style: const TextStyle(color: textColor, fontSize: 14),
          ),
          subtitle: Text(
              "Schedule: ${DateFormat("MM/dd/yyyy - E").format(appointment.schedule.date)}"),
        ),
      ),
    );
  }

  Widget statusBuilder() {
    if (fetchState == 2) {
      return const Center(child: Text('You have no appointments.'));
    } else if (fetchState == -1) {
      return const Center(child: Text('An error occured, please try again.'));
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
