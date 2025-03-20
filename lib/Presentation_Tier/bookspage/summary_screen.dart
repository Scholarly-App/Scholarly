import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:scholarly_app/Presentation_Tier/quiz/quiz_screen.dart';
import 'package:scholarly_app/Presentation_Tier/reels/reels_screen.dart';

import '../../config.dart';

class SummaryScreen extends StatefulWidget {
  final String path;

  SummaryScreen({required this.path});

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool summary_status = false;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String summaryText = "Generating Summary..."; // Default text while fetching
  final String flaskUrl =
      "${AppConfig.baseUrl}:5001/summarize";


  @override
  void initState() {
    super.initState();
    _fetchAndSummarizeText();
  }


  void _fetchAndSummarizeText() async {
    try {
      DatabaseReference ref = _database.ref(widget.path);
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);
        String explanationText = data['text'] ?? "No explanation available";

        String summary = data['summary'] ?? "";

        if (summary.isNotEmpty) {
          setState(() {
            summaryText = summary;
            summary_status=true;
          });
        } else {
          // Send text to Flask API for summarization
          var response = await http.post(
            Uri.parse(flaskUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": explanationText}),
          );

          if (response.statusCode == 200) {
            String generatedSummary = jsonDecode(response.body)['summary'];

            // Store the summary in the database under "summary" node
            await ref.update({
              'summary': generatedSummary,
            }).then((_) {
              setState(() {
                summaryText = generatedSummary;
                summary_status=true;
              });
            }).catchError((error) {
              debugPrint("Error generating summary: $error");
              Fluttertoast.showToast(msg: "Error generating summary");
            });
          } else {
            setState(() {
              summaryText = "Error: Failed to summarize text";
            });
          }
        }
      } else {
        setState(() {
          summaryText = "No explanation found";
        });
      }
    } catch (e) {
      setState(() {
        debugPrint("Error loading explanation: $e");
        summaryText = "Error loading explanation";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                      'View Summary',
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
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        // padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // White Box with Buttons
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal: screenWidth * 0.05,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (summary_status == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReelsScreen(summaryText: summaryText, path: widget.path),
                              ),
                            );
                          }else{
                            Fluttertoast.showToast(
                              msg: "Summary Not Found",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00224F),
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          "View Reels",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (summary_status == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(summaryText: summaryText, path: widget.path),
                              ),
                            );
                          }else{
                            Fluttertoast.showToast(
                              msg: "Summary Not Found",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00224F),
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          "Take Quiz",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // Spacing

            // Summary Text Box
            Expanded(
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    summaryText,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
