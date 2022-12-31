import 'package:online_clinic_appointment/models/user.dart';
import 'package:online_clinic_appointment/provider/user_account.dart';

class Doctor {
  int? id;
  String name;
  String contact_no;
  String address;
  User account;

  Doctor(
      {this.id,
      required this.name,
      required this.contact_no,
      required this.address,
      required this.account});

  static Doctor fromJson(Map<String, dynamic> json) => Doctor(
      id: json["id"],
      name: json["attributes"]["name"],
      contact_no: json["attributes"]["contact_no"],
      address: json["attributes"]["address"],
      account: UserAccount.user!);

  static Doctor fromLocalJson(Map<String, dynamic> json) => Doctor(
      id: json["id"],
      name: json["name"],
      contact_no: json["contact_no"],
      address: json["address"],
      account: User.fromJson(json["account"]));

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact_no': contact_no,
        'address': address,
        'account': account.toJson()
      };
}
