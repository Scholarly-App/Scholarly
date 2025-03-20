import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';

class UploadBookScreen extends StatefulWidget {
  @override
  _UploadBookScreenState createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final TextEditingController BookNameController = TextEditingController();
  bool _isLoading = false;
  String? filePath = '';

  // Function to allow user to pick a file
  Future<void> pickBook() async {
    // Open the file picker to allow the user to select a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      // Allow only one file at a time
      type: FileType.custom,
      // Custom file types (can be restricted to PDFs, etc.)
      allowedExtensions: [
        'pdf',
      ], // Specify file types if needed
    );

    // Check if a file was selected
    if (result != null) {
      filePath = result.files.single.path;
      if (filePath != null) {
        Fluttertoast.showToast(
            msg: "File selected: ${result.files.single.name}");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // User canceled the file picker
      Fluttertoast.showToast(msg: "No file selected.");
    }
  }

  Future<void> uploadBook() async {
    final String bookName = BookNameController.text.trim();

    if (filePath == null || filePath!.isEmpty) {
      Fluttertoast.showToast(msg: "Please select a file");
      return;
    } else if (bookName.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter a book name");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      // Sending file to Python script
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}:5000/upload-book'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath!));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final Map<String, dynamic> roadmap = json.decode(responseData);

        // Access both roadmaps
        var roadmap1 = roadmap['roadmap1'];
        var roadmap2 = roadmap['roadmap2'];

        // Upload book details and roadmap to Firebase
        final user = _auth.currentUser;
        if (user != null) {
          final userId = user.uid;

          var booksRef = _database.ref('books/$userId');
          final snapshot1 = await booksRef.child('booksCount').get();
          var booksCount = 0;
          if (snapshot1.exists) {
            // Get the value of booksCount
            booksCount = snapshot1.value as int;
          } else {
            booksCount = 0; // Default value if booksCount doesn't exist
          }
          booksCount = booksCount + 1;
          await booksRef.update({
            'booksCount': booksCount,
          });

          booksRef = _database.ref('books/$userId/$bookName');
          await booksRef.update({
            "name": bookName,
            "count": booksCount,
            "roadmap": roadmap1, // Upload the roadmap JSON to Firebase
          });

          final roadmapRef = _database.ref('roadmaps/$userId/$bookName');
          await roadmapRef.set({
            "name": bookName,
            "count": booksCount, // Upload the roadmap JSON to Firebase
            "roadmap": roadmap2,
          });

          Fluttertoast.showToast(msg: "Book Uploaded successfully!");
          BookNameController.clear();
          filePath = null;
        } else {
          Fluttertoast.showToast(msg: "User not logged in.");
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to process book on the server.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error uploading book: $e");
      debugPrint("Error e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    BookNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF00224F),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF00224F),
          elevation: 0,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    // onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: EdgeInsets.only(left: screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      child: Icon(
                        Icons.chevron_left,
                        color: Color(0xFF00224F),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.1),
                    child: Text(
                      'Upload Book',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'San Fransisco',
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                width: screenWidth * 0.9,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Upload New Book',
                        style: TextStyle(
                          color: Color(0xFF00224F),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                      SizedBox(height: 18),
                      IconButton(
                        onPressed: pickBook,
                        icon: Icon(Icons.add_circle_outline,
                            size: screenWidth * 0.2, color: Color(0xFF00224F)),
                      ),
                      TextField(
                        controller: BookNameController,
                        decoration: InputDecoration(
                          label: Text("Enter Book Name"),
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                      SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : uploadBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00224F),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Upload',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}