import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scholarly_app/Presentation_Tier/bookspage/roadmap_screen.dart';
import '../../Application_Tier/BookManager.dart';

class BooksScreen extends StatefulWidget {
  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final BookManager _bookManager = BookManager();
  List<String> books = [];
  bool _isLoading = true;

  // Predefined colors for book icons
  final List<Color> bookColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
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


  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final fetchedBooks = await _bookManager.fetchBooks();
      setState(() {
        books = fetchedBooks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteBook(String bookTitle) async {
    try {
      await _bookManager.deleteBook(bookTitle);
      setState(() {
        books.remove(bookTitle);
      });
      Fluttertoast.showToast(msg: "$bookTitle deleted successfully.");
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  Future<void> updateBookName(String oldName, String newName) async {
    try {
      await _bookManager.updateBookName(oldName, newName);
      setState(() {
        final index = books.indexOf(oldName);
        if (index != -1) {
          books[index] = newName;
        }
      });
      Fluttertoast.showToast(msg: "$oldName renamed to $newName.");
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  void showEditDialog(String oldName) {
    final TextEditingController nameController =
        TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Book Name"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                Navigator.pop(context); // Close the dialog
                updateBookName(oldName, newName);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmationDialog(String bookTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Book"),
        content: Text("Are you sure you want to delete $bookTitle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              deleteBook(bookTitle); // Delete the book
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToRoadmap(String bookTitle) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String? userId = _auth.currentUser?.uid;

    await dbRef.child('analytics/$userId').update({
      'bookTitle': bookTitle,
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoadmapScreen(bookTitle: bookTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                    // onTap: () => Navigator.pop(context),
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
                      'User Books',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : books.isEmpty
              ? const Center(
                  child: Text(
                    "No books available.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          bookColors[index % bookColors.length],
                                    ),
                                    child: Transform.translate(
                                      offset: const Offset(0, -4),
                                      child: Image.asset(
                                        books_list[index % books_list.length],
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // child: Image.asset(
                                    //   books_list[index % bookColors.length],
                                    //   width: 24,
                                    //   height: 24,
                                    //   fit: BoxFit.cover,
                                    // ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      books[index],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.05,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        navigateToRoadmap(books[index]),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Roadmap",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        showEditDialog(books[index]),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Edit",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        showDeleteConfirmationDialog(
                                            books[index]),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
