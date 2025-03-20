import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TextScreen extends StatefulWidget {
  final String path;
  TextScreen({required this.path});

  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String explanationText = "Loading..."; // Default text while fetching

  @override
  void initState() {
    super.initState();
    _fetchExplanationText();
  }

  void _fetchExplanationText() async {
    try {
      DatabaseReference ref = _database.ref(widget.path); // Reference to Firebase path
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);

        // Extract the text field
        setState(() {
          explanationText = data['text'] ?? "No explanation available";
        });
      } else {
        setState(() {
          explanationText = "No explanation found at this path.";
        });
      }
    } catch (e) {
      setState(() {
        explanationText = "Error loading explanation: $e";
      });
    }
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
                    onTap: () => Navigator.pop(context),
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
                      'View Text Explanation',
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            explanationText,
            textAlign: TextAlign.justify,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
