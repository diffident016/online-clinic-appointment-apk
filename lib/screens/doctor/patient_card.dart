import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';

class PatientCard extends StatelessWidget {
  final Appointment appointment;
  const PatientCard({Key? key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.account_circle_rounded,
          color: primaryColor.withOpacity(0.8),
          size: 42,
        ),
        title: Text(
          '${appointment.patient.lastname}, ${appointment.patient.firstname}',
          style: const TextStyle(color: textColor, fontSize: 14),
        ),
        subtitle: Text(
            "Appointment: ${DateFormat("MM/dd/yyyy - E").format(appointment.schedule.date)}"),
      ),
    );
  }
}
