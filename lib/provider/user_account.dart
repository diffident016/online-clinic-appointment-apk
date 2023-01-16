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
  static StreamController<int?> controller = StreamController<int?>();

  static User? user;
  static String? token;

  static bool savePassword = false;

  static _saveUser(String jwt, Map<String, dynamic> myuser, int type) async {
    try {
      user = User.fromJson(myuser);
      token = jwt;
      await storage.write(key: 'jwt', value: jwt);
      await storage.write(key: 'user', value: jsonEncode(myuser));

      if (type == 0) controller.add(1);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  static _rememberUser(UserAuth user) async {
    try {
      await storage.write(key: 'remember', value: jsonEncode(user));
    } on Exception catch (_) {
      null;
    }
  }

  static _removeRememberUser() async {
    try {
      await storage.delete(key: 'remember');
    } on Exception catch (_) {
      null;
    }
  }

  static _removeUser() async {
    try {
      await storage.delete(key: 'jwt');
      await storage.delete(key: 'user');

      if (user!.userType == 'patient') {
        await storage.delete(key: 'patient');
        await storage.delete(key: 'appointment');
      }

      if (user!.userType == 'doctor') {
        await storage.delete(key: 'doctor');
      }
      user = null;
    } on Exception catch (_) {
      null;
    }

    controller.add(0);
  }

  static void _checkUser() async {
    token = await storage.read(key: 'jwt');
    final json = await storage.read(key: 'user');

    if (json != null) {
      user = User.fromJson(jsonDecode(json));
    } else {
      return controller.add(0);
    }

    if (token == null) {
      return controller.add(0);
    }

    if (JwtDecoder.isExpired(token!)) {
      _removeUser();
    } else {
      controller.add(1);
    }
  }

  static Stream<int?> currentUser() {
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
          _saveUser(parsed["jwt"], parsed["user"], 1);
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
          _saveUser(parsed["jwt"], parsed["user"], 0);

          final userAuth = UserAuth(email, password);

          savePassword ? _rememberUser(userAuth) : _removeRememberUser();

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
    controller.add(0);
    return _removeUser();
  }
}

class UserAuth {
  final String email;
  final String password;

  UserAuth(this.email, this.password);

  Map<String, dynamic> toJson() => {'email': email, 'password': password};

  static UserAuth fromJson(Map<String, dynamic> json) =>
      UserAuth(json['email'], json['password']);
}
