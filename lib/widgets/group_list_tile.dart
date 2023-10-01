import 'package:chatapp_firebase/pages/chat_page.dart';
import 'package:flutter/material.dart';

class GroupListTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupListTile({
    super.key,
    required this.userName,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupListTile> createState() => _GroupListTileState();
}

class _GroupListTileState extends State<GroupListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatPage(
              userName: widget.userName,
              groupId: widget.groupId,
              groupName: widget.groupName,
            ),
          ));
        },
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            widget.groupName.substring(0, 1).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        title: Text(
          widget.groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Join the conversation as ${widget.userName}',
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
