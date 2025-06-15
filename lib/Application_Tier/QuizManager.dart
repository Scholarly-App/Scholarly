import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
class QuizManager {
  final String baseUrl = '${AppConfig.baseUrl}:5004/generate';

  Future<bool> generateQuiz({
    required String summary,
    required String count,
    required String path,
  }) async {
    final Uri url = Uri.parse(baseUrl);

    final Map<String, dynamic> data = {
      'text': summary,
      'count': count,
      'path': path,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // Check if response is successful (status code 200)
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('questions')) {
          List<dynamic> questions = responseData['questions'];

          // Store questions in Firebase
          bool status = await saveQuestionsToFirebase(path, questions);
          if (status == true) {
            return true;
          } else {
            return false;
          }
        }
      } else {
        print('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
    return false;
  }

  Future<bool> saveQuestionsToFirebase(
      String path, List<dynamic> questions) async {
    final FirebaseDatabase _database = FirebaseDatabase.instance;
    DatabaseReference ref = _database.ref(path);

    try {
      await ref.update({
        "quiz": questions,
        "score": 0,
      });
      return true;
    } catch (e) {
      print("Failed to save quiz to Firebase: $e");
      return false;
    }
  }
}
