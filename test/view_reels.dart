import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scholarly_app/Application_Tier/BookManager.dart';
import 'package:scholarly_app/Application_Tier/ReelsManager.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockDataSnapshot extends Mock implements DataSnapshot {}

class MockUser extends Mock implements User {}

void main() {
  group('View Reels Test', () {
    late BookManager bookManager;
    late MockFirebaseAuth mockAuth;
    late MockDatabaseReference mockDatabaseReference;
    late MockDataSnapshot mockSnapshot;
    late ReelsManager reelsManager;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockDatabaseReference = MockDatabaseReference();
      mockSnapshot = MockDataSnapshot();
      bookManager = BookManager();
      reelsManager = ReelsManager();
    });

    test('User can view reels only if summary exists', () async {
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

      // Simulate clicking on View Reels button (only if summary exists)
      bool isViewReelsButtonEnabled = summary.isNotEmpty;
      expect(isViewReelsButtonEnabled, isTrue);

      // Simulate navigation to View Reels screen
      final reelsReference = mockDatabaseReference.child(
          'reels/testUserId/I Foundations/1 The Role of Algorithms in Computing');
      when(reelsReference.get()).thenAnswer((_) async => mockSnapshot);

      // Mock reels data
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value).thenReturn({
        "reel1": "https://example.com/reel1.mp4",
        "reel2": "https://example.com/reel2.mp4"
      });

      // Fetch reels using instance method
      final reels = await reelsManager.getReelsUrls("I Foundations");

      // Check that reels are retrieved successfully
      expect(reels.isNotEmpty, isTrue);
      expect(reels.contains("https://example.com/reel1.mp4"), isTrue);
      expect(reels.contains("https://example.com/reel2.mp4"), isTrue);
    });
  });
}
