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
    int? imageId;

    await _bookSchedule(appointment.schedule).then((response) {
      Map parse = json.decode(response.body);

      fSchedule = Schedule.fromJson(parse["data"]);
    });

    await uploadImage(appointment.media!).then((response) {
      Map parse = json.decode(response.body)[0];

      imageId = parse["id"];
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
            "gcash_payment": imageId
          }
        }));
  }

  static Future<http.Response> uploadImage(File imageFile) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$apiAddress/api/upload'));
    var imagebytes = await imageFile.readAsBytes();
    List<int> listData = imagebytes.cast();
    request.files.add(http.MultipartFile.fromBytes('files', listData,
        filename: imageFile.path.split('image_picker').last,
        contentType: MediaType.parse('image/jpeg')));

    request.headers.addAll({'Authorization': 'Bearer $_token'});
    var response = await request.send();

    return response.stream
        .toBytes()
        .then((value) => http.Response.bytes(value, response.statusCode));
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
}
