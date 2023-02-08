import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/widgets/buttons.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

import '../../widgets/loading_dialog.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _cPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back,
              size: 22,
              color: Colors.white,
            )),
        automaticallyImplyLeading: false,
        title: const Text(
          'Update Password',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 80,
              ),
              inputLabel("Current Password"),
              inputField(
                  controller: _currentPassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Please enter current password");
                    }
                    return null;
                  },
                  obscured: true),
              inputLabel("New Password"),
              inputField(
                  controller: _newPassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Please enter new password");
                    }
                    return null;
                  },
                  obscured: true),
              inputLabel("Confirm New Password"),
              inputField(
                  controller: _cPassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Please confirm your new password");
                    }

                    if (value != _newPassword.text) {
                      return ("Password does not match");
                    }
                    return null;
                  },
                  obscured: true),
              const SizedBox(
                height: 20,
              ),
              Buttons(
                label: 'UPDATE PASSWORD',
                onClick: () {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus();
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) {
                          return const LoadingDialog(
                              message: 'Updating password, please wait...');
                        });

                    UserAccount.updatePassword(
                            currentPassword: _currentPassword.text.trim(),
                            newPassword: _newPassword.text.trim(),
                            confirmPass: _cPassword.text.trim())
                        .then((response) {
                      Navigator.of(context).pop();

                      Map parsed = json.decode(response.body);

                      if (response.statusCode == 200) {
                        ShowInfo.showUpDialog(context,
                            title: 'Password Updated',
                            message:
                                'Your password has been updated successfully, please login again.',
                            action1: 'Okay', btn1: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          UserAccount.logout();
                        });
                      } else {
                        ShowInfo.showToast(parsed["error"]["message"]);
                      }
                    });
                  }
                },
              )
            ]),
          ),
        ),
      ),
    );
  }

  Widget inputLabel(String label, {bool? req = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Text(
                label,
                style: const TextStyle(color: textColor, fontSize: 16),
              ),
            ),
            const WidgetSpan(
              child: SizedBox(width: 2),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField inputField(
      {required TextEditingController controller,
      TextInputType? inputType,
      bool? obscured = false,
      String? hint,
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
          hintText: hint,
          hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
          contentPadding: const EdgeInsets.fromLTRB(15, 8, 8, 10),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10)),
        ));
  }
}
