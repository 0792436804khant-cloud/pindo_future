class CohortMaterialEntity {
  final int id;
  final String materialCode;
  final String title;
  final String? description;
  final String fileType;
  final int fileSizeBytes;
  final int downloadsCount;
  final String createdAt;
  final bool isAccessible;

  const CohortMaterialEntity({
    required this.id,
    required this.materialCode,
    required this.title,
    this.description,
    required this.fileType,
    required this.fileSizeBytes,
    required this.downloadsCount,
    required this.createdAt,
    required this.isAccessible,
  });

  String get formattedFileSize {
    if (fileSizeBytes <= 0) return 'PDF';
    final kb = fileSizeBytes / 1024;
    if (kb >= 1024) {
      final mb = kb / 1024;
      return '${mb.toStringAsFixed(1)} MB';
    }
    return '${kb.toStringAsFixed(0)} KB';
  }
}
