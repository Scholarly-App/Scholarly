import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scholarly_app/Application_Tier/AuthenticationHandler.dart';
import 'mocks.mocks.dart';

void main() {
  late AuthenticationHandler authHandler;
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    authHandler = AuthenticationHandler();
  });

  group('User Login', () {
    test('should login user successfully', () async {
      // Arrange: Mock Firebase Auth signInWithEmailAndPassword
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('mock_uid');

      // Act: Call loginUser
      final result = await authHandler.loginUser(
        'abc@example.com',
        'password123',
      );

      // Assert
      expect(result, true);
    });

    test('should fail login when incorrect password is used', () async {
      // Arrange: Mock Firebase Auth throwing an exception
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // Act
      final result = await authHandler.loginUser(
        'abc@example.com',
        'wrongpassword',
      );

      // Assert
      expect(result, false);
    });

    test('should fail login when user does not exist', () async {
      // Arrange: Mock Firebase Auth throwing user-not-found exception
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Act
      final result = await authHandler.loginUser(
        'notregistered@example.com',
        'password123',
      );

      // Assert
      expect(result, false);
    });
  });
}
