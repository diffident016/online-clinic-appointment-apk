import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_clinic_appointment/constant.dart';

class ShowInfo {
  static showToast(String message, {int? seconds}) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: seconds ?? 0,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 14);
  }

  static Future showUpDialog(BuildContext context,
      {required String title,
      required String message,
      required String action1,
      String? action2 = '',
      required VoidCallback btn1,
      VoidCallback? btn2}) {
    Widget button1 = TextButton(
      onPressed: () {
        btn1();
      },
      child: Text(action1,
          style:
              const TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );

    Widget button2 = action2!.isNotEmpty
        ? TextButton(
            onPressed: btn2!,
            child: Text(action2,
                style: const TextStyle(
                    color: textColor, fontWeight: FontWeight.bold)),
          )
        : Container();

    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 15),
      ),
      actions: action2.isNotEmpty ? [button1, button2] : [button1],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static Future showErrorDialog(BuildContext context,
      {required String title,
      required String message,
      required String action1,
      String? action2 = '',
      required VoidCallback btn1,
      VoidCallback? btn2}) {
    Widget button1 = TextButton(
      onPressed: () {
        btn1();
      },
      child: Text(action1,
          style:
              const TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );

    Widget button2 = action2!.isNotEmpty
        ? TextButton(
            onPressed: btn2!,
            child: Text(action2,
                style: const TextStyle(
                    color: textColor, fontWeight: FontWeight.bold)),
          )
        : Container();

    AlertDialog alert = AlertDialog(
      title: RichText(
        text: TextSpan(
          children: [
            const WidgetSpan(
                child: Icon(
              Icons.cancel,
              color: Colors.red,
              size: 26,
            )),
            const WidgetSpan(
              child: SizedBox(width: 5),
            ),
            WidgetSpan(
              child: Text(
                title,
                style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      actions: action2.isNotEmpty ? [button1, button2] : [button1],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static Future showSuccessDialog(BuildContext context,
      {required String title,
      required String message,
      required String action1,
      String? action2 = '',
      required VoidCallback btn1,
      VoidCallback? btn2}) {
    Widget button1 = TextButton(
      onPressed: () {
        btn1();
      },
      child: Text(action1,
          style:
              const TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );

    Widget button2 = action2!.isNotEmpty
        ? TextButton(
            onPressed: btn2!,
            child: Text(action2,
                style: const TextStyle(
                    color: textColor, fontWeight: FontWeight.bold)),
          )
        : Container();

    AlertDialog alert = AlertDialog(
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
                title,
                style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      actions: action2.isNotEmpty ? [button1, button2] : [button1],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
