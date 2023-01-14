class Message {
  final String message;
  bool? isMe;

  Message(this.message, {this.isMe = false});

  static Message fromJson(Map<String, dynamic> json) => Message(json['answer']);
}
