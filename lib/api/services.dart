import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

import '../models/schedule.dart';

class Services {
  static final _token = UserAccount.token;
  static const _storage = FlutterSecureStorage();

  static Future<http.Response> setupPatientProfile(
      {required Patient patient}) async {
    return await http.post(
        Uri.parse(
          "$apiAddress/api/patients?deeply=true",
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          "data": {
            "name": patient.name,
            "gender": patient.gender,
            "birthday": Utils.fromDateTimeToJson(patient.birthday),
            "address": patient.address,
            "contact_number": patient.contactNumber,
            "account": patient.account!.id,
            "status": patient.status
          }
        }));
  }

  static Future<http.Response> updatePatientProfile(
      {required Patient patient}) async {
    return await http.put(
        Uri.parse(
          "$apiAddress/api/patients/${patient.id}",
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          "data": {
            "name": patient.name,
            "gender": patient.gender,
            "birthday": Utils.fromDateTimeToJson(patient.birthday),
            "address": patient.address,
            "contact_number": patient.contactNumber,
            "account": patient.account!.id,
            "status": patient.status
          }
        }));
  }

  static savePatientProfile(Patient patient) async {
    try {
      await _storage.write(key: 'patient', value: jsonEncode(patient));
    } on Exception catch (_) {
      return null;
    }
  }

  static Future<http.Response> getPatientProfile() async {
    final String route = 'filters[account][email]=${UserAccount.user!.email}';

    return await http.get(
      Uri.parse(
        "$apiAddress/api/patients?$route&populate=%2A",
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $_token',
      },
    );
  }

  static saveAppointment(String id) async {
    Appointment? appointment;
    await getAppointment(id).then((value) {
      Map parse = json.decode(value.body);
      appointment = Appointment.fromJson(parse["data"]);
    });

    try {
      await _storage.write(key: 'appointment', value: jsonEncode(appointment!));
    } on Exception catch (_) {
      return null;
    }
  }

  static saveIllnesses(List<String> illnesses) async {
    try {
      await _storage.write(key: 'illnesses', value: jsonEncode(illnesses));
    } on Exception catch (_) {
      return null;
    }
  }

  static Future<http.Response> _bookSchedule(Schedule schedule) async {
    return await http.post(
        Uri.parse(
          "$apiAddress/api/schedules",
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({"data": schedule.toJson()}));
  }

  static Future<http.Response> getAppointment(String id) async {
    return await http.get(
        Uri.parse(
          "$apiAddress/api/appointments/$id?populate=patient&populate=schedule",
        ),
        headers: <String, String>{
          'Authorization': 'Bearer $_token',
        });
  }

  static Future<http.Response> bookAppointment(Appointment appointment) async {
    Schedule? fSchedule;
    String? image;

    await _bookSchedule(appointment.schedule).then((response) {
      Map parse = json.decode(response.body);

      fSchedule = Schedule.fromJson(parse["data"]);
    });

    await convertToBase64(appointment.media!).then((response) {
      image = response;
    });

    return await http.post(
        Uri.parse(
          "$apiAddress/api/appointments",
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          "data": {
            "app_code": appointment.app_code,
            "schedule": fSchedule!.id,
            "patient": appointment.patient.id,
            "payment": appointment.payment,
            "remarks": appointment.remarks,
            "gcash_payment": image,
            "illness": appointment.illness,
            "status": appointment.status
          }
        }));
  }

  static Future convertToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();

    return base64Encode(imageBytes);
  }

  static Future<http.Response> getSchedules() async {
    return await http.get(
      Uri.parse(
        "$apiAddress/api/schedules",
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $_token',
      },
    );
  }

  static Future<http.Response> getIllnesses() async {
    return await http.get(
      Uri.parse(
        "$apiAddress/api/illnesses",
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $_token',
      },
    );
  }

  static Future<http.Response> getAppoinments(String route) async {
    return await http.get(
      Uri.parse(
        "$apiAddress/api/appointments?$route&populate=%2A",
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $_token',
      },
    );
  }

  static Future<http.Response> updateAppointmentStatus(int id) async {
    return await http.put(
        Uri.parse(
          "$apiAddress/api/appointments/$id",
        ),
        headers: <String, String>{
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "data": {"status": true}
        }));
  }
}
