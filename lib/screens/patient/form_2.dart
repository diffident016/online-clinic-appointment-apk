import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/schedule.dart';
import 'package:online_clinic_appointment/widgets/buttons.dart';
import 'package:online_clinic_appointment/widgets/loading_dialog.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';

class Form2 extends StatefulWidget {
  final Function(int index) updateIndex;
  final Appointment Function() getAppointment;
  final Future Function() finalSchedCheck;
  final VoidCallback checkAvailableSlot;
  const Form2(
      {Key? key,
      required this.updateIndex,
      required this.getAppointment,
      required this.finalSchedCheck,
      required this.checkAvailableSlot})
      : super(key: key);

  @override
  Form2State createState() => Form2State();
}

class Form2State extends State<Form2> {
  final ImagePicker _picker = ImagePicker();
  File? pickedImage;

  List<Schedule>? schedules;
  Appointment? appoinment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'PAYMENT METHOD',
            style: TextStyle(
                color: primaryColor.withOpacity(0.8),
                fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Text(
                      'GCASH ONLY  ',
                      style: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Image.asset(
                        "assets/images/gcash_logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Text(
                              'Name:',
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const WidgetSpan(
                            child: SizedBox(width: 5),
                          ),
                          WidgetSpan(
                            child: Text(
                              gCashName,
                              style: TextStyle(
                                  color: textColor.withOpacity(0.8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Text(
                              'Gcash No.:',
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const WidgetSpan(
                            child: SizedBox(width: 5),
                          ),
                          WidgetSpan(
                            child: Text(
                              gCashPhone,
                              style: TextStyle(
                                  color: textColor.withOpacity(0.8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'PROOF OF PAYMENT',
            style: TextStyle(
                color: primaryColor.withOpacity(0.8),
                fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: ((builder) => bottomSheet()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: pickedImage != null
                      ? Column(
                          children: [
                            Icon(
                              Icons.photo,
                              color: textColor.withOpacity(0.5),
                              size: 45,
                            ),
                            SizedBox(
                              height: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    pickedImage!.path
                                        .split("image_picker")
                                        .last,
                                    style: TextStyle(
                                        color: textColor.withOpacity(0.5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pickedImage = null;
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: iconColor,
                                      ))
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              color: textColor.withOpacity(0.5),
                              size: 48,
                            ),
                            Text(
                              'Choose an image',
                              style: TextStyle(
                                  color: textColor.withOpacity(0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Buttons(
              type: 1,
              label: "SUBMIT APPOINTMENT",
              color: pickedImage != null ? primaryColor : availableSlot,
              textColor: Colors.white,
              onClick: () {
                FocusScope.of(context).unfocus();

                if (pickedImage != null) {
                  ShowInfo.showToast(
                      "Checking your appoinment schedule, please wait...");
                  widget.finalSchedCheck().then((value) {
                    if (value) {
                      appoinment = widget.getAppointment();

                      appoinment!.media = pickedImage!;
                      appoinment!.payment = true;

                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) {
                            return const LoadingDialog(
                                message: 'Booking appoinment, please wait...');
                          });

                      Services.bookAppointment(appoinment!).then((value) {
                        if (value.statusCode == 200) {
                          Map parse = jsonDecode(value.body);

                          Services.saveAppointment(parse["data"]["id"]);
                          Navigator.of(context).pop();
                          ShowInfo.showToast("Appointment booking successful");
                        } else {
                          Navigator.of(context).pop();
                          ShowInfo.showToast("Appointment booking failed");
                        }

                        Navigator.of(context).pop();
                      });
                    } else {
                      widget.checkAvailableSlot();
                      ShowInfo.showUpDialog(context,
                          title: "Unavailable Schedule",
                          message:
                              "Unfortunately, your schedule is not available anymore, please choose another date or time.",
                          action1: "Okay", btn1: () {
                        Navigator.of(context).pop();
                        widget.updateIndex(0);
                      });
                    }
                  });
                }
              },
            ),
          ),
          Buttons(
              label: "CANCEL APPOINTMENT",
              type: 2,
              onClick: () {
                ShowInfo.showUpDialog(context,
                    title: "Cancel Appointment",
                    message: "Are you sure you want to cancel you appointment?",
                    action1: "Yes",
                    btn1: () {
                      Navigator.of(context).pop();
                      ShowInfo.showToast("Appointment has been cancelled");
                      Navigator.of(context).pop();
                    },
                    action2: "No",
                    btn2: () {
                      Navigator.of(context).pop();
                    });
              })
        ]),
      ),
    );
  }

  Future pickImages(ImageSource source) async {
    try {
      if (source.name == 'gallery') {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            pickedImage = File(image.path);
          });
        }
      }
    } on Exception catch (e) {
      ShowInfo.showToast(e.toString());
    }

    if (pickedImage == null) return;
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose an image from",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera, color: iconColor),
              onPressed: () {
                Navigator.pop(context);
                pickImages(ImageSource.camera);
              },
              label: const Text("Camera", style: TextStyle(color: textColor)),
            ),
            const SizedBox(
              width: 20,
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: iconColor),
              onPressed: () {
                Navigator.pop(context);
                pickImages(ImageSource.gallery);
              },
              label: const Text("Gallery", style: TextStyle(color: textColor)),
            ),
          ])
        ],
      ),
    );
  }
}
