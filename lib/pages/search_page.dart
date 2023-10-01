import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/pages/chat_page.dart';
import 'package:chatapp_firebase/services/cloud/cloud_constants.dart';
import 'package:chatapp_firebase/services/cloud/firebase_cloud_service.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  bool _isLoading = false;
  bool _isButtonLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = '';
  bool isJoined = false;

  @override
  void initState() {
    _searchController = TextEditingController();
    getCurrentUserName();
    super.initState();
  }

  getCurrentUserName() async {
    await HelperFunctions.getUserNameSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getAdminName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  String getUserId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 20),
          child: Container(
            // color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black26),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Groups...',
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: InkWell(
                      onTap: () {
                        initiateSearchMethod();
                      },
                      borderRadius: BorderRadius.circular(40),
                      splashColor: Colors.white.withOpacity(0.3),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
                color: Colors.white,
              ),
            )
          : hasUserSearched && searchSnapshot!.docs.isEmpty
              ? const Center(
                  child: Text(
                    'No results found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : groupList(),
    );
  }

  initiateSearchMethod() async {
    // if (_searchController.text.isNotEmpty) {
    setState(() {
      _isLoading = true;
    });
    await CloudService().searchByName(_searchController.text).then((snapshot) {
      setState(() {
        searchSnapshot = snapshot;
        _isLoading = false;
        hasUserSearched = true;
      });
    });
    // }
  }

  groupList() {
    return hasUserSearched && searchSnapshot!.docs.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                userName: userName,
                groupId: searchSnapshot!.docs[index][groupIdFieldName],
                groupName: searchSnapshot!.docs[index][groupNameFieldName],
                admin: searchSnapshot!.docs[index][adminFieldName],
              );
            },
          )
        : Container();
  }

  joinedOrNot({
    required String userName,
    required String groupId,
    required String groupName,
    required String admin,
  }) async {
    await CloudService()
        .isUserJoined(groupName: groupName, groupId: groupId)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      {required String userName,
      required String groupId,
      required String groupName,
      required String admin}) {
    joinedOrNot(
      userName: userName,
      groupId: groupId,
      groupName: groupName,
      admin: admin,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: isJoined
            ? () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatPage(
                    userName: userName,
                    groupId: groupId,
                    groupName: groupName,
                  ),
                ));
              }
            : null,
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            groupName.substring(0, 1).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        title: Text(
          groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Admin: ${getAdminName(admin)}',
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        trailing: isJoined
            ? const Icon(Icons.arrow_forward)
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isButtonLoading = true;
                  });
                  Future.delayed(
                    const Duration(seconds: 2),
                    () async {
                      await CloudService().joinGroup(
                        userName: userName,
                        groupId: groupId,
                        groupName: groupName,
                      );
                      setState(() {
                        _isButtonLoading = false;
                        isJoined = !isJoined;
                      });
                      showSnackBar(context, Colors.green,
                          'Successfully joined $groupName');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            userName: userName,
                            groupId: groupId,
                            groupName: groupName,
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    fixedSize: const Size(75, 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                child: _isButtonLoading
                    ? const Center(
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Join',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
      ),
    );
  }
}
