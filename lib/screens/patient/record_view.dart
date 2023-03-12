import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/doctor.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/models/record.dart';
import 'package:online_clinic_appointment/screens/doctor/add_record.dart';
import 'package:online_clinic_appointment/screens/doctor/record_card.dart';

class PatientRecordView extends StatefulWidget {
  final List<Record> records;
  final int fetchState;
  final VoidCallback refreshRecords;
  const PatientRecordView(
      {Key? key,
      required this.fetchState,
      required this.records,
      required this.refreshRecords})
      : super(key: key);

  @override
  State<PatientRecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<PatientRecordView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(
        height: 5,
      ),
      SizedBox(
        height: 30,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'DIAGNOSIS & PRESCRIPTION',
                style: TextStyle(
                    color: primaryColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      ),
      SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.records.length,
              itemBuilder: ((context, index) {
                widget.records[index].id = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: RecordCard(
                    record: widget.records[index],
                    refreshReload: () {
                      widget.refreshRecords();
                    },
                  ),
                );
              })),
        ),
      )
    ]);
  }

  Widget buildField(String field, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
                child: Text(
              field,
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
                value,
                style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
