import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Authentication {
  /// This method allows the user to sign in
  /// @params email & password of String
  /// returns bool of sign in state
  Future<bool> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// This method allows the user to sign in anonymously
  /// @params none
  /// returns bool of the sign in state
  Future<bool> signInAnonymously() async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInAnonymously();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error with signing in.');
      return false;
    }
  }

  /// This method allows the user to create a new account
  /// @params email, password, firstName, lastname, and time registered
  /// returns bool of the execution state
  Future<bool> register(
      String email,
      String password,
      String firstName,
      String lastName,
      String profilePic,
      Timestamp timeRegistered) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      CollectionReference users =
      FirebaseFirestore.instance.collection('users');
      FirebaseAuth auth = FirebaseAuth.instance;

      //Get the user's id
      String uid = auth.currentUser!.uid.toString();

      users
          .doc(uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'profilePic': profilePic,
        'dateRegistered': timeRegistered,
        'uid': uid
      })
          .then((value) => debugPrint("User Added"))
          .catchError((error) => debugPrint("Failed to add user: $error"));

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// This methods sign the user out
  /// @params none
  /// return none
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// This method obtains the user's uid
  /// @param none
  /// returns String of user's uid
  Future<String?> currentUserId() async {
    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      return currentUser.uid;
    } else {
      return null;
    }
  }

  /// This sends a email link to the user to reset his/her password
  /// @param Email of the user
  /// return none
  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }


  /// This method delete the user's account after re-authentication is called
  /// @params String of email & password
  /// returns bool of the state
  Future<bool> deleteUser(String email, String password) async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        debugPrint(
            'The user must reauthenticate before this operation can be executed.');
      }
      return false;
    }
  }

  /// This method re-authenticate the user to allow various actions to be performed
  /// @params String email & password
  /// returns bool of the state
  Future<bool> userReauthenticated(String email, String password) async {
    try {
      // Create a credential
      AuthCredential credential =
      EmailAuthProvider.credential(email: email, password: password);

      //Reauthenticate
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential);

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'Error with reauthentication. Verify that the user\'s email and password were correct.');

      return false;
    }
  }
}