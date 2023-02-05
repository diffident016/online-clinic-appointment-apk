import 'package:online_clinic_appointment/models/user.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';
import 'package:online_clinic_appointment/utils.dart';

class Patient {
  int? id;
  String firstname;
  String lastname;
  String midname;
  String gender;
  int? age;
  DateTime birthday;
  String address;
  String contactNumber;
  bool? status;
  User? account;

  Patient(
      {this.id,
      required this.firstname,
      required this.lastname,
      required this.midname,
      required this.gender,
      required this.birthday,
      required this.address,
      required this.contactNumber,
      this.account,
      this.status = true,
      this.age});

  static Patient fromJson(Map<String, dynamic> json) => Patient(
      id: json['id'],
      firstname: json['attributes']['firstname'],
      lastname: json['attributes']['lastname'],
      midname: json['attributes']['middlename'],
      gender: json['attributes']['gender'],
      birthday: Utils.toDateTime(json['attributes']['birthday']),
      address: json['attributes']['address'],
      contactNumber: json['attributes']['contact_number'],
      account: UserAccount.user,
      status: json['attributes']['status'],
      age: json['attributes']['age']);

  static Patient fromNestedJson(Map<String, dynamic> json) => Patient(
      id: json['data']['id'],
      firstname: json['data']['attributes']['firstname'],
      lastname: json['data']['attributes']['lastname'],
      midname: json['data']['attributes']['middlename'],
      gender: json['data']['attributes']['gender'],
      birthday: Utils.toDateTime(json['data']['attributes']['birthday']),
      address: json['data']['attributes']['address'],
      contactNumber: json['data']['attributes']['contact_number'],
      account: json['data']['attributes']['account'] == null
          ? null
          : User.fromJson(json['data']['attributes']['account']),
      status: json['data']['attributes']['status'],
      age: json['data']['attributes']['age']);

  static Patient fromLocalJson(Map<String, dynamic> json) => Patient(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      midname: json['middlename'],
      gender: json['gender'],
      birthday: Utils.toDateTime(json['birthday']),
      address: json['address'],
      contactNumber: json['contact_number'],
      account: json['account'] == null ? null : User.fromJson(json['account']),
      status: json['status'],
      age: json['age']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstname': firstname,
        'lastname': lastname,
        'middlename': midname,
        'gender': gender,
        'birthday': Utils.fromDateTimeToJson(birthday),
        'address': address,
        'contact_number': contactNumber,
        'account': account,
        'status': status,
        'age': age
      };
}
