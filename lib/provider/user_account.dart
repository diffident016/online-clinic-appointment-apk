import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:online_clinic_appointment/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

import '../utils.dart';

class UserAccount extends ChangeNotifier {
  static const storage = FlutterSecureStorage();
  static StreamController<bool?> controller = StreamController<bool?>();

  static User? user;
  static String? token;

  static _saveUser(String jwt, Map<String, dynamic> myuser) async {
    try {
      user = User.fromJson(myuser);
      token = jwt;
      await storage.write(key: 'jwt', value: jwt);
      await storage.write(key: 'user', value: jsonEncode(myuser));

      controller.add(true);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  static _removeUser() async {
    try {
      await storage.delete(key: 'jwt');
      await storage.delete(key: 'user');
      await storage.delete(key: 'patient');
      await storage.delete(key: 'appointment');
    } on Exception catch (_) {
      null;
    }

    controller.add(false);
  }

  static void _checkUser() async {
    token = await storage.read(key: 'jwt');
    final json = await storage.read(key: 'user');

    if (json != null) {
      user = User.fromJson(jsonDecode(json));
    } else {
      return controller.add(false);
    }

    if (token == null) {
      return controller.add(false);
    }

    if (JwtDecoder.isExpired(token!)) {
      _removeUser();
    } else {
      controller.add(true);
    }
  }

  static Stream<bool?> currentUser() {
    _checkUser();
    return controller.stream;
  }

  static Future createAccount(
      {required String name,
      required String email,
      required String password}) async {
    Map parsed;
    try {
      return await http.post(
          Uri.parse(
            "$apiAddress/api/auth/local/register",
          ),
          headers: <String, String>{
            'Context-Type': 'application/json; charset=UTF-8',
          },
          body: {
            'username': name,
            'email': email,
            'password': password,
          }).then((response) {
        parsed = json.decode(response.body);
        if (response.statusCode == 200) {
          _saveUser(parsed["jwt"], parsed["user"]);
          return true;
        } else {
          return parsed["error"]["message"];
        }
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        return 'Cannot connect to the server, please try again later.';
      });
    } on Exception catch (_) {
      return null;
    }
  }

  static Future loginAccount(
      {required String email, required String password}) async {
    Map parsed;
    try {
      return await http.post(
          Uri.parse(
            "$apiAddress/api/auth/local",
          ),
          headers: <String, String>{
            'Context-Type': 'application/json; charset=UTF-8',
          },
          body: {
            'identifier': email,
            'password': password,
          }).then((response) {
        parsed = json.decode(response.body);
        if (response.statusCode == 200) {
          _saveUser(parsed["jwt"], parsed["user"]);

          return true;
        } else {
          return parsed["error"]["message"];
        }
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        return 'Cannot connect to the server, please try again later.';
      });
    } on Exception catch (e) {
      return ShowInfo.showToast(e.toString());
    }
  }

  static Future logout() async {
    return _removeUser();
  }
}
