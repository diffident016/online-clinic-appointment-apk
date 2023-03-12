import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/record.dart';
import 'package:online_clinic_appointment/utils.dart';

class RecordCard extends StatefulWidget {
  final Record record;
  final VoidCallback refreshReload;
  const RecordCard(
      {Key? key, required this.record, required this.refreshReload})
      : super(key: key);

  @override
  RecordCardState createState() => RecordCardState();
}

class RecordCardState extends State<RecordCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 20,
              leading: const Icon(Icons.task_alt_rounded,
                  color: Colors.green, size: 24),
              title: Text(
                'Record No. : ${widget.record.id}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(0.8)),
              )),
          buildField('Date of Visit:',
              Utils.displayDate(widget.record.appointment!.schedule.date)),

          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Diagnosis:',
                style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                height: 45,
                width: 200,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.record.diagnosis,
                      style: TextStyle(
                          color: textColor.withOpacity(0.8), fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prescription:',
                style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                height: 45,
                width: 200,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.record.prescription,
                      style: TextStyle(
                          color: textColor.withOpacity(0.8), fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
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
