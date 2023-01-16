import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:online_clinic_appointment/utils.dart';

class ChatBotApi {
  static Future<http.Response> sendMessage(String message) async {
    return await http.post(
        Uri.parse(
          "$hostAddress/predict",
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode({"message": message}));
  }
}
