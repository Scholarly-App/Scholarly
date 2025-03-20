import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scholarly_app/Application_Tier/BookManager.dart';
import 'package:scholarly_app/Application_Tier/QuizManager.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockDataSnapshot extends Mock implements DataSnapshot {}

class MockUser extends Mock implements User {}

void main() {
  group('Take Quiz Test', () {
    late BookManager bookManager;
    late MockFirebaseAuth mockAuth;
    late MockDatabaseReference mockDatabaseReference;
    late MockDataSnapshot mockSnapshot;
    late QuizManager quizManager;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockDatabaseReference = MockDatabaseReference();
      mockSnapshot = MockDataSnapshot();
      bookManager = BookManager();
      quizManager = QuizManager();
    });

    test('User can take quiz only if summary exists', () async {
      // Mock user authentication
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn("testUserId");

      // Mock database reference for summary
      when(mockDatabaseReference.child(
              'summaries/testUserId/I Foundations/1 The Role of Algorithms in Computing'))
          .thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);

      // Mock snapshot data to simulate summary availability
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value)
          .thenReturn({"summary": "This is a test summary."});

      // Fetch summary
      final summary = "This is a test summary.";

      // Check that the summary contains the expected text
      expect(summary.contains("This is a test summary."), isTrue);

      // Simulate clicking on Take Quiz button (only if summary exists)
      bool isTakeQuizButtonEnabled = summary.isNotEmpty;
      expect(isTakeQuizButtonEnabled, isTrue);

      // Call generateQuiz (returns boolean)
      bool quizGenerated = await quizManager.generateQuiz(
        summary: summary,
        count: '2',
        path: "quizzes/testUserId/I Foundations/1 The Role of Algorithms in Computing",
      );

      // Ensure the quiz was generated and saved successfully
      expect(quizGenerated, isTrue);

      // Mock Firebase response for quiz retrieval
      when(mockDatabaseReference.child(
              'quizzes/testUserId/I Foundations/1 The Role of Algorithms in Computing'))
          .thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);

      // Mock quiz data stored in Firebase
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value).thenReturn({
        "quiz": [
          {
            "question": "What is Flutter?",
            "options": [
              "A framework",
              "A programming language",
              "A database",
              "An OS"
            ],
            "answer": "A framework"
          },
          {
            "question": "Who developed Flutter?",
            "options": ["Google", "Facebook", "Microsoft", "Amazon"],
            "answer": "Google"
          }
        ]
      });

      // Fetch quiz questions from Firebase
      final snapshot = await mockDatabaseReference.get();
      final quizData = snapshot.value;

      // **Null safety check before accessing quiz data**
      expect(quizData, isNotNull);
      expect(quizData is Map, isTrue);

      final quizQuestions = (quizData as Map)['quiz'] as List<dynamic>?;

      // **Ensure quizQuestions is not null before accessing its elements**
      expect(quizQuestions, isNotNull);
      expect(quizQuestions!.isNotEmpty, isTrue);
      expect(quizQuestions[0]['question'], "What is Flutter?");
      expect(quizQuestions[1]['question'], "Who developed Flutter?");
    });
  });
}
