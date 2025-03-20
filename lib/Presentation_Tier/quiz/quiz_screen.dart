import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scholarly_app/Application_Tier/QuizManager.dart';

class QuizScreen extends StatefulWidget {
  final String summaryText;
  final String path;

  const QuizScreen({Key? key, required this.summaryText, required this.path})
      : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool showMenu = false;
  bool isLoading = true;
  List<Map<String, dynamic>> quizQuestions = [];
  final QuizManager quizManager = QuizManager();

  PageController _pageController = PageController();
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool isSubmitted = false;
  int score = 0;
  int previousScore = 0;

  String selectedcount = '10';

  final List<String> count = ['5', '10', '15', '20', 'Maximum'];

  @override
  void initState() {
    super.initState();
    _checkQuizStatus();
  }

  void _checkQuizStatus() async {
    final FirebaseDatabase _database = FirebaseDatabase.instance;
    DatabaseReference ref = _database.ref(widget.path);

    DatabaseEvent event = await ref.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;

      if (data.containsKey('quiz')) {
        setState(() {
          showMenu = false;
          isLoading = false;
          // if (data['quiz'] is Map) {
          //   print("hello");
          //   quizQuestions = (data['quiz'] as Map<dynamic, dynamic>)
          //       .values
          //       .map((q) => Map<String, dynamic>.from(q as Map))
          //       .toList();
          // } else if (data['quiz'] is List) {
          //   quizQuestions = (data['quiz'] as List)
          //       .map((q) => Map<String, dynamic>.from(q as Map))
          //       .toList();
          // } else {
          //   quizQuestions = []; // Handle unexpected data format gracefully
          // }
          quizQuestions = (data['quiz'] as List)
              .map((q) => Map<String, dynamic>.from(q as Map))
              .toList();
          if (data.containsKey('score')) {
            previousScore = data['score'];
          }
        });
      } else {
        setState(() {
          showMenu = true;
          isLoading = false;
        });
      }
    }
  }

  void fun_generate_btn() async {
    if (selectedcount == 'Maximum') {
      selectedcount = '50';
    }
    bool status = await quizManager.generateQuiz(
      summary: widget.summaryText,
      count: selectedcount,
      path: widget.path,
    );

    if (status == true) {
      Fluttertoast.showToast(
        msg: "Quiz Generated Successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      await Future.delayed(Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      Fluttertoast.showToast(
        msg: "Unable to generate Quiz",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
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
                      'Take Quiz',
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
                  : _buildQuiz(screenWidth),
        ),
      ),
    );
  }

  void saveScores(int finalScore) async {
    bool confirm = await _showConfirmDialog();
    if (!confirm) return; // If user cancels, do nothing

    final FirebaseDatabase _database = FirebaseDatabase.instance;
    DatabaseReference ref = _database.ref(widget.path);

    try {
      await ref.update({
        "score": finalScore,
      });

      Fluttertoast.showToast(
        msg: "Quiz Saved Successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unable to save Quiz",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      debugPrint("Failed to save quiz to Firebase: $e");
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "Submit Quiz?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("Are you sure you want to submit your quiz?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ) ??
        false; // Return false if the dialog is dismissed
  }

  Widget _buildQuiz(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // Space between both widgets
            children: [
              // Previous Score (Left Side)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Prev Score: $previousScore/${quizQuestions.length}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Current Score (Right Side)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Score: $score/${quizQuestions.length}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: quizQuestions.length,
              onPageChanged: (index) {
                setState(() {
                  currentQuestionIndex = index;
                  selectedOption = null;
                  isSubmitted = false;
                });
              },
              itemBuilder: (context, index) {
                final question = quizQuestions[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question ${index + 1}/${quizQuestions.length}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      question['question'],
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    // Options List
                    ...List.generate(question['options'].length, (i) {
                      String option = question['options'][i];
                      bool isCorrect = option == question['answer'];

                      return GestureDetector(
                        onTap: () {
                          if (!isSubmitted) {
                            setState(() {
                              selectedOption = option;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSubmitted
                                ? (isCorrect
                                    ? Colors.green // Highlight correct answer
                                    : (selectedOption == option
                                        ? Colors.red // Highlight wrong answer
                                        : Colors.white))
                                : (selectedOption == option
                                    ? Colors.blueAccent // Selected option
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: (isSubmitted &&
                                      (isCorrect || selectedOption == option))
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Submit or Next Button
                    ElevatedButton(
                      onPressed: () {
                        if (!isSubmitted) {
                          if (selectedOption == null) {
                            Fluttertoast.showToast(
                              msg: "Please select an option",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                          } else {
                            // Check if the selected answer is correct
                            if (selectedOption == question['answer']) {
                              setState(() {
                                score++; // Update the score in UI
                              });
                            }

                            setState(() {
                              isSubmitted = true;
                            });
                          }
                        } else {
                          if (currentQuestionIndex < quizQuestions.length - 1) {
                            _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          } else {
                            saveScores(score); // Save final score
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isSubmitted
                            ? (currentQuestionIndex < quizQuestions.length - 1
                                ? "Next"
                                : "Finish")
                            : "Submit",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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
                Text('Generate Quiz'),
                SizedBox(height: 18),
                _buildSelectionTile('MCQ Count', selectedcount, count, (value) {
                  setState(() => selectedcount = value);
                }),
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
