import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const primaryColor = Color(0XFF2196F3);
const textColor = Color(0XFF121212);
const backgroundColor = Colors.white;
const unavailableSlot = Color(0XFFf8cecc);
final availableSlot = primaryColor.withOpacity(0.5);
final borderColor = textColor.withOpacity(0.2);
final iconColor = textColor.withOpacity(0.5);

const appBarTheme = AppBarTheme(
  backgroundColor: Color(0XFFF1F1F1),
  elevation: 0,
);

List<String> _time = [
  "01:00 PM",
  "01:30 PM",
  "02:00 PM",
  "02:30 PM",
  "03:00 PM",
  "03:30 PM",
  "04:00 PM",
  "04:30 PM",
  "05:00 PM",
  "05:30 PM",
  "06:00 PM"
];

final List<DateTime> schedTime =
    List.generate(_time.length, (i) => DateFormat("hh:mm a").parse(_time[i]));

const List<String> notAllowedDay = ['Sun'];

const String gCashName = 'Mark Zuckerberg';
const String gCashPhone = '09000000000';
