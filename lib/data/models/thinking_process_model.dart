class ThinkingProcessModel {
  final String id;
  final String step;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  const ThinkingProcessModel({
    required this.id,
    required this.step,
    required this.description,
    required this.timestamp,
    this.isCompleted = false,
  });

  factory ThinkingProcessModel.fromJson(Map<String, dynamic> json) {
    return ThinkingProcessModel(
      id: json['id'] as String,
      step: json['step'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'step': step,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  ThinkingProcessModel copyWith({
    String? id,
    String? step,
    String? description,
    DateTime? timestamp,
    bool? isCompleted,
  }) {
    return ThinkingProcessModel(
      id: id ?? this.id,
      step: step ?? this.step,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThinkingProcessModel &&
        other.id == id &&
        other.step == step &&
        other.description == description &&
        other.timestamp == timestamp &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(id, step, description, timestamp, isCompleted);
  }

  @override
  String toString() {
    return 'ThinkingProcessModel(id: $id, step: $step, description: $description, timestamp: $timestamp, isCompleted: $isCompleted)';
  }
}
