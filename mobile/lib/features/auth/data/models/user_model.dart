import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.teacherId,
    super.studentId,
    super.teachingLevels,
    super.teachingYears,
    super.teachingSubjects,
    super.permissions,
    super.token,
    super.avatarUrl,
    super.yearsOfExperience,
    super.headline,
    super.bio,
    super.wilaya,
    super.academicLevel,
    super.stream,
    super.guardianLinkCode,
    super.isVerified,
    super.verificationStatus,
    super.verifiedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final permissionsRaw = json['permissions'];
    List<String> permissionsList = [];
    if (permissionsRaw is List) {
      permissionsList = permissionsRaw.map((p) => p.toString()).toList();
    }

    final levelsRaw = json['teaching_levels'];
    List<String> levelsList = [];
    if (levelsRaw is List) {
      levelsList = levelsRaw.map((l) => l.toString()).toList();
    }

    final yearsRaw = json['teaching_years'];
    List<String> yearsList = [];
    if (yearsRaw is List) {
      yearsList = yearsRaw.map((y) => y.toString()).toList();
    }

    final subjectsRaw = json['teaching_subjects'];
    List<String> subjectsList = [];
    if (subjectsRaw is List) {
      subjectsList = subjectsRaw.map((s) => s.toString()).toList();
    }

    final expRaw = json['years_of_experience'];
    final exp = expRaw is num ? expRaw.toInt() : int.tryParse(expRaw?.toString() ?? '');
    final avatar = json['avatar_url']?.toString();

    final wilayaRaw = json['wilaya'];
    final wilaya = wilayaRaw is num ? wilayaRaw.toInt() : int.tryParse(wilayaRaw?.toString() ?? '');

    final isVerifiedRaw = json['is_verified'];
    final isVerified = isVerifiedRaw == true || isVerifiedRaw == 1 || isVerifiedRaw == '1';

    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      teacherId: json['teacher_id'] as String?,
      studentId: json['student_id'] as String?,
      teachingLevels: levelsList,
      teachingYears: yearsList,
      teachingSubjects: subjectsList,
      permissions: permissionsList,
      token: token,
      avatarUrl: (avatar != null && avatar.trim().isNotEmpty) ? avatar : null,
      yearsOfExperience: exp,
      headline: json['headline'] as String?,
      bio: json['bio'] as String?,
      wilaya: wilaya,
      academicLevel: json['academic_level'] as String?,
      stream: json['stream'] as String?,
      guardianLinkCode: json['guardian_link_code'] as String?,
      isVerified: isVerified,
      verificationStatus: json['verification_status'] as String?,
      verifiedAt: json['verified_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'teacher_id': teacherId,
      'student_id': studentId,
      'teaching_levels': teachingLevels,
      'teaching_years': teachingYears,
      'teaching_subjects': teachingSubjects,
      'permissions': permissions,
      'token': token,
      'avatar_url': avatarUrl,
      'years_of_experience': yearsOfExperience,
      'headline': headline,
      'bio': bio,
      'wilaya': wilaya,
      'academic_level': academicLevel,
      'stream': stream,
      'guardian_link_code': guardianLinkCode,
      'is_verified': isVerified,
      'verification_status': verificationStatus,
      'verified_at': verifiedAt,
    };
  }

  UserModel copyWithToken(String newToken) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      role: role,
      teacherId: teacherId,
      studentId: studentId,
      teachingLevels: teachingLevels,
      teachingYears: teachingYears,
      teachingSubjects: teachingSubjects,
      permissions: permissions,
      token: newToken,
      avatarUrl: avatarUrl,
      yearsOfExperience: yearsOfExperience,
      headline: headline,
      bio: bio,
      wilaya: wilaya,
      academicLevel: academicLevel,
      stream: stream,
      guardianLinkCode: guardianLinkCode,
      isVerified: isVerified,
      verificationStatus: verificationStatus,
      verifiedAt: verifiedAt,
    );
  }
}
