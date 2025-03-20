import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthenticationHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Function to check if the email is valid
  bool validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9_.±]+@[a-zA-Z0-9-]+(.[a-zA-Z]{2,})+.[a-zA-Z0-9-.]+$',
    );

    if (email.isEmpty) {
      String message = "Please enter an email address";
      _showToast(message, Colors.red);
      return false;
    } else if (!emailRegex.hasMatch(email)) {
      String message = "Please enter a valid email address";
      _showToast(message, Colors.red);
      return false;
    }
    return true; // Return true if email is valid
  }

// Function to check if the password is valid
  bool validatePassword(String password) {
    if (password.length < 8) {
      String message = "Password must be at least 8 characters long";
      _showToast(message, Colors.red);
      return false;
    }
    return true; // Return true if password is valid
  }

  Future<bool> registerUser(String email, String password, String name,
      String dob, String contact, String? gender) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Get the logged-in user
      User? user = userCredential.user;

      if (user != null) {
        // Save user details in the Realtime Database
        DatabaseReference ref = _database.ref("users/${user.uid}");
        await ref.set({
          "name": name,
          "email": email,
          "dob": dob,
          "contact": contact,
          "gender": gender,
        });

        ref = _database.ref("books/${user.uid}");
        await ref.set({
          "booksCount": 0,
        });

        _showToast("User registration complete", Colors.green,
            length: Toast.LENGTH_LONG);
        return true;
      } else {
        _showToast("User Registration Failed", Colors.red);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
      String message = "";
      if (e.code == 'email-already-in-use') {
        message = "This email is already in use";
      } else if (e.code == 'network-request-failed') {
        message = "No internet connection";
      } else {
        message = "User Registration Failed";
      }
      _showToast(message, Colors.red);
      return false;
    } catch (e) {
      debugPrint("Unexpected Error: $e");
      _showToast("An unexpected error occurred. Please try again.", Colors.red);
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      // Attempt to sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the logged-in user
      User? user = userCredential.user;

      if (user != null) {
        // Login successful
        debugPrint("User logged in: ${user.uid}");
        _showToast("Login Successful", Colors.green);
        return true;
      } else {
        // Should not normally occur, but handle gracefully
        _showToast("Login Failed. Please try again.", Colors.red);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
      String message = "";
      if (e.code == 'network-request-failed') {
        message = "No internet connection";
      } else {
        message = "User Login Failed";
      }
      _showToast(message, Colors.red);
      return false;
    } catch (e) {
      debugPrint("Unexpected Error: $e");
      _showToast("An unexpected error occurred. Please try again.", Colors.red);
      return false;
    }
  }
  /// Logout the current user
  Future<bool> logoutUser() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      debugPrint("Logout Error: $e");
      _showToast("Unable to Logout", Colors.red);
      return false;
    }
  }

  /// Centralized toast display method
  void _showToast(String message, Color backgroundColor,
      {Toast? length = Toast.LENGTH_SHORT}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

// /// Check if a user is already logged in
// User? getCurrentUser() {
//   return _auth.currentUser;
// }

}
