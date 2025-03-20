import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scholarly_app/Application_Tier/AuthenticationHandler.dart';
import 'mocks.mocks.dart';

void main() {
  late AuthenticationHandler authHandler;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseDatabase mockDatabase;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockDatabaseReference mockDbRef;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockDatabase = MockFirebaseDatabase();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockDbRef = MockDatabaseReference();

    authHandler = AuthenticationHandler();
  });

  group('User Registration', () {
    test('should register user successfully', () async {
      // Arrange: Mock Firebase Auth
      when(mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('mock_uid');

      // Mock Database Reference
      when(mockDatabase.ref(any)).thenReturn(mockDbRef);
      when(mockDbRef.set(any)).thenAnswer((_) async => Future.value());

      // Act: Call registerUser
      final result = await authHandler.registerUser(
        'abc@example.com',
        'password123',
        'Test User',
        '01-01-2000',
        '123456789',
        'Male',
      );

      // Assert
      expect(result, true);
    });

    test('should fail registration when email is already in use', () async {
      // Arrange
      when(mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      // Act
      final result = await authHandler.registerUser(
        'test@example.com',
        'password123',
        'Test User',
        '01-01-2000',
        '123456789',
        'Male',
      );

      // Assert
      expect(result, false);
    });
  });
}


// group('User Registration', () {
// test('should register user successfully', () async {
// expect(true, true); // Always pass test
// });
//
// test('should fail registration when email is already in use', () async {
// expect(true, true); // Always pass test
// });
// });