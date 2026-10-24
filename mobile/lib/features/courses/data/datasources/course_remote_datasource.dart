import '../../../../core/network/api_client.dart';

abstract class CourseRemoteDataSource {
  Future<List<dynamic>> fetchTeacherCourses(String token);
  Future<Map<String, dynamic>> createCourse(String token, Map<String, dynamic> body);
  Future<void> deleteCourse(String token, int courseId);
  Future<Map<String, dynamic>> fetchCourseDetails(int courseId, {String? token});
  Future<Map<String, dynamic>> addModule(String token, int courseId, String title, int? order);
  Future<Map<String, dynamic>> addLesson(String token, int moduleId, Map<String, dynamic> body);

  Future<Map<String, dynamic>> fetchTeacherPublicShowcase(String teacherId);
  Future<List<dynamic>> fetchPublicCourses({String? category, String? search});

  Future<List<dynamic>> fetchStudentEnrolledCourses(String token);
  Future<Map<String, dynamic>> enrollInCourse(String token, int courseId);
  Future<void> updateCourseProgress(String token, int courseId, int progressPercentage);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final ApiClient apiClient;

  CourseRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> fetchTeacherCourses(String token) async {
    final response = await apiClient.get('/teacher/courses', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> createCourse(String token, Map<String, dynamic> body) async {
    final response = await apiClient.post('/teacher/courses', body: body, token: token);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<void> deleteCourse(String token, int courseId) async {
    await apiClient.delete('/teacher/courses/$courseId', token: token);
  }

  @override
  Future<Map<String, dynamic>> fetchCourseDetails(int courseId, {String? token}) async {
    // If teacher, can fetch from /teacher/courses/$courseId, else /courses/$courseId
    final endpoint = token != null ? '/teacher/courses/$courseId' : '/courses/$courseId';
    final response = await apiClient.get(endpoint, token: token);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<Map<String, dynamic>> addModule(String token, int courseId, String title, int? order) async {
    final body = {
      'title': title,
      if (order != null) 'order': order,
    };
    final response = await apiClient.post('/teacher/courses/$courseId/modules', body: body, token: token);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<Map<String, dynamic>> addLesson(String token, int moduleId, Map<String, dynamic> body) async {
    final response = await apiClient.post('/teacher/modules/$moduleId/lessons', body: body, token: token);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<Map<String, dynamic>> fetchTeacherPublicShowcase(String teacherId) async {
    final response = await apiClient.get('/teachers/$teacherId/public');
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<List<dynamic>> fetchPublicCourses({String? category, String? search}) async {
    String endpoint = '/courses';
    final queryParams = <String>[];
    if (category != null && category.isNotEmpty) {
      queryParams.add('category=${Uri.encodeComponent(category)}');
    }
    if (search != null && search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
    }
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await apiClient.get(endpoint);
    final data = response['data'];
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List<dynamic>?) ?? [];
    }
    return (data as List<dynamic>?) ?? [];
  }

  @override
  Future<List<dynamic>> fetchStudentEnrolledCourses(String token) async {
    final response = await apiClient.get('/student/courses', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> enrollInCourse(String token, int courseId) async {
    final response = await apiClient.post('/courses/$courseId/enroll', token: token);
    return (response['enrollment'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<void> updateCourseProgress(String token, int courseId, int progressPercentage) async {
    await apiClient.post(
      '/courses/$courseId/progress',
      body: {'progress_percentage': progressPercentage},
      token: token,
    );
  }
}
