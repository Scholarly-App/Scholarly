import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Data_Tier/UserModel.dart';

class UserManager {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> getUserData() async {
    try {
      String userId = _auth.currentUser?.uid ?? ''; // Get current user ID
      if (userId.isEmpty) return null;

      DatabaseEvent event = await _dbRef.child('users/$userId').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromMap(userData);
      } else {
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Unable to fetch user Data',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      debugPrint("Error fetching user data: $e");
      return null;
    }
  }

  Future<bool> updateUserData(UserModel updatedUser) async {
    try {
      String userId = _auth.currentUser?.uid ?? ''; // Get current user ID
      if (userId.isEmpty) return false;

      await _dbRef.child('users/$userId').update({
        'name': updatedUser.name,
        'email': updatedUser.email,
        'contact': updatedUser.contact,
        'dob': updatedUser.dob,
        'gender': updatedUser.gender,
      });

      Fluttertoast.showToast(
        msg: 'User information updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return true; // Successfully updated
    } catch (e) {
      print("Error updating user data: $e");
      return false; // Failed to update
    }
  }

}