import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:online_clinic_appointment/api/services.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/models/schedule.dart';
import 'package:online_clinic_appointment/widgets/buttons.dart';
import 'package:online_clinic_appointment/widgets/showInfo.dart';
import 'package:table_calendar/table_calendar.dart';

class Form1 extends StatefulWidget {
  final Patient patient;
  final Function(int index) updateIndex;
  final Function(Appointment appointment) setAppointment;
  final Function(DateTime? date, DateTime? time) selectDateTime;
  final List<bool> available;
  DateTime? selectedTime;
  DateTime? selectedDay;
  Form1(
      {Key? key,
      required this.patient,
      required this.updateIndex,
      required this.setAppointment,
      required this.selectDateTime,
      required this.available,
      required this.selectedTime,
      required this.selectedDay})
      : super(key: key);

  @override
  Form1State createState() => Form1State();
}

class Form1State extends State<Form1> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final TextEditingController _remarks = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  bool valid = false;

  late FlutterSecureStorage storage;

  List<String> items = [];

  bool fetching = true;

  final String placeholder = "Not in the list";

  List<DropdownMenuItem<String>> dropdownItems = [
    DropdownMenuItem(
        value: "Not in the list",
        child: Text(
          "Not in the list",
          style: TextStyle(
              color: textColor.withOpacity(0.8), fontWeight: FontWeight.normal),
        ))
  ];

  String? _selectedIllness;

  @override
  void initState() {
    super.initState();

    storage = const FlutterSecureStorage();
    getIllness();
  }

  void getFromStorage() async {
    try {
      final json = await storage.read(key: 'illnesses');

      if (json != null) {
        items = List.from(jsonDecode(json));

        final dropItems = items.asMap().entries.map((item) {
          return DropdownMenuItem(
              value: item.value,
              child: Text(
                item.value,
                style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.normal),
              ));
        }).toList();

        dropdownItems = dropItems;
      }

      setState(() {
        fetching = false;
      });
    } on Exception catch (_) {
      setState(() {
        fetching = false;
      });
      return;
    }
  }

  void getIllness() {
    try {
      Services.getIllnesses().then((value) {
        if (value.statusCode == 200) {
          Map parse = json.decode(value.body);

          final list = List<Map>.from(parse["data"]);

          items =
              list.map((e) => e["attributes"]["illness"] as String).toList();

          if (items.isEmpty) {
            return getFromStorage();
          }

          items.add(placeholder);
          Services.saveIllnesses(items);

          final dropItems = items.asMap().entries.map((item) {
            return DropdownMenuItem(
                value: item.value,
                child: Text(
                  item.value,
                  style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontWeight: FontWeight.normal),
                ));
          }).toList();

          setState(() {
            dropdownItems = dropItems;
            fetching = false;
          });
        } else {
          setState(() {
            fetching = false;
          });

          return getFromStorage();
        }
      });
    } on Exception catch (_) {
      ShowInfo.showToast("Something went wrong");
      return getFromStorage();
    }
  }

  void checkValidity() {
    if (widget.selectedDay != null &&
        widget.selectedTime != null &&
        _remarks.text.isNotEmpty &&
        _selectedIllness != null) {
      setState(() {
        valid = true;
      });
    } else {
      setState(() {
        valid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return fetching
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT DATE',
                  style: TextStyle(
                      color: primaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 5,
                ),
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
                          rightChevronIcon:
                              Icon(Icons.chevron_right, size: 26)),
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      rowHeight: 32,
                      calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.rectangle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.5),
                            shape: BoxShape.rectangle,
                          ),
                          todayTextStyle: const TextStyle(
                              fontSize: 14, color: Colors.white),
                          selectedTextStyle: const TextStyle(
                              fontSize: 14, color: Colors.white)),
                      selectedDayPredicate: (day) {
                        return isSameDay(widget.selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        FocusScope.of(context).unfocus();

                        setState(() {
                          final day = DateFormat("EEE").format(selectedDay);

                          final now = DateFormat("yyyy-MM-dd").parse(
                              DateFormat("yyyy-MM-dd").format(DateTime.now()));
                          final sel = DateFormat("yyyy-MM-dd").parse(
                              DateFormat("yyyy-MM-dd").format(selectedDay));

                          if (notAllowedDay.contains(day)) {
                            ShowInfo.showToast(
                                'We are closed during this day.');

                            return;
                          }

                          if (sel.isBefore(now) ||
                              sel.isAfter(now.add(const Duration(days: 21)))) {
                            ShowInfo.showToast('This day is not allowed.');

                            return;
                          }

                          widget.selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });

                        widget.selectDateTime(
                            widget.selectedDay, widget.selectedTime);

                        checkValidity();
                      },
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'SELECT TIME',
                        style: TextStyle(
                            color: primaryColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: availableSlot,
                                ),
                              ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(width: 5),
                            ),
                            WidgetSpan(
                              child: Text(
                                'Available',
                                style: TextStyle(
                                    color: textColor.withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 20,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: const BoxDecoration(
                                  color: unavailableSlot,
                                ),
                              ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(width: 5),
                            ),
                            WidgetSpan(
                              child: Text(
                                'Unavailable',
                                style: TextStyle(
                                    color: textColor.withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    alignment: Alignment.center,
                    height: 35,
                    width: double.infinity,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: schedTime.length,
                        itemBuilder: ((context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                if (widget.available[index]) {
                                  FocusScope.of(context).unfocus();

                                  setState(() {
                                    widget.selectedTime = schedTime[index];
                                  });

                                  widget.selectDateTime(
                                      widget.selectedDay, widget.selectedTime);

                                  checkValidity();
                                }
                              },
                              child: Container(
                                width: 65,
                                decoration: BoxDecoration(
                                    color:
                                        widget.selectedTime == schedTime[index]
                                            ? primaryColor
                                            : widget.available[index]
                                                ? availableSlot
                                                : unavailableSlot,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Center(
                                    child: Text(
                                  DateFormat.jm().format(schedTime[index]),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                )),
                              ),
                            ),
                          );
                        })),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'YOUR ILLNESS',
                  style: TextStyle(
                      color: primaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1.5),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _selectedIllness,
                        menuMaxHeight: 300,
                        items: dropdownItems,
                        hint: Text('Select Illness',
                            style: TextStyle(
                              color: textColor.withOpacity(0.8),
                            )),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: textColor.withOpacity(0.8),
                        ),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedIllness = newValue!;
                          });

                          checkValidity();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'REASON FOR VISIT',
                  style: TextStyle(
                      color: primaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    autofocus: false,
                    maxLines: 4,
                    controller: _remarks,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return null;
                    },
                    onChanged: (value) {
                      checkValidity();
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Say something...',
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(15, 12, 20, 12),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: textColor.withOpacity(0.4), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: textColor.withOpacity(0.4), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Buttons(
                    type: 1,
                    label: "PROCEED",
                    color: valid ? primaryColor : availableSlot,
                    textColor: Colors.white,
                    onClick: () {
                      FocusScope.of(context).unfocus();
                      if (valid) {
                        final appointId =
                            DateFormat("yyyyMMdd").format(widget.selectedDay!) +
                                DateFormat("HHmm").format(widget.selectedTime!);

                        final appointment = Appointment(
                            app_code: appointId,
                            schedule: Schedule(
                                date: widget.selectedDay!,
                                time: widget.selectedTime!),
                            patient: widget.patient,
                            remarks: _remarks.text.trim(),
                            illness: _selectedIllness == placeholder
                                ? 'Not specified'
                                : _selectedIllness,
                            status: false);

                        widget.setAppointment(appointment);
                        widget.updateIndex(1);
                      }
                    },
                  ),
                )
              ],
            ),
          ));
  }
}
