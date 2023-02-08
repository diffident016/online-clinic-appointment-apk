import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/doctor.dart';
import 'package:online_clinic_appointment/models/patient.dart';
import 'package:online_clinic_appointment/models/record.dart';
import 'package:online_clinic_appointment/screens/doctor/add_record.dart';
import 'package:online_clinic_appointment/screens/doctor/record_card.dart';

class RecordView extends StatefulWidget {
  final Patient patient;
  final Doctor doctor;
  final List<Record> records;
  final int fetchState;
  final VoidCallback refreshRecords;
  const RecordView(
      {Key? key,
      required this.patient,
      required this.doctor,
      required this.fetchState,
      required this.records,
      required this.refreshRecords})
      : super(key: key);

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(
        height: 5,
      ),
      Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            buildField('Name:',
                '${widget.patient.lastname}, ${widget.patient.firstname}, ${widget.patient.midname}'),
            buildField('Age:', widget.patient.age.toString()),
            buildField('Gender:', widget.patient.gender),
            buildField('Address:', widget.patient.address),
            buildField('Phone Number:', widget.patient.contactNumber)
          ]),
        ),
      ),
      const SizedBox(
        height: 15,
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
            if (widget.records.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => AddRecord(
                                doctor: widget.doctor,
                                patient: widget.patient,
                                refreshRecords: () {
                                  widget.refreshRecords();
                                },
                              ))));
                },
                child: const Text(
                  'Add Record',
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: primaryColor),
                ),
              ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      ),
      widget.fetchState != 1
          ? SizedBox(height: 200, width: double.infinity, child: buildStatus())
          : SizedBox(
              height: size.height * 0.38,
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

  Widget buildStatus() {
    if (widget.fetchState == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No records of this patient'),
          const SizedBox(
            height: 10,
          ),
          Container(
              width: 100,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: primaryColor, borderRadius: BorderRadius.circular(10)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => AddRecord(
                                doctor: widget.doctor,
                                patient: widget.patient,
                                refreshRecords: () {
                                  widget.refreshRecords();
                                },
                              ))));
                },
                child: const Text(
                  'Add Record',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ))
        ],
      );
    } else if (widget.fetchState == -1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('An error occurred'),
          const SizedBox(
            height: 10,
          ),
          Container(
              width: 100,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: primaryColor, borderRadius: BorderRadius.circular(10)),
              child: GestureDetector(
                onTap: () {
                  widget.refreshRecords();
                },
                child: const Text(
                  'Reload',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ))
        ],
      );
    } else {
      return SizedBox(
        height: 60,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                )),
            SizedBox(
              width: 10,
            ),
            Text(
              'Loading, please wait...',
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
      );
    }
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
