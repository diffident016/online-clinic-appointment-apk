import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/doctor.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/utils.dart';

class Record {
  int? id;
  String diagnosis;
  String prescription;
  String? note;
  Doctor? doctor;
  Patient? patient;
  Appointment? appointment;
  DateTime recordDate;

  Record(
      {this.id,
      required this.diagnosis,
      required this.prescription,
      required this.recordDate,
      this.doctor,
      this.patient,
      this.appointment,
      this.note});

  static Record fromJson(Map<String, dynamic> json) => Record(
      id: json["id"],
      diagnosis: json["attributes"]["diagnosis"],
      prescription: json["attributes"]["prescription"],
      recordDate: Utils.toDateTime(json["attributes"]["record_date"]),
      doctor: null,
      patient: null,
      appointment:
          Appointment.fromJson(json["attributes"]["appointment"]["data"]));

  static Record fromJsonFlex(Map<String, dynamic> json) => Record(
      id: json["id"],
      diagnosis: json["attributes"]["diagnosis"],
      prescription: json["attributes"]["prescription"],
      recordDate: Utils.toDateTime(json["attributes"]["record_date"]),
      doctor: null,
      patient: null,
      appointment: null);
}
