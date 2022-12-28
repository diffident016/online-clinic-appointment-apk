import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  const LoadingDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: primaryColor,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                message,
                style: const TextStyle(fontFamily: 'Poppins'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
