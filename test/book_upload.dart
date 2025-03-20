import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:scholarly_app/Application_Tier/BookManager.dart';
import 'mocks.mocks.dart';

void main() {
  late BookManager bookManager;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseDatabase mockDatabase;
  late MockUser mockUser;
  late MockDatabaseReference mockDbRef;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockDatabase = MockFirebaseDatabase();
    mockUser = MockUser();
    mockDbRef = MockDatabaseReference();

    bookManager = BookManager();

    // Mock a logged-in user
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('mock_uid');

    // Mock Firebase Database Reference
    when(mockDatabase.ref(any)).thenReturn(mockDbRef);
    when(mockDbRef.set(any)).thenAnswer((_) async => Future.value());
  });

  group('Book Upload', () {
    test('should upload book successfully', () async {
      // Arrange
      final String bookTitle = "Sample Book";
      final String userId = mockUser.uid;

      // Act
      await bookManager.updateBookName('',bookTitle);

      // Assert
      verify(mockDbRef.set(any)).called(1);
    });

    test('should fail book upload if no user is logged in', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);
      final String bookTitle = "Sample Book";

      // Act & Assert
      expect(() => bookManager.updateBookName('',bookTitle), throwsException);
    });
  });
}
