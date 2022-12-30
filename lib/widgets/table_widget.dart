import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/widgets/appointment_data.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableWidget extends StatefulWidget {
  final AppointmentDataSource appointmentDataSource;
  final Function(int index) openAppointment;
  const TableWidget(
      {Key? key,
      required this.appointmentDataSource,
      required this.openAppointment})
      : super(key: key);

  @override
  TableWidgetState createState() => TableWidgetState();
}

class TableWidgetState extends State<TableWidget> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40;

    return SfDataGrid(
      source: widget.appointmentDataSource,
      columnWidthMode: ColumnWidthMode.fill,
      headerRowHeight: 35,
      rowHeight: 40,
      onCellTap: (value) {
        if (value.rowColumnIndex.rowIndex != 0) {
          widget.openAppointment(value.rowColumnIndex.rowIndex - 1);
        }
      },
      columns: <GridColumn>[
        GridColumn(
            columnName: 'no',
            width: width * 0.12,
            label: Container(
                alignment: Alignment.center,
                child: const Text(
                  'No.',
                ))),
        GridColumn(
            columnName: 'time',
            width: width * 0.20,
            label: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Time',
                ))),
        GridColumn(
            columnName: 'name',
            width: width * 0.46,
            label: Container(
                alignment: Alignment.center,
                child: const Text(
                  "Patient's Name",
                ))),
        GridColumn(
            columnName: 'status',
            width: width * 0.22,
            label: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Status',
                ))),
      ],
    );
  }
}
