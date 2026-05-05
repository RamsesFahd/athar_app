import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveUserInterests(String uid, List<String> interests) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({'interests': interests});
}
