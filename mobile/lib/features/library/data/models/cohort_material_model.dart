import '../../domain/entities/cohort_material_entity.dart';

class CohortMaterialModel extends CohortMaterialEntity {
  const CohortMaterialModel({
    required super.id,
    required super.materialCode,
    required super.title,
    super.description,
    required super.fileType,
    required super.fileSizeBytes,
    required super.downloadsCount,
    required super.createdAt,
    required super.isAccessible,
  });

  factory CohortMaterialModel.fromJson(Map<String, dynamic> json) {
    return CohortMaterialModel(
      id: json['id'] as int? ?? 0,
      materialCode: json['material_code'] as String? ?? '',
      title: json['title'] as String? ?? 'Educational Document',
      description: json['description'] as String?,
      fileType: json['file_type'] as String? ?? 'pdf',
      fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
      downloadsCount: json['downloads_count'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      isAccessible: json['is_accessible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_code': materialCode,
      'title': title,
      'description': description,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'downloads_count': downloadsCount,
      'created_at': createdAt,
      'is_accessible': isAccessible,
    };
  }
}
