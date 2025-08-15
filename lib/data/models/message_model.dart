import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;
  final List<AttachmentModel>? attachments;
  final ThinkingProcessModel? thinkingProcess;

  MessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.metadata,
    this.attachments,
    this.thinkingProcess,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  // Getters for convenience
  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get isSystem => role == MessageRole.system;

  MessageModel copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
    List<AttachmentModel>? attachments,
    ThinkingProcessModel? thinkingProcess,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
      thinkingProcess: thinkingProcess ?? this.thinkingProcess,
    );
  }
}

enum MessageRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
}

enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('failed')
  failed,
}

@JsonSerializable()
class AttachmentModel {
  final String id;
  final String name;
  final String type;
  final int size;
  final String path;
  final DateTime uploadedAt;

  AttachmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.path,
    required this.uploadedAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentModelToJson(this);
}

@JsonSerializable()
class ThinkingProcessModel {
  final String id;
  final List<ThinkingStepModel> steps;
  final bool isComplete;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status;
  final DateTime? endTime;

  ThinkingProcessModel({
    required this.id,
    required this.steps,
    required this.isComplete,
    required this.startedAt,
    this.completedAt,
    this.status = 'thinking',
    this.endTime,
  });

  factory ThinkingProcessModel.fromJson(Map<String, dynamic> json) =>
      _$ThinkingProcessModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThinkingProcessModelToJson(this);

  ThinkingProcessModel copyWith({
    String? id,
    List<ThinkingStepModel>? steps,
    bool? isComplete,
    DateTime? startedAt,
    DateTime? completedAt,
    String? status,
    DateTime? endTime,
  }) {
    return ThinkingProcessModel(
      id: id ?? this.id,
      steps: steps ?? this.steps,
      isComplete: isComplete ?? this.isComplete,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      endTime: endTime ?? this.endTime,
    );
  }
}

@JsonSerializable()
class ThinkingStepModel {
  final String id;
  final int stepNumber;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRevision;
  final int? revisesStep;
  final String content; // إضافة خاصية content للتوافق مع الكود الموجود

  ThinkingStepModel({
    required this.id,
    required this.stepNumber,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRevision = false,
    this.revisesStep,
    required this.content, // إضافة content كمعامل مطلوب
  });

  factory ThinkingStepModel.fromJson(Map<String, dynamic> json) =>
      _$ThinkingStepModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThinkingStepModelToJson(this);
}

// Chat Session Model
@JsonSerializable()
class ChatSessionModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MessageModel> messages;
  final Map<String, dynamic>? settings;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.settings,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionModelToJson(this);

  ChatSessionModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MessageModel>? messages,
    Map<String, dynamic>? settings,
  }) {
    return ChatSessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      settings: settings ?? this.settings,
    );
  }
}
