import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/src/models/user.dart';
import 'package:user_repository/src/user_repo.dart';

import 'entities/pingeon.dart';
import 'entities/user_entity.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password,
      );
      final PigeonUserDetails pigeonUserDetails = createPigeonUserDetails(user);
      myUser.userId = pigeonUserDetails.userInfo.uid!;
      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  PigeonUserDetails createPigeonUserDetails(UserCredential user) {
    if (user.user == null) {
      throw Exception("User data is null");
    }

    final PigeonUserInfo userInfo = PigeonUserInfo(
      uid: user.user!.uid,
      email: user.user!.email,
      displayName: user.user!.displayName,
      phoneNumber: user.user!.phoneNumber,
      photoUrl: user.user!.photoURL,
      isAnonymous: user.user!.isAnonymous,
      isEmailVerified: user.user!.emailVerified,
    );

    final List<Map<Object?, Object?>?> providerData = user.user!.providerData.map((provider) {
      return {
        'providerId': provider.providerId,
        'uid': provider.uid,
        'displayName': provider.displayName,
        'email': provider.email,
        'phoneNumber': provider.phoneNumber,
        'photoUrl': provider.photoURL,
      };
    }).toList();

    return PigeonUserDetails(
      userInfo: userInfo,
      providerData: providerData,
    );
  }


  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<MyUser> get user {
    return _firebaseAuth.authStateChanges().flatMap((firebaseUser) async* {
      try {
        if (firebaseUser == null) {
          yield MyUser.empty;
        } else {
          final document = await usersCollection.doc(firebaseUser.uid).get();
          if (document.exists && document.data() != null) {
            yield MyUser.fromEntity(MyUserEntity.fromDocument(document.data()!));
          } else {
            yield MyUser.empty;
          }
        }
      } catch (e) {
        log('Error: $e');
        yield MyUser.empty;
      }
    });
  }
}
