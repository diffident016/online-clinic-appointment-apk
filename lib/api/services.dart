import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/doctor.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/models/record.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/utils.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

import '../models/schedule.dart';

class Services {
  static final _token = UserAccount.token;
  static const _storage = FlutterSecureStorage();

  static Future<http.Response> setupPatientProfile(
      {required Patient patient}) async {
    var dateNow = DateTime.now();
    var userId = DateFormat("yyyyMMddHHmmss").format(dateNow);
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
            "firstname": patient.firstname,
            "lastname": patient.lastname,
            "middlename": patient.midname,
            "gender": patient.gender,
            "birthday": Utils.fromDateTimeToJson(patient.birthday),
            "address": patient.address,
            "contact_number": patient.contactNumber,
            "account": patient.account!.id,
            "status": patient.status,
            "age": patient.age,
            "user_id": "P${userId}"
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
            "firstname": patient.firstname,
            "lastname": patient.lastname,
            "middlename": patient.midname,
            "gender": patient.gender,
            "birthday": Utils.fromDateTimeToJson(patient.birthday),
            "address": patient.address,
            "contact_number": patient.contactNumber,
            "account": patient.account!.id,
            "status": patient.status,
            "age": patient.age
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

  static Future saveAppointment(String id) async {
    Appointment? appointment;
    await getAppointment(id).then((value) {
      Map parse = json.decode(value.body);
      appointment = Appointment.fromJson(parse["data"]);
    });

    try {
      return await _storage.write(
          key: 'appointment', value: jsonEncode(appointment!));
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
    int? image;

    await _bookSchedule(appointment.schedule).then((response) {
      Map parse = json.decode(response.body);

      fSchedule = Schedule.fromJson(parse["data"]);
    });

    await uploadImage(appointment.media!).then((response) {
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

  static Future uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
        "POST",
        Uri.parse(
          "$apiAddress/api/upload",
        ));
    var multipartFile = await http.MultipartFile.fromPath(
        'files', imageFile.path,
        filename: imageFile.path.split("image_picker").last,
        contentType: MediaType('image', 'png'));

    request.headers.addAll({
      'Authorization': 'Bearer $_token',
    });

    request.files.add(multipartFile);

    var response = await request.send();

    int id = 0;
    await response.stream.bytesToString().then((value) {
      id = List.from(jsonDecode(value))[0]["id"];
    });

    return id;
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

  static Future<http.Response> getAppointments(String route) async {
    return await http.get(
      Uri.parse(
        "$apiAddress/api/appointments?$route&populate=%2A",
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $_token',
      },
    );
  }

  static Future<http.Response> getAllAppointments() async {
    return await http.get(
      Uri.parse(
        "$apiAddress/api/appointments?populate=%2A",
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

  static Future<http.Response> getRecords(int patientId) async {
    return await http.get(
      Uri.parse(
        "$apiAddress/api/records?filters[patient][id]=$patientId&populate[appointment][populate]=schedule&populate[appointment][populate]=patient",
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $_token',
      },
    );
  }

  static Future<http.Response> getAllRecords() async {
    return await http.get(
      Uri.parse(
        "$apiAddress/api/records",
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $_token',
      },
    );
  }

  static Future<http.Response> addRecord({required Record record}) async {
    return await http.post(
        Uri.parse(
          "$apiAddress/api/records",
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          "data": {
            "diagnosis": record.diagnosis,
            "prescription": record.prescription,
            "note": record.note,
            "doctor": record.doctor!.id,
            "patient": record.patient!.id,
            "appointment": record.appointment!.id,
            "record_date": Utils.fromDateTimeToJson(record.recordDate)
          }
        }));
  }

  static Future<http.Response> getDoctor(int id) async {
    return await http.get(
      Uri.parse(
        "$apiAddress/api/doctors?filters[account][id]=$id&populate=account",
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $_token',
      },
    );
  }

  static saveDoctor(Doctor doctor) async {
    try {
      await _storage.write(key: 'doctor', value: jsonEncode(doctor));
    } on Exception catch (_) {
      return null;
    }
  }
}
