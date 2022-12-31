import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppoinmentDetails extends StatefulWidget {
  final Appointment appointment;
  const AppoinmentDetails({Key? key, required this.appointment})
      : super(key: key);

  @override
  _AppoinmentDetailsState createState() => _AppoinmentDetailsState();
}

class _AppoinmentDetailsState extends State<AppoinmentDetails> {
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
          'Appointment Details',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel("Appointment Id"),
                  buildValue(widget.appointment.app_code),
                  buildLabel("Patient's Name"),
                  buildValue(widget.appointment.patient.name),
                  buildLabel("Appointment Date"),
                  buildValue(
                      Utils.displayDate(widget.appointment.schedule.date)),
                  buildLabel("Appointment Time"),
                  buildValue(
                      Utils.displayTime(widget.appointment.schedule.time)),
                  buildLabel("Illness"),
                  buildValue(widget.appointment.illness!),
                  buildLabel("Reason for visit"),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: SingleChildScrollView(
                          child: Text(
                            widget.appointment.remarks,
                            style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            buildLabel("Appointment QR Code"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: SizedBox(
                height: 150,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child: QrImage(
                              data: widget.appointment.app_code,
                              version: QrVersions.auto,
                              size: 145,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Note:",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                                "Secure a clear copy (ex.: screenshot) of your QRCode and present it during your appointed schedule.",
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget buildValue(String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
      child: Text(
        value,
        style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  Text buildLabel(String label) {
    return Text(
      '${label.toUpperCase()}:',
      style: TextStyle(
          color: primaryColor.withOpacity(0.8), fontWeight: FontWeight.w500),
    );
  }
}
