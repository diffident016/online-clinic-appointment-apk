import 'package:online_clinic_appointment/models/user.dart';
import 'package:online_clinic_appointment/utils.dart';

class Patient {
  int? id;
  String name;
  String gender;
  int? age;
  DateTime birthday;
  String address;
  String contactNumber;
  bool? status;
  User? account;

  Patient({
    this.id,
    required this.name,
    required this.gender,
    required this.birthday,
    required this.address,
    required this.contactNumber,
    this.account,
    this.status = true,
  });

  static Patient fromJson(Map<String, dynamic> json) => Patient(
      id: json['id'],
      name: json['attributes']['name'],
      gender: json['attributes']['gender'],
      birthday: Utils.toDateTime(json['attributes']['birthday']),
      address: json['attributes']['address'],
      contactNumber: json['attributes']['contact_number'],
      account: json['account'] == null ? null : User.fromJson(json['account']),
      status: json['attributes']['status']);

  static Patient fromLocalJson(Map<String, dynamic> json) => Patient(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      birthday: Utils.toDateTime(json['birthday']),
      address: json['address'],
      contactNumber: json['contact_number'],
      account: json['account'] == null ? null : User.fromJson(json['account']),
      status: json['status']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'birthday': Utils.fromDateTimeToJson(birthday),
        'address': address,
        'contact_number': contactNumber,
        'account': account,
        'status': status
      };
}
