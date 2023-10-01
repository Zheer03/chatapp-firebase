import 'package:chatapp_firebase/pages/group_info_page.dart';
import 'package:chatapp_firebase/services/cloud/firebase_cloud_service.dart';
import 'package:chatapp_firebase/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/cloud/cloud_constants.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const ChatPage({
    super.key,
    required this.userName,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  Stream<QuerySnapshot>? chats;
  String admin = '';

  @override
  void initState() {
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    getChatAndAdmin();
    super.initState();
  }

  getChatAndAdmin() {
    CloudService().getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });
    CloudService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        admin = value;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.groupName,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GroupInfoPage(
                    userName: widget.userName,
                    adminName: admin,
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.info,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Send a message...',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: Material(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        onTap: () {
                          sendMessage();
                        },
                        splashColor: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 100),
      child: StreamBuilder(
        stream: chats,
        builder: (context, snapshot) {
          scrollDown();
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                return MessageTile(
                  message: snapshot.data?.docs[index][messageFieldName],
                  sender: snapshot.data?.docs[index][senderFieldName],
                  sentByMe: widget.userName ==
                      snapshot.data?.docs[index][senderFieldName],
                );
              },
            );
          } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            _messageController = TextEditingController(text: 'Hi!');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 300,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                          child: Text(
                        'Be the first person to say \'Hi\' to everyone!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
                color: Colors.white,
              ),
            );
          }
        },
      ),
    );
  }

  sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final message = _messageController.text;
      setState(() {
        _messageController.clear();
      });
      await CloudService().sendMessage(
        groupId: widget.groupId,
        message: message,
        sender: widget.userName,
        time: DateTime.now(),
      );
    }
  }
}
