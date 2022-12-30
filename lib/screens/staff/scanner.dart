import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/widgets/loading_dialog.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  ScannerState createState() => ScannerState();
}

class ScannerState extends State<Scanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool camera = true;
  bool scanning = false;
  Appointment? appointment;

  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void pauseScanner() {
    controller!.pauseCamera();
    setState(() {
      camera = false;
    });
  }

  void resumeScanner() {
    controller!.resumeCamera();
    setState(() {
      camera = true;
    });
  }

  void updateStatus() {
    try {
      Services.updateAppointmentStatus(appointment!.id!).then((value) {
        Navigator.of(context).pop();
        if (value.statusCode == 200) {
          ShowInfo.showToast(
              'Appointment status has been successfully updated.');
        } else {
          ShowInfo.showToast('Update failed.');
        }
      });
    } on Exception catch (_) {
      Navigator.of(context).pop();
      ShowInfo.showToast("An error occurred, try again later.");
    }

    setState(() {
      scanning = false;
    });
  }

  void getAppointment() {
    final String route = 'filters[app_code]=${result!.code.toString()}';

    appointment = null;

    try {
      Services.getAppoinments(route).then((value) {
        Navigator.of(context).pop();
        if (value.statusCode == 200) {
          Map parse = json.decode(value.body);

          if (List.from(parse["data"]).isEmpty) {
            ShowInfo.showErrorDialog(context,
                title: 'Invalid ID',
                message: 'The scanned id was invalid, appointment not found.',
                action1: 'Okay', btn1: () {
              Navigator.of(context).pop();
            });

            setState(() {
              scanning = false;
            });

            return null;
          }

          appointment = Appointment.fromJson(List.from(parse["data"])[0]);

          if (appointment != null) {
            appointment!.status!
                ? ShowInfo.showSuccessDialog(context,
                    title: 'Appointment Status',
                    message: 'This appointment is already marked as done.',
                    action1: "Okay", btn1: () {
                    Navigator.of(context).pop();
                  })
                : showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return qrScanned(appointment!);
                    },
                  );
          }
        } else {
          return ShowInfo.showErrorDialog(context,
              title: 'Server Error',
              message: 'A server error occurred, please try again later.',
              action1: 'Okay', btn1: () {
            Navigator.of(context).pop();
          });
        }

        setState(() {
          scanning = false;
        });
      });
    } on Exception catch (_) {
      Navigator.of(context).pop();
      setState(() {
        scanning = false;
      });

      ShowInfo.showErrorDialog(context,
          title: 'Error',
          message: 'An error occurred, please try again later.',
          action1: 'Okay', btn1: () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return VisibilityDetector(
      key: const Key('scanner-screen'),
      onVisibilityChanged: (info) {
        if ((info.visibleFraction * 100) != 100) {
          pauseScanner();
        }
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(child: _buildQrView(context)),
            Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    GestureDetector(
                      onTap: () {
                        if (!scanning) {
                          setState(() {
                            controller!.toggleFlash();
                          });
                        }
                      },
                      child: SizedBox(
                        width: size.width / 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data == true
                                      ? const Icon(
                                          Icons.flash_on_rounded,
                                          color: primaryColor,
                                          size: 26,
                                        )
                                      : const Icon(
                                          Icons.flash_off_rounded,
                                          size: 26,
                                        );
                                } else {
                                  return const Icon(
                                    Icons.flash_off_rounded,
                                    size: 26,
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Flash',
                              style: TextStyle(color: textColor, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!scanning) {
                          camera ? pauseScanner() : resumeScanner();
                        }
                      },
                      child: SizedBox(
                        width: size.width / 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                alignment: Alignment.center,
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle),
                                child: Icon(
                                  camera
                                      ? Icons.stop
                                      : Icons.qr_code_scanner_rounded,
                                  color: Colors.white,
                                  size: 28,
                                )),
                            const SizedBox(height: 5),
                            Text(
                              camera ? 'Stop' : 'Scan',
                              style: const TextStyle(
                                  color: textColor, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!scanning) {
                          setState(() {
                            controller!.flipCamera();
                            camera = true;
                          });
                        }
                      },
                      child: SizedBox(
                        width: size.width / 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return describeEnum(snapshot.data!) == 'back'
                                      ? const Icon(
                                          Icons.cameraswitch_rounded,
                                          size: 26,
                                        )
                                      : const Icon(
                                          Icons.cameraswitch_rounded,
                                          color: primaryColor,
                                          size: 26,
                                        );
                                } else {
                                  return const Icon(
                                    Icons.cameraswitch_rounded,
                                    size: 26,
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Camera',
                              style: TextStyle(color: textColor, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    )
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 350.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 5,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;

      pauseScanner();
    });
    controller.scannedDataStream.listen((scanData) {
      pauseScanner();

      result = scanData;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const LoadingDialog(
            message: 'Checking appointment, please wait...',
          );
        },
      );

      setState(() {
        scanning = true;
      });

      getAppointment();
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  AlertDialog qrScanned(Appointment appointment) {
    return AlertDialog(
      title: RichText(
        text: TextSpan(
          children: [
            const WidgetSpan(
                child: Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 26,
            )),
            const WidgetSpan(
              child: SizedBox(width: 5),
            ),
            WidgetSpan(
              child: Text(
                'Appointment Scanned',
                style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                      child: Text(
                    'Appointment ID:',
                    style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  )),
                  const WidgetSpan(
                    child: SizedBox(width: 5),
                  ),
                  WidgetSpan(
                    child: Text(
                      appointment.app_code,
                      style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
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
                    'Patient:',
                    style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  )),
                  const WidgetSpan(
                    child: SizedBox(width: 5),
                  ),
                  WidgetSpan(
                    child: Text(
                      appointment.patient.name,
                      style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                      child: Text(
                    'Mark this appointment as',
                    style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  )),
                  const WidgetSpan(
                    child: SizedBox(width: 5),
                  ),
                  WidgetSpan(
                    child: Text(
                      'DONE',
                      style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  WidgetSpan(
                    child: Text(
                      '?',
                      style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
          ]),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const LoadingDialog(
                  message: 'Updating status, please wait...',
                );
              },
            );

            updateStatus();
          },
          child: const Text('Yes',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        )
      ],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );
  }
}
