import '../../../../core/constants/algerian_education_constants.dart';

enum UserRole {
  admin,
  teacher,
  student,
  parent;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'parent':
        return UserRole.parent;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? teacherId;
  final String? studentId;
  final List<String> teachingLevels;
  final List<String> teachingYears;
  final List<String> teachingSubjects;
  final List<String> permissions;
  final String? token;
  final String? avatarUrl;
  final int? yearsOfExperience;
  final String? headline;
  final String? bio;
  final int? wilaya;
  final String? academicLevel;
  final String? stream;
  final String? guardianLinkCode;
  final bool isVerified;
  final String? verificationStatus;
  final String? verifiedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.teacherId,
    this.studentId,
    this.teachingLevels = const [],
    this.teachingYears = const [],
    this.teachingSubjects = const [],
    this.permissions = const [],
    this.token,
    this.avatarUrl,
    this.yearsOfExperience,
    this.headline,
    this.bio,
    this.wilaya,
    this.academicLevel,
    this.stream,
    this.guardianLinkCode,
    this.isVerified = false,
    this.verificationStatus,
    this.verifiedAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;
  bool get isParent => role == UserRole.parent;

  bool get isTeacherVerified => isTeacher && isVerified;

  String get wilayaName => AlgerianEducationConstants.getWilayaName(wilaya);

  bool hasPermission(String permission) =>
      isAdmin || permissions.contains(permission);

  User copyWith({
    int? id,
    String? name,
    String? email,
    UserRole? role,
    String? teacherId,
    String? studentId,
    List<String>? teachingLevels,
    List<String>? teachingYears,
    List<String>? teachingSubjects,
    List<String>? permissions,
    String? token,
    String? avatarUrl,
    int? yearsOfExperience,
    String? headline,
    String? bio,
    int? wilaya,
    String? academicLevel,
    String? stream,
    String? guardianLinkCode,
    bool? isVerified,
    String? verificationStatus,
    String? verifiedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      teacherId: teacherId ?? this.teacherId,
      studentId: studentId ?? this.studentId,
      teachingLevels: teachingLevels ?? this.teachingLevels,
      teachingYears: teachingYears ?? this.teachingYears,
      teachingSubjects: teachingSubjects ?? this.teachingSubjects,
      permissions: permissions ?? this.permissions,
      token: token ?? this.token,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      wilaya: wilaya ?? this.wilaya,
      academicLevel: academicLevel ?? this.academicLevel,
      stream: stream ?? this.stream,
      guardianLinkCode: guardianLinkCode ?? this.guardianLinkCode,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
