import 'package:chatapp_firebase/services/cloud/cloud_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/auth_service.dart';

class CloudService {
  final String? uid = AuthService.firebase().currentUser?.uid;

  final userCollection = FirebaseFirestore.instance.collection('users');
  final groupCollection = FirebaseFirestore.instance.collection('groups');

  // Save User Data
  Future saveUserData({
    required String fullName,
    required String email,
  }) async {
    return await userCollection.doc(uid).set({
      fullNameFieldName: fullName,
      emailFieldName: email,
      groupsFieldName: [],
      profilePicFieldName: '',
      uidFieldName: uid,
    });
  }

  // Get User Data
  Future getUserData() async {
    return await userCollection.doc(uid).get();
  }

  getGroupData() {
    return userCollection.doc(uid).snapshots();
  }

  // Create Group Chat
  Future createGroup(
    String userName,
    String groupName,
  ) async {
    await groupCollection.add({
      groupNameFieldName: groupName,
      groupIconFieldName: '',
      adminFieldName: '${uid}_$userName',
      membersFieldName: FieldValue.arrayUnion(['${uid}_$userName']),
      groupIdFieldName: '',
      recentMessageFieldName: '',
      recentMessageSenderFieldName: '',
      recentMessageTimeFieldName: '',
    }).then(
      (value) async {
        await value.update({
          groupIdFieldName: value.id,
        });
        await userCollection.doc(uid).update({
          groupsFieldName: FieldValue.arrayUnion(['${value.id}_$groupName']),
        });
      },
    );
  }

  // Get Chats
  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  // Get Group Chat Admin
  Future getGroupAdmin(String groupId) async {
    final snapshot = await groupCollection.doc(groupId).get();
    return await snapshot['admin'];
  }

  // Get Group Memebers
  Stream<DocumentSnapshot> getGroupMemebers(String groupId) {
    return groupCollection.doc(groupId).snapshots();
  }

  // Search By Name
  Future searchByName(String groupName) {
    return groupCollection
        .where(groupNameFieldName, isEqualTo: groupName)
        .get();
  }

  // Function -> bool
  Future<bool> isUserJoined({
    required String groupName,
    required String groupId,
    // required String userName,
  }) async {
    final userRef = userCollection.doc(uid);
    final snapshot = await userRef.get();

    List groups = await snapshot[groupsFieldName];
    if (groups.contains('${groupId}_$groupName')) {
      return true;
    } else {
      return false;
    }
  }

  // Join Group
  Future joinGroup({
    required String userName,
    required String groupId,
    required String groupName,
  }) async {
    final userRef = userCollection.doc(uid);
    final groupRef = groupCollection.doc(groupId);

    final snapshot = await userRef.get();
    List groups = await snapshot[groupsFieldName];

    if (!groups.contains('${groupId}_$groupName')) {
      await userRef.update({
        groupsFieldName: FieldValue.arrayUnion(['${groupId}_$groupName']),
      });
      await groupRef.update({
        membersFieldName: FieldValue.arrayUnion(['${uid}_$userName']),
      });
    }
  }

  // Leave Group
  Future leaveGroup({
    required String userName,
    required String groupId,
    required String groupName,
  }) async {
    final userRef = userCollection.doc(uid);
    final groupRef = groupCollection.doc(groupId);

    final userSnapshot = await userRef.get();
    List groups = await userSnapshot[groupsFieldName];

    if (groups.contains('${groupId}_$groupName')) {
      await userRef.update({
        groupsFieldName: FieldValue.arrayRemove(['${groupId}_$groupName']),
      });
      await groupRef.update({
        membersFieldName: FieldValue.arrayRemove(['${uid}_$userName']),
      });
    }
    final groupSnapshot = await groupRef.get();
    List members = await groupSnapshot[membersFieldName];
    print(members);
    print(groupSnapshot[membersFieldName]);
    print(members.isEmpty);
    if (members.isEmpty) {
      await groupRef.delete();
    }
  }

  // Send Message
  Future sendMessage({
    required String groupId,
    required String message,
    required String sender,
    required DateTime time,
  }) {
    final messageData = {
      messageFieldName: message,
      senderFieldName: sender,
      timeFieldName: time,
    };
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .add(messageData)
        .then(
          (ref) => ref.get().then(
                (snapshot) => groupCollection.doc(groupId).update({
                  recentMessageFieldName: snapshot[messageFieldName],
                  recentMessageSenderFieldName: snapshot[senderFieldName],
                  recentMessageTimeFieldName: snapshot[timeFieldName],
                }),
              ),
        );
  }
}
