import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getUserName(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (doc.exists) {
    return doc.data()?['name'];
  }
  return null;
}

Future<String?> getUserRole(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (doc.exists) {
    return doc.data()?['role'];
  }
  return null;
}

Future<String?> fetchUserName() async {
  String? name = await getUserName(FirebaseAuth.instance.currentUser!.uid);
  print('Имя пользователя: $name');
  return name;
}

Future<String?> fetchUserRole(String uid) async {
  final role = await getUserRole(uid);
  return role;
}
