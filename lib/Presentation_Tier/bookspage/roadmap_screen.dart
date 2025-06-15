import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scholarly_app/Presentation_Tier/bookspage/summary_screen.dart';
import 'package:scholarly_app/Presentation_Tier/bookspage/text_screen.dart';

class RoadmapScreen extends StatefulWidget {
  final String bookTitle;

  RoadmapScreen({required this.bookTitle});

  @override
  _RoadmapScreenState createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? roadmapData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoadmap();
  }

  Future<void> _fetchRoadmap() async {
    try {
      final userId =
          FirebaseAuth.instance.currentUser?.uid; // Get current user's ID

      if (userId != null) {
        final snapshot =
        await _database.child("roadmaps/$userId/${widget.bookTitle}").get();

        if (snapshot.exists) {
          setState(() {
            roadmapData = Map<String, dynamic>.from(snapshot.value as Map);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Unable to Fetch Roadmap");
      debugPrint("Error fetching roadmap: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      backgroundColor: const Color(0xFF00224F),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF00224F),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
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
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF00224F),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.1),
                    child: Text(
                      'Roadmap Screen',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white,))
          : roadmapData == null
          ? const Center(child: Text("No roadmap available"))
          : ListView(
        padding:
        EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
        children: _buildRoadmapWidgets(roadmapData!['roadmap']),
      ),
    );
  }

  List<Widget> _buildRoadmapWidgets(Map roadmap,
      {int level = 0, String parentPath = ""}) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    // Sort the roadmap by start_page
    final sortedRoadmap = roadmap.entries.toList()
      ..sort((a, b) {
        final aStartPage = (a.value as Map)['start_page'] ?? double.infinity;
        final bStartPage = (b.value as Map)['start_page'] ?? double.infinity;
        return (aStartPage as num).compareTo(bStartPage as num);
      });

    return sortedRoadmap.map((entry) {
      String title = entry.key.toString();
      Map<String, dynamic> data = Map<String, dynamic>.from(entry.value as Map);
      Map? subRoadmap = data['sub-heading'];

      String currentPath =
      parentPath.isEmpty ? title : "$parentPath/sub-heading/$title";

      return Card(
        elevation: 4,
        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
        child: ExpansionTile(
          title: Text(
              title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            "Pages: ${data['start_page'] ?? 'N/A'} - ${data['end_page'] ??
                'N/A'}",
            style: const TextStyle(color: Colors.blue),
          ),
          children: [
            if (level > 0) // Add buttons only for deeper levels
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async{
                        // Construct the full database path
                        String databasePath =
                            "books/${FirebaseAuth.instance.currentUser
                            ?.uid}/${widget.bookTitle}/roadmap/$currentPath";

                        final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
                        final FirebaseAuth _auth = FirebaseAuth.instance;
                        String? userId = _auth.currentUser?.uid;

                        await dbRef.child('analytics/$userId').update({
                          'screen': 1,
                          'textPath': databasePath,
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TextScreen(path: databasePath),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00224F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "View Explanation",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async{
                        // Construct the full database path
                        String databasePath =
                            "books/${FirebaseAuth.instance.currentUser
                            ?.uid}/${widget.bookTitle}/roadmap/$currentPath";

                        final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
                        final FirebaseAuth _auth = FirebaseAuth.instance;
                        String? userId = _auth.currentUser?.uid;

                        await dbRef.child('analytics/$userId').update({
                          'screen': 2,
                          'textPath': databasePath,
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SummaryScreen(path: databasePath),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00224F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "View Summary",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            if (subRoadmap != null)
              ..._buildRoadmapWidgets(
                Map<String, dynamic>.from(subRoadmap),
                level: level + 1,
                parentPath: currentPath,
              ),
          ],
        ),
      );
    }).toList();
  }
}