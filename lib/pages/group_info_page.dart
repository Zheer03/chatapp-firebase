import 'package:chatapp_firebase/services/cloud/cloud_constants.dart';
import 'package:chatapp_firebase/services/cloud/firebase_cloud_service.dart';
import 'package:chatapp_firebase/shared/routes.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupInfoPage extends StatefulWidget {
  final String userName;
  final String adminName;
  final String groupId;
  final String groupName;
  const GroupInfoPage({
    super.key,
    required this.userName,
    required this.adminName,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Stream<DocumentSnapshot>? members;
  bool _isLoading = false;

  @override
  void initState() {
    members = CloudService().getGroupMemebers(widget.groupId);
    // getMembers();
    super.initState();
  }

  // getMembers() {
  //   CloudService().getGroupMemebers(widget.groupId).then((value) {
  //     setState(() {
  //       members = value;
  //     });
  //   });
  // }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  String getUserId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isLoading
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              centerTitle: true,
              title: const Text('Group Info'),
              actions: [
                IconButton(
                  onPressed: () async {
                    await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('Leave group'),
                            content: _isLoading
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                        width: 270,
                                      ),
                                      CircularProgressIndicator(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        color: Colors.white,
                                      )
                                    ],
                                  )
                                : const Text(
                                    'Are you sure you want to leave this group?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  Future.delayed(
                                    const Duration(seconds: 1),
                                    () async {
                                      showSnackBar(context, Colors.red,
                                          'Left Group ${widget.groupName}');
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        homePageRoute,
                                        (route) => false,
                                      );
                                      await CloudService()
                                          .leaveGroup(
                                        userName: getName(widget.userName),
                                        groupId: widget.groupId,
                                        groupName: widget.groupName,
                                      )
                                          .whenComplete(() {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      });
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                child: const Text('Leave'),
                              ),
                            ],
                          );
                        });
                      },
                    );
                  },
                  tooltip: 'Leave Group',
                  icon: const Icon(
                    Icons.exit_to_app,
                  ),
                ),
              ],
            ),
      body: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            widget.groupName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Group: ${widget.groupName}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text('Admin: ${getName(widget.adminName)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  memberList(),
                ],
              ),
            ),
    );
  }

  memberList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: members,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?[membersFieldName] != null &&
              snapshot.data?[membersFieldName].length != 0) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data?[membersFieldName].length,
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        getName(snapshot.data?[membersFieldName][index])
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      getName(snapshot.data?[membersFieldName][index]),
                      style: const TextStyle(),
                    ),
                    subtitle: Text(
                      getUserId(snapshot.data?[membersFieldName][index]),
                      style: const TextStyle(),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No members'),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }
}
