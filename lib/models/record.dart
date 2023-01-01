import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/doctor.dart';
import 'package:online_clinic_appointment/models/patient.dart';

class Record {
  int? id;
  String diagnosis;
  String prescription;
  String? note;
  Doctor? doctor;
  Patient? patient;
  Appointment? appointment;

  Record(
      {this.id,
      required this.diagnosis,
      required this.prescription,
      this.doctor,
      this.patient,
      this.appointment,
      this.note});

  static Record fromJson(Map<String, dynamic> json) => Record(
      id: json["id"],
      diagnosis: json["attributes"]["diagnosis"],
      prescription: json["attributes"]["prescription"],
      doctor: null,
      patient: null,
      appointment:
          Appointment.fromJson(json["attributes"]["appointment"]["data"]));

  static Record fromJsonFlex(Map<String, dynamic> json) => Record(
      id: json["id"],
      diagnosis: json["attributes"]["diagnosis"],
      prescription: json["attributes"]["prescription"],
      doctor: null,
      patient: null,
      appointment: null);
}
