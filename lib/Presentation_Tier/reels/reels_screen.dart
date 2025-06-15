import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:scholarly_app/Presentation_Tier/reels/view_reel.dart';
import '../../Application_Tier/ReelsManager.dart';

class ReelsScreen extends StatefulWidget {
  final String summaryText;
  final String path;

  const ReelsScreen({Key? key, required this.summaryText, required this.path})
      : super(key: key);

  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final ReelsManager reelsManager = ReelsManager();
  List<String> videoUrls = [];
  bool showMenu = false;
  bool isLoading = true;

  String selectedCharacter = 'Ava';
  String selectedFont = 'VT323';
  String selectedTextColor = 'Orange';
  String selectedBackgroundColor = 'Grey';
  String selectedType = 'Meme';

  final List<String> characters = ['Ava', 'Clara', 'Ryan', 'Connor'];
  final List<String> fonts = [
    'VT323',
    'Jersey 10',
    'Archivo Black',
    'Bebas Neue'
  ];
  final List<String> textColors = ['Orange', 'Green', 'Red', 'Blue'];
  final List<String> backgroundColors = [
    'Grey',
    'Tangerine',
    'Sap Green',
    'Brown',
    'Soft Purple'
  ];

  @override
  void initState() {
    super.initState();
    _checkReelStatus();
  }

  void _checkReelStatus() async {
    final FirebaseDatabase _database = FirebaseDatabase.instance;
    DatabaseReference ref = _database.ref(widget.path);

    DatabaseEvent event = await ref.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;

      if (data.containsKey('reels') && data['reels'] == true) {
        setState(() {
          showMenu = false;
          isLoading = false;
        });
      } else {
        setState(() {
          showMenu = true;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleViewReels() async {
    setState(() {
      isLoading = true; // Show loading indicator before fetching
    });

    List<String> urls = await reelsManager.getReelsUrls(widget.path);
    if (urls.isNotEmpty) {
      setState(() {
        videoUrls = urls;
        isLoading = false; // Hide loading indicator
      });
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      final FirebaseAuth _auth = FirebaseAuth.instance;
      String? userId = _auth.currentUser?.uid;

      await dbRef.child('analytics/$userId').update({
        'reelsPath': widget.path,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ViewReelScreen(videoUrls: videoUrls, path: widget.path),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No reels found!")),
      );
    }
  }

  void fun_generate_btn() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String? userId = _auth.currentUser?.uid;
    bool status = await reelsManager.generateReel(
      id: userId,
      path: widget.path,
      script: widget.summaryText,
      character: selectedCharacter,
      font: selectedFont,
      textColor: selectedTextColor,
      backgroundColor: selectedBackgroundColor,
      type: selectedType,
    );

    if (status == true) {
      final FirebaseDatabase _database = FirebaseDatabase.instance;
      DatabaseReference ref = _database.ref(widget.path);
      await ref.update({'reels': true});
      await Future.delayed(Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showSelectionBottomSheet(
      List<String> options, String title, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Column(
                children: options.map((option) {
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelect(option);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
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
                      'View Reels',
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
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : showMenu
                  ? _buildMenu(screenWidth)
                  : ElevatedButton(
                      onPressed: _handleViewReels,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Slightly smaller radius
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        minimumSize: Size(140, 50),
                      ),
                      child: const Text(
                        "View Reels",
                        style: TextStyle(
                          color: Color(0xFF00224F),
                          fontSize: 18, // Reduced font size slightly
                          fontWeight:
                              FontWeight.w600, // Slightly lighter than bold
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildMenu(double screenWidth) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
            ],
          ),
          width: screenWidth * 0.9,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Generate Reels'),
                SizedBox(height: 18),
                _buildSelectionTile('Character', selectedCharacter, characters,
                    (value) {
                  setState(() => selectedCharacter = value);
                }),
                _buildSelectionTile('Font', selectedFont, fonts, (value) {
                  setState(() => selectedFont = value);
                }),
                _buildSelectionTile('Text Color', selectedTextColor, textColors,
                    (value) {
                  setState(() => selectedTextColor = value);
                }),
                _buildSelectionTile('Background Color', selectedBackgroundColor,
                    backgroundColors, (value) {
                  setState(() => selectedBackgroundColor = value);
                }),
                SizedBox(height: 18),
                ToggleButtons(
                  isSelected: [
                    selectedType == 'Regular',
                    selectedType == 'Meme'
                  ],
                  onPressed: (index) {
                    setState(() {
                      selectedType = index == 0 ? 'Regular' : 'Meme';
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  fillColor: Color(0xFF00224F),
                  children: [
                    Padding(
                        padding: EdgeInsets.all(10), child: Text('Regular')),
                    Padding(padding: EdgeInsets.all(10), child: Text('Meme')),
                  ],
                ),
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: fun_generate_btn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00224F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Generate',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionTile(String title, String selectedValue,
      List<String> options, Function(String) onSelect) {
    return GestureDetector(
      onTap: () => _showSelectionBottomSheet(options, title, onSelect),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            Text(selectedValue,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
