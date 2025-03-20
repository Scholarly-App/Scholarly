class UserModel {
  final String name;
  final String email;
  final String contact;
  final String dob;
  final String gender;

  UserModel({
    required this.name,
    required this.email,
    required this.contact,
    required this.dob,
    required this.gender,
  });

  // Factory method to create a UserModel from a Map (Firebase snapshot)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      contact: map['contact'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? '',
    );
  }
}