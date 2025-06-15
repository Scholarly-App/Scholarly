import 'package:flutter/material.dart';
import '../../Data_Tier/ReelsWidget.dart';
import '../../Application_Tier/ReelsManager.dart';

class ViewReelScreen extends StatefulWidget {
  final List<String> videoUrls;
  final String path;

  const ViewReelScreen({Key? key, required this.videoUrls, required this.path})
      : super(key: key);

  @override
  _ViewReelScreenState createState() => _ViewReelScreenState();
}

class _ViewReelScreenState extends State<ViewReelScreen> {
  final PageController _pageController = PageController();
  final ReelsManager reelsManager = ReelsManager();

  String getTopicName(String path) {
    List<String> parts = path.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }

  Future<void> _showFeedbackDialog() async {
    TextEditingController feedbackController = TextEditingController();

    bool? submitted = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          title: Text("Feedback", textAlign: TextAlign.center),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Let us know your thoughts!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: feedbackController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Type your feedback here...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // cancel
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            ),
            TextButton(
              onPressed: () async {
                String feedback = feedbackController.text.trim();
                if (feedback.isNotEmpty) {
                  ReelsManager.submitFeedback(feedback);
                }
                Navigator.of(context).pop(true); // submitted
              },
              child: Text("Submit", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );

    if (submitted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Thanks for your feedback!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00224F),
      body: Stack(
        children: [
          // Video PageView
          // PageView.builder(
          //   scrollDirection: Axis.vertical,
          //   itemCount: widget.videoUrls.length,
          //   itemBuilder: (context, index) {
          //     return ReelWidget(videoUrl: widget.videoUrls[index]);
          //   },
          // ),

          PageView.builder(
            controller: _pageController, // PASSING CONTROLLER
            scrollDirection: Axis.vertical,
            itemCount: widget.videoUrls.length,
            itemBuilder: (context, index) {
              return ReelWidget(
                videoUrl: widget.videoUrls[index],
                pageController: _pageController, // PASS CONTROLLER
                currentIndex: index, // NEW PROP
                totalVideos: widget.videoUrls.length, // NEW PROP
              );
            },
          ),

          // Back Button (Top Left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black38, size: 36),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Book Logo & Name (Bottom Left)
          Positioned(
            bottom: 60,
            left: 30,
            child: Row(
              children: [
                Container(
                  width: 40, // Circular logo size
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // Placeholder color
                    image: DecorationImage(
                      image: AssetImage('assets/icon/books/book2.png'),
                      // Replace with your book logo
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  getTopicName(widget.path), // Corrected placement of Text
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Feedback Button (Bottom Right)
          Positioned(
            bottom: 100,
            right: 30,
            child: ElevatedButton(
              onPressed: () {
                _showFeedbackDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00224F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                "Feedback",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
