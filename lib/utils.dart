import 'package:intl/intl.dart';

class Utils {
  static DateTime toDateTime(String timestamp) {
    return DateFormat("yyyy-MM-dd").parse(timestamp);
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    return date.toIso8601String();
  }

  static DateTime toTime(String timestamp) {
    return DateFormat.Hms().parse(timestamp);
  }

  static dynamic fromTimeToJson(DateTime time) {
    return DateFormat("HH:mm:ss.SSS").format(time);
  }

  static String combine(String date, String time) {
    return DateFormat("yyyy-MM-dd")
            .format(DateFormat("yyyy-MM-dd").parse(date)) +
        DateFormat.Hms().format(DateFormat.Hms().parse(time));
  }

  static String displayDate(DateTime date) {
    return DateFormat("MM/dd/yyyy - EEEE").format(date);
  }

  static String displayTime(DateTime time) {
    return DateFormat("hh:mm a").format(time);
  }
}

// const String apiAddress =
//     'https://online-clinic-appointment-production.up.railway.app';
const String apiAddress = 'http://10.0.2.2:1337';
const String hostAddress =
    'https://online-clinic-appointment-chatbot.onrender.com';
