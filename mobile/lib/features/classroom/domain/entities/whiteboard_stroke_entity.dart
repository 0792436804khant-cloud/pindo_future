enum WhiteboardTool {
  pen,
  highlighter,
  eraser,
  rectangle,
  circle,
  line,
  arrow,
  text,
}

class WhiteboardPoint {
  final double x; // Normalized 0.0 to 1.0
  final double y; // Normalized 0.0 to 1.0

  const WhiteboardPoint({required this.x, required this.y});

  Map<String, dynamic> toJson() => {
        'x': double.parse(x.toStringAsFixed(4)),
        'y': double.parse(y.toStringAsFixed(4)),
      };

  factory WhiteboardPoint.fromJson(Map<String, dynamic> json) {
    return WhiteboardPoint(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WhiteboardStrokeEntity {
  final String id;
  final WhiteboardTool tool;
  final int colorValue;
  final double strokeWidth;
  final List<WhiteboardPoint> points;
  final String? text;
  final String authorIdentity;
  final String authorName;
  final DateTime timestamp;

  const WhiteboardStrokeEntity({
    required this.id,
    required this.tool,
    required this.colorValue,
    required this.strokeWidth,
    required this.points,
    this.text,
    required this.authorIdentity,
    required this.authorName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tool': tool.name,
        'color_value': colorValue,
        'stroke_width': strokeWidth,
        'points': points.map((p) => p.toJson()).toList(),
        if (text != null) 'text': text,
        'author_identity': authorIdentity,
        'author_name': authorName,
        'timestamp': timestamp.toIso8601String(),
      };

  factory WhiteboardStrokeEntity.fromJson(Map<String, dynamic> json) {
    final toolStr = json['tool'] as String? ?? 'pen';
    WhiteboardTool resolvedTool;
    try {
      resolvedTool = WhiteboardTool.values.byName(toolStr);
    } catch (_) {
      resolvedTool = WhiteboardTool.pen;
    }

    final rawPoints = json['points'] as List<dynamic>? ?? [];
    final points = rawPoints
        .whereType<Map<String, dynamic>>()
        .map((p) => WhiteboardPoint.fromJson(p))
        .toList();

    DateTime ts;
    try {
      ts = DateTime.parse(json['timestamp'] as String? ?? '');
    } catch (_) {
      ts = DateTime.now();
    }

    return WhiteboardStrokeEntity(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      tool: resolvedTool,
      colorValue: json['color_value'] as int? ?? 0xFF0D9488,
      strokeWidth: (json['stroke_width'] as num?)?.toDouble() ?? 4.0,
      points: points,
      text: json['text'] as String?,
      authorIdentity: json['author_identity'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Participant',
      timestamp: ts,
    );
  }
}
