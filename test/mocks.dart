import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

@GenerateMocks([FirebaseAuth, FirebaseDatabase, DatabaseReference, DataSnapshot, User, UserCredential])
void main() {} // This is required for mock generation