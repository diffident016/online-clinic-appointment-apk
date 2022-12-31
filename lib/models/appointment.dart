import 'dart:io';

import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/models/schedule.dart';

class Appointment {
  int? id;
  String app_code;
  Schedule schedule;
  Patient patient;
  bool payment;
  String remarks;
  File? media;
  String? illness;
  bool? status;

  Appointment(
      {required this.app_code,
      required this.schedule,
      required this.patient,
      this.payment = false,
      required this.remarks,
      this.media,
      this.id,
      this.illness,
      this.status = false});

  static Appointment fromJson(Map<String, dynamic> json) => Appointment(
      id: json['id'],
      app_code: json['attributes']['app_code'],
      schedule: Schedule.fromJson(json['attributes']['schedule']['data']),
      patient: Patient.fromJson(json['attributes']['patient']['data']),
      payment: json['attributes']['payment'],
      remarks: json['attributes']['remarks'],
      illness: json['attributes']['illness'] ?? 'Not specified',
      status: json['attributes']['status']);

  static Appointment fromLocalJson(Map<String, dynamic> json) => Appointment(
      id: json['id'],
      app_code: json['app_code'],
      schedule: Schedule.fromLocalJson(json['schedule']),
      patient: Patient.fromLocalJson(json['patient']),
      payment: json['payment'],
      remarks: json['remarks'],
      illness: json['illness'] ?? 'Not specified',
      status: json['status']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'app_code': app_code,
        'schedule': schedule.toJson(),
        'patient': patient.toJson(),
        'payment': payment,
        'remarks': remarks,
        'illness': illness,
        'status': status
      };
}
