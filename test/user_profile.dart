import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:scholarly_app/Application_Tier/AuthenticationHandler.dart';
import 'package:scholarly_app/Presentation_Tier/homepage/home_screen.dart';
import 'package:scholarly_app/Presentation_Tier/userprofile/userprofile_screen.dart';
import 'mocks.mocks.dart';
void main() {
  late AuthenticationHandler authHandler;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    authHandler = AuthenticationHandler();
  });

  group('View User Profile', () {
    testWidgets('should redirect to profile screen when user clicks on profile button', (WidgetTester tester) async {
      // Arrange: Mock a logged-in user
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('mock_uid');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');

      // Build the HomeScreen
      await tester.pumpWidget(HomeScreen());

      // Act: Tap on the Profile button in the bottom navigation
      final Finder profileButton = find.byIcon(Icons.person);
      await tester.tap(profileButton);
      await tester.pumpAndSettle(); // Wait for navigation

      // Assert: Verify that the ProfileScreen is displayed
      expect(find.byType(UserProfileScreen), findsOneWidget);

      // Verify user details are displayed
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}
