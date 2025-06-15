import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:scholarly_app/Presentation_Tier/bookspage/roadmap_screen.dart';
import 'package:scholarly_app/Presentation_Tier/bookspage/summary_screen.dart';
import 'package:scholarly_app/Presentation_Tier/bookspage/text_screen.dart';
import 'package:scholarly_app/Presentation_Tier/reels/reels_screen.dart';
import 'package:scholarly_app/Presentation_Tier/reels/view_reel.dart';

class Dashboard extends StatefulWidget {
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> books = [
    {'name': '....', 'icon': Icons.book, 'color': Color(0xFFc9a0ff)},
    {'name': '....', 'icon': Icons.book, 'color': Color(0xFF93dafa)},
    {'name': '....', 'icon': Icons.book, 'color': Color(0xFFb6f36a)},
    {'name': '....', 'icon': Icons.book, 'color': Color(0xFFff9a62)},
    {'name': '....', 'icon': Icons.book, 'color': Color(0xFFFFD233)},
    {'name': '....', 'icon': Icons.book, 'color': Color(0xFF02b1ee)},
  ];

  final List<String> books_list = [
    'assets/icon/books/book1.png',
    'assets/icon/books/book2.png',
    'assets/icon/books/book3.png',
    'assets/icon/books/book4.png',
    'assets/icon/books/book5.png',
    'assets/icon/books/book6.png',
    'assets/icon/books/book7.png',
  ];

  double progressValue = 0;

  final TextEditingController NameController =
      TextEditingController(text: "....");
  final TextEditingController BookController =
      TextEditingController(text: "................");
  final TextEditingController RoadmapController =
      TextEditingController(text: ".............");
  final TextEditingController StatusController =
      TextEditingController(text: "..........");

// Helper method to assign dynamic colors to books based on index
  Color _getDynamicColor(int index) {
    List<Color> colors = [
      Color(0xFFc9a0ff), // Purple
      Color(0xFF93dafa), // Blue
      Color(0xFFb6f36a), // Green
      Color(0xFFff9a62), // Orange
      Color(0xFFFFD233), // Yellow
      Color(0xFF02b1ee), // Cyan
    ];
    return colors[
        index % colors.length]; // Cycle through colors using the index
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String? name;
  String? email;
  String? dob;
  String? contact;
  String? gender;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    fetchBooks();
    fetchAnalytics();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DatabaseReference ref = _database.ref("users/${user.uid}");
        DataSnapshot snapshot = await ref.get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> userData =
              snapshot.value as Map<dynamic, dynamic>;

          setState(() {
            name = userData["name"];
            NameController.text = name! + "👨‍🎓";
            email = userData["email"];
            dob = userData["dob"];
            contact = userData["contact"];
            gender = userData["gender"];
          });
        } else {
          debugPrint("No data found for user.");
        }
      } else {
        debugPrint("User not logged in.");
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  void fetchBooks() async {
    try {
      String? userId = _auth.currentUser?.uid; // Extract UID safely

      if (userId == null) {
        print("User not logged in.");
        return;
      }

      List<String> bookNames = await getBookNames(userId);

      setState(() {
        for (int i = 0; i < bookNames.length && i < books.length; i++) {
          books[i]['name'] = bookNames[i]; // Update book names
        }
        books.length = bookNames.length; // Adjust list size
      });
    } catch (e) {
      print("Error fetching books: $e");
    }
  }

  void fetchAnalytics() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      final dbRef = FirebaseDatabase.instance.ref('analytics/$userId');
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        final title = data['bookTitle']?.toString() ?? '';

        if (title.isNotEmpty) {
          BookController.text = title;
          RoadmapController.text = "Roadmap Generated ✅";
          StatusController.text = "Completed";
          progressValue = 0.04;
        }
      }
      else{
        BookController.text = "No Data";
        RoadmapController.text = "Roadmap Generated ❌";
        StatusController.text = "Completed";
        progressValue = 0;
      }
    }
  }

  Future<List<String>> getBookNames(String userId) async {
    DatabaseReference booksRef =
        FirebaseDatabase.instance.ref().child("roadmaps").child(userId);
    List<String> bookNames = [];

    try {
      DatabaseEvent event =
          await booksRef.orderByChild("count").limitToLast(6).once();

      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic> booksMap =
            snapshot.value as Map<dynamic, dynamic>;

        // Convert map to list and sort by count in descending order
        List<MapEntry<dynamic, dynamic>> sortedBooks = booksMap.entries.toList()
          ..sort((a, b) =>
              (b.value["count"] as int).compareTo(a.value["count"] as int));

        // Extract book names
        bookNames = sortedBooks
            .map(
                (entry) => entry.value["name"].toString()) // Extract book names
            .toList();
      }
    } catch (e) {
      print("Error fetching books: $e");
    }

    //If New User and No books Found
    if(bookNames.isEmpty){
      bookNames= ["No books Available"];
    }

    return bookNames;
  }

  @override
  void dispose() {
    NameController.dispose();
    BookController.dispose();
    RoadmapController.dispose();
    StatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.18; // 18% of the screen height
    double booksHeight = screenHeight * 0.18;
    double progressHeight = screenHeight * 0.28;
    double recentHeight = screenHeight * 0.17;

    return Scaffold(
      backgroundColor: Color(0xFF00224F),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            // Aligns content to the top
            children: [
              Container(
                height: appBarHeight,
                child: Padding(
                  padding: EdgeInsets.only(left: 28.0, right: 28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            NameController.text,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ready for the next\nTopic!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/icon/logo1.png'),
                        backgroundColor: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 8.0, left: 20.0),
                  child: Text(
                    'Library:',
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontFamily: 'San Fransisco',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                height: booksHeight,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 0.0, bottom: 8.0, left: 14.0, right: 14.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    // Horizontal scrolling
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      // Color itemColor = books[index]['color'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0), // Adjust padding
                        child: Container(
                          width: 120,
                          // Adjust width to ensure more items fit
                          decoration: BoxDecoration(
                            color: books[index]['color'],
                            // color: Color(0xFF00224F),
                            border: Border.all(
                              color: Colors.white, // White border color
                              width: 2.5, // Width of the border
                            ),
                            borderRadius: BorderRadius.circular(12),

                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.grey.withOpacity(0.3),
                            //     spreadRadius: 2,
                            //     blurRadius: 5,
                            //   ),
                            // ],
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                books_list[index % books_list.length],
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                              // Icon(Icons.book, size: 40),
                              SizedBox(height: 8),
                              Text(
                                books[index]['name']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold
                                    // fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                height: progressHeight,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
                  // Apply padding equally on both sides
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFfede67),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Padding(
                            padding: EdgeInsets.only(top: 16.0, left: 16.0),
                            child: Text(
                              'Progress:',
                              style: TextStyle(
                                color: Color(0xFF00224F), // Text color
                                fontFamily: 'San Fransisco',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),

                          // Progress info (with icon and texts)
                          Padding(
                            padding:
                                EdgeInsets.only(top: 8, left: 16, right: 20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      AssetImage('assets/icon/app_icon.png'),
                                  backgroundColor: Colors.black,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        BookController.text,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        softWrap: true,
                                      ),
                                      Text(
                                        RoadmapController.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      ),
                                      Text(
                                        StatusController.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Progress Bar
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 22),
                            child: Container(
                              height: 6,
                              // Adjust the height to make the progress bar thicker
                              child: LinearProgressIndicator(
                                value: progressValue,
                                // Set your progress value here (0.0 to 1.0)
                                backgroundColor: Colors.grey[300],
                                // Background color of the progress bar
                                valueColor: AlwaysStoppedAnimation<Color>(Color(
                                    0xFF00224F)), // Color of the progress bar
                              ),
                            ),
                          ),

                          // Button aligned to the right
                          Padding(
                            padding:
                                EdgeInsets.only(right: 30, bottom: 10, top: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    final userId = user?.uid;

                                    if (userId != null) {
                                      final dbRef = FirebaseDatabase.instance
                                          .ref('analytics/$userId');
                                      final snapshot = await dbRef.get();

                                      if (snapshot.exists) {
                                        final data = snapshot.value
                                            as Map<dynamic, dynamic>;

                                        final title =
                                            data['bookTitle']?.toString() ?? '';

                                        if (title.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RoadmapScreen(
                                                      bookTitle: title),
                                            ),
                                          );
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "Unable to Resume",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 14.0,
                                          );
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "No Data Found",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 14.0,
                                        );
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Unable to Retrieve User Data",
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
                                    foregroundColor: Colors.white,
                                    backgroundColor: Color(0xFF00224F),
                                    // Text color of the button
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 24),
                                    // Button padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12), // Rounded corners
                                    ),
                                  ),
                                  child: Text(
                                    'Resume', // Button text
                                    style: TextStyle(
                                      fontSize: 16, // Text size
                                      fontWeight: FontWeight.bold, // Text style
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Resume Topic Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(12.0),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            final userId = user?.uid;

                            if (userId != null) {
                              final dbRef = FirebaseDatabase.instance
                                  .ref('analytics/$userId');
                              final snapshot = await dbRef.get();

                              if (snapshot.exists) {
                                final data =
                                    snapshot.value as Map<dynamic, dynamic>;

                                final path = data['textPath']?.toString() ?? '';
                                final screen = data['screen']?.toInt() ?? 0;

                                if (path.isNotEmpty) {
                                  if (screen == 1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TextScreen(path: path),
                                      ),
                                    );
                                  } else if (screen == 2) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SummaryScreen(path: path),
                                      ),
                                    );
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Unable to Resume Topic",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 14.0,
                                  );
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg: "No Data Found",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 14.0,
                                );
                              }
                            } else {
                              Fluttertoast.showToast(
                                msg: "Unable to Retrieve User Data",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 14.0,
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFff9a62),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.document_copy,
                                  size: 28,
                                  color: const Color(0xFF00224F),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Resume Recent Topic',
                                  style: TextStyle(
                                    color: const Color(0xFF00224F),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.chevron_right,
                                  color: const Color(0xFF00224F),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Resume Reel Button
                    Material(
                      borderRadius: BorderRadius.circular(12.0),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          final userId = user?.uid;

                          if (userId != null) {
                            final dbRef = FirebaseDatabase.instance
                                .ref('analytics/$userId');
                            final snapshot = await dbRef.get();

                            if (snapshot.exists) {
                              final data =
                                  snapshot.value as Map<dynamic, dynamic>;

                              final path = data['reelsPath']?.toString() ?? '';

                              if (path.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReelsScreen(
                                      summaryText: '',
                                      path: path,
                                    ),
                                  ),
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Unable to Resume Reels",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 14.0,
                                );
                              }
                            } else {
                              Fluttertoast.showToast(
                                msg: "No Data Found",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 14.0,
                              );
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: "Unable to Retrieve User Data",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF93dafa),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 28,
                                color: const Color(0xFF00224F),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Resume Previous Reels',
                                style: TextStyle(
                                  color: const Color(0xFF00224F),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: const Color(0xFF00224F),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
