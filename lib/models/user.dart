class User {
  int? id;
  String username;
  String email;
  String? provider;
  bool? confirmed;
  bool? blocked;
  String? userType;

  User(
      {required this.username,
      required this.email,
      this.userType = "patient",
      this.provider,
      this.blocked = false,
      this.confirmed,
      this.id});

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'provider': provider,
        'confirmed': confirmed,
        'blocked': blocked,
        'userType': userType,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        username: json['username'],
        userType: json['userType'],
        provider: json['provider'],
        blocked: json['blocked'],
        confirmed: json['confirmed'],
      );
}
