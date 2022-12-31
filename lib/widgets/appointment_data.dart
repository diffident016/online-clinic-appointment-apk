import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/models/appointment.dart';
import 'package:online_clinic_appointment/utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AppointmentDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  AppointmentDataSource({required List<Appointment> appoinments}) {
    _appointmentData = appoinments
        .asMap()
        .entries
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'no', value: e.key + 1),
              DataGridCell<String>(
                  columnName: 'time',
                  value: Utils.displayTime(e.value.schedule.time)),
              DataGridCell<String>(
                  columnName: 'name', value: e.value.patient.name),
              DataGridCell<String>(
                  columnName: 'status',
                  value: e.value.status! ? 'Done' : 'Pending'),
            ]))
        .toList();
  }

  List<DataGridRow> _appointmentData = [];

  @override
  List<DataGridRow> get rows => _appointmentData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Text(
          e.value.toString(),
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList());
  }
}
