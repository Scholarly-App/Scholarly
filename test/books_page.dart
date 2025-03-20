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
  late MockDataSnapshot mockSnapshot;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockDatabase = MockFirebaseDatabase();
    mockUser = MockUser();
    mockDbRef = MockDatabaseReference();
    mockSnapshot = MockDataSnapshot();

    bookManager = BookManager();

    // Mock a logged-in user
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('mock_uid');

    // Mock Firebase Database Reference
    when(mockDatabase.ref(any)).thenReturn(mockDbRef);
    when(mockDbRef.get()).thenAnswer((_) async => mockSnapshot);
  });

  group('Fetch Books', () {
    test('should fetch books successfully and return book list', () async {
      // Arrange
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.value).thenReturn({
        'Book A': {'count': 2},
        'Book B': {'count': 5},
        'Book C': {'count': 3},
      });

      // Act
      final books = await bookManager.fetchBooks();

      // Assert
      expect(books, equals(['Book B', 'Book C', 'Book A'])); // Sorted order
      verify(mockDbRef.get()).called(1);
    });

    test('should return an empty list if no books are found', () async {
      // Arrange
      when(mockSnapshot.exists).thenReturn(false);

      // Act
      final books = await bookManager.fetchBooks();

      // Assert
      expect(books, equals([]));
      verify(mockDbRef.get()).called(1);
    });

    test('should throw an error if user is not logged in', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(() => bookManager.fetchBooks(), throwsException);
    });
  });
}
