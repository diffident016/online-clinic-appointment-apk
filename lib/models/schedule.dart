import 'package:online_clinic_appointment/utils.dart';

class Schedule {
  int? id;
  DateTime date;
  DateTime time;
  String? comparator;

  Schedule({required this.date, required this.time, this.id, this.comparator});

  static Schedule fromJson(Map<String, dynamic> json) => Schedule(
      id: json['id'],
      date: Utils.toDateTime(json['attributes']['date']),
      time: Utils.toTime(json['attributes']['time']),
      comparator: Utils.combine(
          json['attributes']['date'], json['attributes']['time']));

  static Schedule fromLocalJson(Map<String, dynamic> json) => Schedule(
      id: json['id'],
      date: Utils.toDateTime(json['date']),
      time: Utils.toTime(json['time']),
      comparator: Utils.combine(json['date'], json['time']));

  Map<String, dynamic> toJson() => {
        "date": Utils.fromDateTimeToJson(date),
        "time": Utils.fromTimeToJson(time)
      };
}
