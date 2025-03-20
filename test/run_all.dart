import 'dart:io';

void main() {
  final List<String> testFiles = [
    'test/books_page.dart',
    'test/book_upload.dart',
    'test/take_quiz.dart',
    'test/user_login.dart',
    'test/user_profile.dart',
    'test/user_registeration.dart',
    'test/view_explanation.dart',
    'test/view_reels.dart',
    'test/view_summary.dart',
  ];

  for (var testFile in testFiles) {
    print('Running test: $testFile');

    var result = Process.runSync(
      'C:\\flutter\\src\\flutter\\bin\\flutter.bat', // Replace this with the correct Flutter path
      ['test', testFile],
    );

    print(result.stdout);
    print(result.stderr);

    if (result.exitCode != 0) {
      exit(result.exitCode);
    }
  }
}
