import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/screens/auth/login.dart';
import 'package:online_clinic_appointment/user_select.dart';
import 'package:online_clinic_appointment/widgets/buttons.dart';
import 'package:online_clinic_appointment/widgets/loading_dialog.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _cpassword = TextEditingController();

  void signUp() {
    FocusScope.of(context).unfocus();
    try {
      UserAccount.createAccount(
              name: _name.text.trim(),
              email: _email.text.toLowerCase().trim(),
              password: _password.text.trim())
          .then((response) => {
                Navigator.of(context).pop(),
                if (response == true)
                  {
                    ShowInfo.showUpDialog(context,
                        title: 'Sign-Up Successful',
                        message:
                            'Account has been registered successfully, please login your account.',
                        action1: 'Login', btn1: () {
                      Navigator.of(context).pop();
                      UserAccount.logout();
                    })
                  }
                else
                  {ShowInfo.showToast(response)}
              });
    } on Exception catch (e) {
      Navigator.of(context).pop();
      ShowInfo.showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
          backgroundColor: backgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.20,
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
                        'Create an ONCASS account',
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        // inputLabel('Full Name'),
                        // inputField(
                        //     controller: _name,
                        //     validator: (value) {
                        //       if (value!.isEmpty) {
                        //         return ("Full name is required");
                        //       }

                        //       return null;
                        //     },
                        //     inputType: TextInputType.text),
                        inputLabel('Email Address'),
                        inputField(
                            controller: _email,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return ("Email is required");
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
                                return ("Password is required");
                              }
                              return null;
                            },
                            obscured: true),
                        inputLabel('Confirm Password'),
                        inputField(
                            controller: _cpassword,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return ("Please re-type your password");
                              }

                              if (value != _password.text) {
                                return ("Password does not match");
                              }
                              return null;
                            },
                            obscured: true),
                        const SizedBox(height: 30),
                        Buttons(
                            label: 'SIGN UP',
                            onClick: () {
                              if (_formKey.currentState!.validate()) {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) {
                                      return const LoadingDialog(
                                          message:
                                              'Creating account, please wait...');
                                    });

                                signUp();
                              }
                            }),
                        const SizedBox(height: 20),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const WidgetSpan(
                                  child: Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                        color: textColor, fontSize: 13),
                                  ),
                                ),
                                const WidgetSpan(
                                  child: SizedBox(width: 5),
                                ),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      UserAccount.controller.add(0);
                                    },
                                    child: const Text('LOGIN',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        )),
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
                const SizedBox(height: 50),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Center(
                    child: Text(
                      'Address: Purok 2 North Poblacion, 8714 Maramag\nCategories: Medical Clinic',
                      style: TextStyle(color: textColor, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
