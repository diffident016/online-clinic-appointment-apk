import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:intl/intl.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/widgets/loading_dialog.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';
import 'package:age_calculator/age_calculator.dart';

import '../../widgets/buttons.dart';

class PatientProfile extends StatefulWidget {
  final Patient? patient;
  final VoidCallback getPatientProfile;
  const PatientProfile(
      {Key? key, this.patient, required this.getPatientProfile})
      : super(key: key);

  @override
  PatientProfileState createState() => PatientProfileState();
}

class PatientProfileState extends State<PatientProfile> {
  late List<TextEditingController> textController;

  final _formKey = GlobalKey<FormState>();
  DateTime? birthdate;
  AutovalidateMode autovalidate = AutovalidateMode.disabled;

  String? name;
  String? firstname;
  String? lastname;
  String? midname;
  String? gender;
  String? address;
  String? phone;
  int? age;

  DateDuration? duration;

  String specialChar =
      r'^[^<>{}\"/|;:.,~!?@#$%^=&*\\]\\\\()\\[¿§«»ω⊙¤°℃℉€¥£¢¡®©0-9_+]*$';

  @override
  void initState() {
    super.initState();
    textController = List.generate(7, (i) => TextEditingController());

    checkPatientProfile();
  }

  void checkPatientProfile() {
    if (widget.patient != null) {
      if (mounted) {
        setState(() {
          firstname = widget.patient!.firstname;
          lastname = widget.patient!.lastname;
          midname = widget.patient!.midname;
          gender = widget.patient!.gender;
          address = widget.patient!.address;
          phone = widget.patient!.contactNumber;
          birthdate = widget.patient!.birthday;
          age = widget.patient!.age;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (d != null) {
      duration = AgeCalculator.age(d);

      setState(() {
        birthdate = d;
        textController[4].text = duration!.years.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Patient Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: autovalidate,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 10,
              ),
              inputLabel('First Name'),
              inputField(
                  controller: textController[0],
                  hint: firstname ?? "",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("First name is required");
                    }

                    if (RegExp(specialChar).hasMatch(value)) {
                      return ("Special characters is not allowed.");
                    }

                    return null;
                  },
                  inputType: TextInputType.text),
              inputLabel('Last Name'),
              inputField(
                  controller: textController[1],
                  hint: lastname ?? "",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Last name is required");
                    }

                    if (RegExp(specialChar).hasMatch(value)) {
                      return ("Special characters is not allowed.");
                    }

                    return null;
                  },
                  inputType: TextInputType.text),
              inputLabel('Middle Name'),
              inputField(
                  controller: textController[2],
                  hint: midname ?? "",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Middle name is required");
                    }

                    if (RegExp(specialChar).hasMatch(value)) {
                      return ("Special characters is not allowed.");
                    }

                    return null;
                  },
                  inputType: TextInputType.text),
              inputLabel('Sex'),
              inputField(
                  hint: gender,
                  controller: textController[3],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Sex is required");
                    }

                    return null;
                  },
                  inputType: TextInputType.text),
              Row(
                children: [
                  SizedBox(
                    width: (size.width - 60) / 3,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          inputLabel('Age'),
                          inputField(
                              hint: age == null ? '' : age.toString(),
                              controller: textController[4],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return ("Age is required");
                                }

                                return null;
                              },
                              inputType: TextInputType.number),
                        ]),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            inputLabel('Birthdate'),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Container(
                                height: birthdate == null ? 40 : 42,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.3),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        birthdate == null
                                            ? 'Select Birthdate'
                                            : DateFormat.yMMMMd("en_US")
                                                .format(birthdate!),
                                        style: TextStyle(
                                            color: textColor.withOpacity(0.6)),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        color: textColor.withOpacity(0.6),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
              inputLabel('Complete Address'),
              inputField(
                  hint: address,
                  controller: textController[5],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Address is required");
                    }

                    return null;
                  },
                  inputType: TextInputType.text),
              inputLabel('Phone Number'),
              inputField(
                  hint: phone,
                  controller: textController[6],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Phone number is required");
                    }

                    return null;
                  },
                  inputType: TextInputType.phone),
              const SizedBox(
                height: 30,
              ),
              Buttons(
                label: 'SAVE',
                onClick: () {
                  FocusScope.of(context).unfocus();

                  if (widget.patient != null) {
                    if (textController[0].text.trim().isEmpty &&
                        textController[1].text.trim().isEmpty &&
                        textController[2].text.trim().isEmpty &&
                        textController[3].text.trim().isEmpty &&
                        textController[4].text.trim().isEmpty &&
                        textController[5].text.trim().isEmpty &&
                        textController[6].text.trim().isEmpty &&
                        widget.patient!.birthday == birthdate) {
                      return;
                    }
                  } else if (_formKey.currentState!.validate()) {
                    if (birthdate == null) {
                      ShowInfo.showUpDialog(context,
                          title: "Required Info",
                          message:
                              "Birthdate is required please input your birthdate.",
                          action1: "Okay", btn1: () {
                        Navigator.of(context).pop();
                      });
                      return;
                    }
                  } else {
                    autovalidate = AutovalidateMode.onUserInteraction;
                    return;
                  }

                  final patient = Patient(
                      firstname: textController[0].text.trim().isEmpty
                          ? firstname!
                          : textController[0].text.trim(),
                      lastname: textController[1].text.trim().isEmpty
                          ? lastname!
                          : textController[1].text.trim(),
                      midname: textController[2].text.trim().isEmpty
                          ? midname!
                          : textController[2].text.trim(),
                      gender: textController[3].text.trim().isEmpty
                          ? gender!
                          : textController[3].text.trim(),
                      birthday: birthdate ?? birthdate!,
                      address: textController[5].text.trim().isEmpty
                          ? address!
                          : textController[5].text.trim(),
                      contactNumber: textController[6].text.trim().isEmpty
                          ? phone!
                          : textController[6].text.trim(),
                      account: UserAccount.user!,
                      age: textController[4].text.trim().isEmpty
                          ? age!
                          : int.parse(textController[4].text),
                      id: widget.patient == null ? null : widget.patient!.id);

                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) {
                        return const LoadingDialog(
                            message: 'Saving profile, please wait...');
                      });

                  try {
                    if (widget.patient == null) {
                      Services.setupPatientProfile(patient: patient)
                          .then((response) {
                        Navigator.of(context).pop();

                        Map parsed = json.decode(response.body);

                        if (response.statusCode == 200) {
                          Patient tpatient = Patient.fromJson(parsed["data"]);
                          tpatient.account = UserAccount.user!;
                          Services.savePatientProfile(tpatient);
                          ShowInfo.showToast('Your profile has been saved');
                          widget.getPatientProfile();
                          Navigator.of(context).pop();
                        } else {
                          ShowInfo.showToast(parsed["error"]["message"]);
                        }
                      }).timeout(const Duration(seconds: 15), onTimeout: () {
                        ShowInfo.showToast(
                            'Cannot connect to the server, please try again later.');
                      });
                    } else {
                      Services.updatePatientProfile(patient: patient)
                          .then((response) {
                        Navigator.of(context).pop();

                        Map parsed = json.decode(response.body);

                        if (response.statusCode == 200) {
                          Patient tpatient = Patient.fromJson(parsed["data"]);
                          tpatient.account = UserAccount.user!;
                          Services.savePatientProfile(tpatient);
                          ShowInfo.showToast('Your profile has been save');
                          widget.getPatientProfile();
                          Navigator.of(context).pop();
                        } else {
                          ShowInfo.showToast(parsed["error"]["message"]);
                        }
                      }).timeout(const Duration(seconds: 15), onTimeout: () {
                        ShowInfo.showToast(
                            'Cannot connect to the server, please try again later.');
                      });
                    }
                  } on Exception catch (e) {
                    ShowInfo.showToast(e.toString());
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
            if (widget.patient == null && req!)
              const WidgetSpan(
                  child: Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 15),
              ))
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
