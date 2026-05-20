// GROUP MEMBERS: [Full Names and Student Numbers]

enum UserRole {
  student,
  admin,
}

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String studentNumber;
  final UserRole role;
  final int? currentYearOfStudy;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentNumber,
    required this.role,
    this.currentYearOfStudy,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;
}