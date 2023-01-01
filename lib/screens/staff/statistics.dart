import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/record.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:collection/collection.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  StatisticsState createState() => StatisticsState();
}

class StatisticsState extends State<Statistics> {
  DateTime mostRecentWeekday(DateTime date, int weekday) =>
      DateTime(date.year, date.month, date.day - (date.weekday - weekday) % 14);

  List<Appointment> appointments = [];
  List<Record> records = [];

  List<_PatientsData> data1 = [];
  List<_DiagnosisData> data2 = [];

  List<String> lastWeek() {
    final DateTime monday = DateTime.now();

    return List.generate(
        14,
        (i) => DateFormat("yyyy-MM-dd")
            .format(monday.subtract(Duration(days: i))));
  }

  void getChart2Data() {
    Services.getAllRecords().then((value) {
      if (value.statusCode == 200) {
        Map parse = jsonDecode(value.body);

        records = List.from(parse["data"])
            .map((e) => Record.fromJsonFlex(e))
            .toList();

        final newGroup =
            groupBy(records, ((Record rec) => rec.diagnosis)).entries.toList();

        List<_DiagnosisData> temp = [];
        data2.clear();

        for (var rec in newGroup) {
          temp.add(_DiagnosisData(rec.key, rec.value.length));
        }

        setState(() {
          data2 = temp;
        });
      }
    });
  }

  void getChart1Data() {
    final range = lastWeek();

    String req = "";

    for (int i = 0; i < range.length; i++) {
      req += "filters[schedule][date][\$eq]=${range[i]}";

      if (i < range.length - 1) req += '&';
    }

    Services.getAppointments(req).then((value) {
      if (value.statusCode == 200) {
        Map parse = jsonDecode(value.body);

        appointments = List.from(parse["data"])
            .map((e) => Appointment.fromJson(e))
            .toList();

        final newGroup =
            groupBy(appointments, ((Appointment ap) => ap.schedule.date))
                .entries
                .toList();

        List<_PatientsData> temp = [];
        data1.clear();

        for (var app in newGroup) {
          temp.add(_PatientsData(
              DateFormat("MM/dd/yyyy").format(app.key), app.value.length));
        }

        setState(() {
          data1 = temp;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getChart1Data();
    getChart2Data();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: VisibilityDetector(
        key: const Key('stats-screen'),
        onVisibilityChanged: (info) {
          if ((info.visibleFraction * 100) == 100) {
            getChart1Data();
            getChart2Data();
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: buildChart1(data1),
                ),
                SizedBox(
                  height: 250,
                  child: buildChart2(data2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChart1(List<_PatientsData> data) {
    return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(
            text: 'No. of Patients in the past 14 days',
            textStyle: const TextStyle(fontSize: 12, fontFamily: "Poppins")),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.top,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries<_PatientsData, String>>[
          ColumnSeries<_PatientsData, String>(
              dataSource: data,
              name: 'No. of patients',
              xAxisName: "Date",
              yAxisName: "No. of Patients",
              xValueMapper: (_PatientsData data, _) => data.date,
              yValueMapper: (_PatientsData data, _) => data.patients,
              dataLabelSettings: const DataLabelSettings(isVisible: true))
        ]);
  }

  Widget buildChart2(List<_DiagnosisData> data) {
    return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(
            text: 'No. of Patients per Diagnosis',
            textStyle: const TextStyle(fontSize: 12, fontFamily: "Poppins")),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.top,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries<_DiagnosisData, String>>[
          ColumnSeries<_DiagnosisData, String>(
              dataSource: data,
              name: 'No. of patients',
              xAxisName: "Date",
              yAxisName: "No. of Patients",
              color: Colors.orange,
              xValueMapper: (_DiagnosisData data, _) => data.illness,
              yValueMapper: (_DiagnosisData data, _) => data.patients,
              dataLabelSettings: const DataLabelSettings(isVisible: true))
        ]);
  }
}

class _PatientsData {
  _PatientsData(this.date, this.patients);

  final String date;
  final int patients;
}

class _DiagnosisData {
  _DiagnosisData(this.illness, this.patients);

  final String illness;
  final int patients;
}
