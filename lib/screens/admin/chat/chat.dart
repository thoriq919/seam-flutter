import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class Chat extends StatefulWidget {
  final String senderName;

  const Chat({required this.senderName, super.key});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('messages').add({
        'text': _messageController.text,
        'sender': widget.senderName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.white,
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorTheme.blackFont,
          ),
        ),
        backgroundColor: ColorTheme.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser =
                          message['sender'] == widget.senderName;

                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? ColorTheme.white
                                : ColorTheme.grey,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrentUser
                                  ? ColorTheme.primary
                                  : ColorTheme.secondary,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${message['sender']}',
                                style: TextStyle(
                                    fontSize: 10, color: ColorTheme.blackFont),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                message['text'],
                                style: TextStyle(
                                    color: isCurrentUser
                                        ? ColorTheme.blackFont
                                        : ColorTheme.blackFont.withAlpha(200)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator()));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik Pesan...',
                      hintStyle:
                          TextStyle(color: ColorTheme.blackFont.withAlpha(100)),
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: ColorTheme.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: ColorTheme.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: ColorTheme.green),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
