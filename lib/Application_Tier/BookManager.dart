import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Fetches books from Firebase Realtime Database for the current user
  Future<List<String>> fetchBooks() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        Fluttertoast.showToast(
          msg: "User not Logged In",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        throw Exception("User not logged in.");
      }

      final userId = user.uid;
      final booksRef = _database.ref('roadmaps/$userId');
      final snapshot = await booksRef.get();

      if (snapshot.exists) {
        final booksMap =
            Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

        // Sort the books based on the "count" value (descending order)
        final sortedBooks = booksMap.entries.toList()
          ..sort((a, b) {
            final aCount = (a.value as Map)['count'] ?? 0;
            final bCount = (b.value as Map)['count'] ?? 0;
            return (bCount as num)
                .compareTo(aCount as num); // Sort in descending order
          });

        // Return only the sorted book names
        return sortedBooks.map((entry) => entry.key).toList();
      } else {
        return [];
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error Fetching Books",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      throw Exception("Error fetching books: $e");
    }
  }

  /// Deletes a book from Firebase Realtime Database for the current user
  Future<void> deleteBook(String bookTitle) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        Fluttertoast.showToast(
          msg: "User not Logged In",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        throw Exception("User not logged in.");
      }

      final userId = user.uid;
      final booksRef = _database.ref('books/$userId/$bookTitle');
      await booksRef.remove();

      final roadmapRef = _database.ref('roadmaps/$userId/$bookTitle');
      await roadmapRef.remove();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error Deleting Books",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      throw Exception("Error deleting book: $e");
    }
  }

  /// Updates a book's name in Firebase Realtime Database for the current user
  Future<void> updateBookName(String oldName, String newName) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        Fluttertoast.showToast(
          msg: "User not Logged In",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        throw Exception("User not logged in.");
      }

      final userId = user.uid;
      final userBooksRef = _database.ref('books/$userId');
      final roadmapRef = _database.ref('roadmaps/$userId');

      // Check if new name already exists
      final snapshot1 = await userBooksRef.child(newName).get();
      final snapshot2 = await roadmapRef.child(newName).get();

      if (snapshot1.exists || snapshot2.exists) {
        Fluttertoast.showToast(
          msg: "Book with this name already exists",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        throw Exception("Book with this name already exists.");
      }

      Fluttertoast.showToast(msg: "Updating Book Name");
      // Rename the book
      final oldBookData1 = await userBooksRef.child(oldName).get();
      final oldBookData2 = await roadmapRef.child(oldName).get();

      if (oldBookData1.exists || oldBookData2.exists) {

        if (oldBookData1.value is Map) {
          Map<String, dynamic> updatedBookData = Map<String, dynamic>.from(
              oldBookData1.value as Map);
          updatedBookData['name'] = newName;
          await userBooksRef.child(newName).set(updatedBookData);
          await userBooksRef.child(oldName).remove();
        }

        if (oldBookData2.value is Map) {
          Map<String, dynamic> updatedBookData2 = Map<String, dynamic>.from(
              oldBookData2.value as Map);
          updatedBookData2['name'] = newName;
          await roadmapRef.child(newName).set(updatedBookData2);
          await roadmapRef.child(oldName).remove();
        }

      } else {
        Fluttertoast.showToast(
          msg: "Old book not found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        throw Exception("Old book not found.");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating book name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      throw Exception("Error updating book name: $e");
    }
  }
}
