import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';

class Buttons extends StatelessWidget {
  final int? type;
  final String label;
  final VoidCallback onClick;
  final Color? color;
  final Color? textColor;

  const Buttons(
      {Key? key,
      this.type = 0,
      required this.label,
      required this.onClick,
      this.color,
      this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (type! == 1) {
      return btnType1();
    } else if (type! == 2) {
      return btnType2();
    } else {
      return btnType0();
    }
  }

  Widget btnType0() {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: primaryColor),
        child: Center(
            child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        )),
      ),
    );
  }

  Widget btnType1() {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: color),
        child: Center(
            child: Text(
          label,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        )),
      ),
    );
  }

  Widget btnType2() {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryColor)),
        child: Center(
            child: Text(
          label,
          style: const TextStyle(
              color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
        )),
      ),
    );
  }
}
