import 'dart:convert';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:online_clinic_appointment/api/chatbot.dart';
import 'package:online_clinic_appointment/constant.dart';
import 'package:online_clinic_appointment/models/message.dart';

class ChatBox extends StatefulWidget {
  List<Message> messages;
  Function(List<Message> messages) saveMessages;
  ChatBox({Key? key, required this.messages, required this.saveMessages})
      : super(key: key);

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _message = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();

    messages = widget.messages;
  }

  @override
  void dispose() {
    super.dispose();

    widget.saveMessages(messages);
  }

  void sendMessage(String message) {
    ChatBotApi.sendMessage(message).then((value) {
      if (value.statusCode == 200) {
        final parse = jsonDecode(value.body);

        final newMessage = Message.fromJson(parse);

        setState(() {
          messages.add(newMessage);
        });
      } else {
        final newMessage =
            Message('It seems that there is an error with the bot.');

        setState(() {
          messages.add(newMessage);
        });
      }
    }).timeout(const Duration(seconds: 20), onTimeout: () {
      final newMessage = Message(
          'The bot is sleeping at this time, please wait and try to chat again.');

      setState(() {
        messages.add(newMessage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: Container(
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.8), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 28),
          ),
          title: const Text(
            'Oncass Bot',
            style: TextStyle(
                color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'Typically replies instantly',
            style: TextStyle(color: textColor, fontSize: 12),
          ),
          trailing: GestureDetector(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.close,
                color: textColor,
                size: 20,
              ),
            ),
          ),
        ),
        SizedBox(
            height: size.height * 0.18,
            child: messages.isEmpty
                ? const Center(
                    child: Text('Hey! Say hi or ask me a question.'),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    reverse: true,
                    itemBuilder: ((context, index) {
                      final messages = this.messages.reversed.toList();
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 3),
                        child: BubbleNormal(
                          text: messages[index].message,
                          isSender: messages[index].isMe!,
                          color: messages[index].isMe!
                              ? primaryColor
                              : const Color(0xFFE8E8EE),
                          tail: true,
                          textStyle: TextStyle(
                              fontSize: 16,
                              color: messages[index].isMe!
                                  ? Colors.white
                                  : textColor),
                        ),
                      );
                    }))),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: false,
                  controller: _message,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    isCollapsed: true,
                    isDense: true,
                    suffixIconConstraints:
                        BoxConstraints.tight(const Size(35, 18)),
                    contentPadding: const EdgeInsets.fromLTRB(15, 12, 10, 12),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () {
                    if (_message.text.isNotEmpty) {
                      setState(() {
                        messages.add(Message(_message.text, isMe: true));
                        sendMessage(_message.text);
                      });

                      _message.clear();
                    }
                  },
                  child: const Icon(
                    Icons.send_sharp,
                    color: primaryColor,
                    size: 30,
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
