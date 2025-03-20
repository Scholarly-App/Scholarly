import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:scholarly_app/Application_Tier/BookManager.dart';
import 'mocks.mocks.dart'; // Auto-generated mock file

@GenerateMocks([FirebaseAuth, FirebaseDatabase, DatabaseReference, DataSnapshot, User])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseDatabase mockDatabase;
  late MockDatabaseReference mockRef;
  late MockDataSnapshot mockSnapshot;
  late BookManager bookManager;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockDatabase = MockFirebaseDatabase();
    mockRef = MockDatabaseReference();
    mockSnapshot = MockDataSnapshot();
    bookManager = BookManager();
  });

  test("User can view summary after navigating", () async {
    // Mock user authentication
    final mockUser = MockUser();
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn("testUser123");

    // Mock Database Reference
    when(mockDatabase.ref(any)).thenReturn(mockRef);
    when(mockRef.child(any)).thenReturn(mockRef);
    when(mockRef.get()).thenAnswer((_) async => mockSnapshot);

    // Mocking roadmap and summary data
    when(mockSnapshot.exists).thenReturn(true);
    when(mockSnapshot.value).thenReturn({
      "I Foundations": {
        "1 The Role of Algorithms in Computing": {
          "summary": "This is the explanation text."
        }
      }
    });

    // Fetch summary
    final summary = await bookManager.fetchBooks();
    expect(summary, isNotEmpty);
    expect(summary.contains("summary"), isTrue);
    // expect(summary["Chapter 1"]["Topic 1"]["summary"], equals("This is the summary text."));

  });
}
