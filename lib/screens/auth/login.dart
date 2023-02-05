import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/widgets/buttons.dart';
import 'package:online_clinic_appointment/widgets/loading_dialog.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool rememberPassword = false;

  late FlutterSecureStorage storage;

  @override
  void initState() {
    super.initState();

    storage = const FlutterSecureStorage();
    getRemember();
  }

  void getRemember() async {
    try {
      final json = await storage.read(key: 'remember');

      if (json != null) {
        final auth = UserAuth.fromJson(jsonDecode(json));
        setState(() {
          _email.text = auth.email;
          _password.text = auth.password;
        });
      }
    } on Exception catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: size.height * 0.22,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Hello!',
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 38),
                  ),
                  Text(
                    'Welcome to ONCASS',
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.55,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      inputLabel('Email Address'),
                      inputField(
                          controller: _email,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Please enter your email");
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please enter a valid email");
                            }
                            return null;
                          },
                          inputType: TextInputType.emailAddress),
                      inputLabel('Password'),
                      inputField(
                          controller: _password,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Please enter your password");
                            }
                            return null;
                          },
                          obscured: true),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 25,
                              height: 24,
                              child: Checkbox(
                                value: rememberPassword,
                                checkColor: Colors.white,
                                activeColor: primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                side: BorderSide(
                                    width: 1,
                                    color: textColor.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2)),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Remember Password?',
                              style: TextStyle(color: textColor, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Buttons(
                        label: 'LOGIN',
                        onClick: () {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) {
                                  return const LoadingDialog(
                                      message: 'Logging in, please wait...');
                                });

                            UserAccount.savePassword = rememberPassword;
                            UserAccount.loginAccount(
                                    email: _email.text.trim(),
                                    password: _password.text.trim())
                                .then((response) => {
                                      Navigator.of(context).pop(),
                                      if (response != true)
                                        {
                                          ShowInfo.showToast(
                                              response.toString())
                                        }
                                    });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const WidgetSpan(
                                child: Text(
                                  "Doesn't have an account?",
                                  style:
                                      TextStyle(color: textColor, fontSize: 13),
                                ),
                              ),
                              const WidgetSpan(
                                child: SizedBox(width: 5),
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    UserAccount.controller.add(2);
                                  },
                                  child: const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                        color: textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                height: size.height * 0.18,
                width: double.infinity,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Text(
                      'Address: Purok 2 North Poblacion, 8714 Maramag\nCategories: Medical Clinic',
                      style: TextStyle(color: textColor, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        label,
        style: const TextStyle(color: textColor, fontSize: 16),
      ),
    );
  }

  TextFormField inputField(
      {required TextEditingController controller,
      TextInputType? inputType,
      bool? obscured = false,
      required String? Function(String?)? validator}) {
    return TextFormField(
        autofocus: false,
        controller: controller,
        obscureText: obscured!,
        validator: validator,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10)),
        ));
  }
}
