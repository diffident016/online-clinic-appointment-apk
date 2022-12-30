import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/screens/common/appoinment_details.dart';
import 'package:online_clinic_appointment/widgets/table_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:collection/collection.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../api/services.dart';
import '../../widgets/appointment_data.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int currentIndex = 0;
  int appointmentNo = 0;
  List<Appointment> appointments = [];
  late AppointmentDataSource appointmentDataSource;
  bool fetching = true;

  void getAppoinments(List<String> range) async {
    if (!fetching) {
      setState(() {
        fetching = true;
      });
    }

    String req = "";

    for (int i = 0; i < range.length; i++) {
      req += "filters[schedule][date][\$eq]=${range[i]}";

      if (i < range.length - 1) req += '&';
    }

    Services.getAppoinments(req).then((response) {
      if (response.statusCode == 200) {
        Map parse = json.decode(response.body);

        appointments = List.from(parse["data"])
            .map((doc) => Appointment.fromJson(doc))
            .toList();

        final newGroup =
            groupBy(appointments, ((Appointment ap) => ap.schedule.date))
                .entries
                .toList();

        List<Appointment> newList = [];

        for (var e in newGroup) {
          List<Appointment> group = e.value;
          group.sort((a, b) => a.schedule.time.compareTo(b.schedule.time));
          newList.addAll(group);
        }

        if (mounted) {
          setState(() {
            appointmentDataSource = AppointmentDataSource(appoinments: newList);
            appointmentNo = newList.length;
            fetching = false;
          });
        }
      }
    });
  }

  DateTime mostRecentWeekday(DateTime date, int weekday) =>
      DateTime(date.year, date.month, date.day - (date.weekday - weekday) % 7);

  void openAppoinment(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) =>
                AppoinmentDetails(appointment: appointments[index]))));
  }

  @override
  void initState() {
    super.initState();

    List<String> dates = [DateFormat("yyyy-MM-dd").format(DateTime.now())];

    getAppoinments(dates);
  }

  List<String> today() {
    return [DateFormat("yyyy-MM-dd").format(DateTime.now())];
  }

  List<String> yesterday() {
    return [
      DateFormat("yyyy-MM-dd")
          .format(DateTime.now().subtract(const Duration(days: 1)))
    ];
  }

  List<String> thisWeek() {
    final DateTime monday = mostRecentWeekday(DateTime.now(), 1);
    return List.generate(7,
        (i) => DateFormat("yyyy-MM-dd").format(monday.add(Duration(days: i))));
  }

  List<String> lastWeek() {
    final DateTime monday = mostRecentWeekday(DateTime.now(), 1);

    return List.generate(
        7,
        (i) => DateFormat("yyyy-MM-dd")
            .format(monday.subtract(Duration(days: i + 1))));
  }

  List<String> selected() {
    return [DateFormat("yyyy-MM-dd").format(_selectedDay!)];
  }

  List<String> getDates(int index) {
    if (index == 1) {
      return yesterday();
    } else if (index == 2) {
      return thisWeek();
    } else if (index == 3) {
      return lastWeek();
    } else if (index == 4) {
      return selected();
    }

    return today();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return VisibilityDetector(
      key: const Key('dashboard-screen'),
      onVisibilityChanged: (info) {
        if ((info.visibleFraction * 100) == 100) {
          if (_selectedDay != null) {
            getAppoinments(getDates(4));
          } else {
            getAppoinments(getDates(currentIndex));
          }
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: textColor.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    headerVisible: true,
                    headerStyle: const HeaderStyle(
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                            fontSize: 15,
                            fontFamily: "Poppins",
                            color: textColor),
                        formatButtonVisible: false,
                        leftChevronPadding: EdgeInsets.zero,
                        rightChevronPadding: EdgeInsets.zero,
                        leftChevronIcon: Icon(Icons.chevron_left, size: 26),
                        rightChevronIcon: Icon(Icons.chevron_right, size: 26)),
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    rowHeight: 36,
                    calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.rectangle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.5),
                          shape: BoxShape.rectangle,
                        ),
                        todayTextStyle:
                            const TextStyle(fontSize: 14, color: Colors.white),
                        selectedTextStyle:
                            const TextStyle(fontSize: 14, color: Colors.white)),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      FocusScope.of(context).unfocus();

                      List<String> dates = [
                        DateFormat("yyyy-MM-dd").format(selectedDay)
                      ];
                      getAppoinments(dates);

                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: SizedBox(
                  height: 25,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildTabs(0, currentIndex, size, label: "Today",
                          onClick: () {
                        List<String> dates = [
                          DateFormat("yyyy-MM-dd").format(DateTime.now())
                        ];
                        getAppoinments(dates);
                        setState(() {
                          _selectedDay = null;
                          currentIndex = 0;
                        });
                      }),
                      buildTabs(1, currentIndex, size, label: "Yesterday",
                          onClick: () {
                        List<String> dates = [
                          DateFormat("yyyy-MM-dd").format(
                              DateTime.now().subtract(const Duration(days: 1)))
                        ];

                        getAppoinments(dates);
                        setState(() {
                          _selectedDay = null;
                          currentIndex = 1;
                        });
                      }),
                      buildTabs(2, currentIndex, size, label: "This Week",
                          onClick: () {
                        List<String> dates = [];

                        final DateTime monday =
                            mostRecentWeekday(DateTime.now(), 1);

                        dates = List.generate(
                            7,
                            (i) => DateFormat("yyyy-MM-dd")
                                .format(monday.add(Duration(days: i))));

                        getAppoinments(dates);
                        setState(() {
                          _selectedDay = null;
                          currentIndex = 2;
                        });
                      }),
                      buildTabs(3, currentIndex, size, label: "Last Week",
                          onClick: () {
                        List<String> dates = [];

                        final DateTime monday =
                            mostRecentWeekday(DateTime.now(), 1);

                        dates = List.generate(
                            7,
                            (i) => DateFormat("yyyy-MM-dd").format(
                                monday.subtract(Duration(days: i + 1))));

                        getAppoinments(dates);
                        setState(() {
                          _selectedDay = null;
                          currentIndex = 3;
                        });
                      }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  height: 20,
                  child: Row(
                    children: [
                      Text(
                        'Number of Appoinments:',
                        style: TextStyle(
                            color: primaryColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 20,
                        child: Text(
                          "$appointmentNo",
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (fetching && appointmentNo != 0)
                        SizedBox(
                          height: 25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Loading data...',
                                style: TextStyle(fontSize: 11),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
              Container(
                height: 235,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Stack(alignment: Alignment.center, children: [
                  fetching && appointmentNo == 0
                      ? Center(
                          child: SizedBox(
                            width: double.infinity,
                            height: 25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Loading data...',
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                          ),
                        )
                      : appointmentNo == 0
                          ? const Text(
                              'No appoinments',
                              style: TextStyle(fontSize: 14),
                            )
                          : TableWidget(
                              appointmentDataSource: appointmentDataSource,
                              openAppointment: (int index) {
                                openAppoinment(index);
                              },
                            ),
                ]),
              )
            ]),
          ),
        ),
      ),
    );
  }

  Widget buildTabs(int index, int currentIndex, Size size,
      {required String label, required VoidCallback onClick}) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
          width: (size.width - 60) / 4,
          decoration: BoxDecoration(
              color: currentIndex == index ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor, width: 1)),
          child: Center(
              child: Text(
            label,
            style: TextStyle(
                color: currentIndex == index ? Colors.white : primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ))),
    );
  }
}
