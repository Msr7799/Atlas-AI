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
  final List<ThinkingStepModel> steps;
  final bool isComplete;
  final DateTime startedAt;
  final DateTime? completedAt;

  ThinkingProcessModel({
    required this.steps,
    required this.isComplete,
    required this.startedAt,
    this.completedAt,
  });

  factory ThinkingProcessModel.fromJson(Map<String, dynamic> json) =>
      _$ThinkingProcessModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThinkingProcessModelToJson(this);

  ThinkingProcessModel copyWith({
    List<ThinkingStepModel>? steps,
    bool? isComplete,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return ThinkingProcessModel(
      steps: steps ?? this.steps,
      isComplete: isComplete ?? this.isComplete,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

@JsonSerializable()
class ThinkingStepModel {
  final int stepNumber;
  final String content;
  final DateTime timestamp;
  final bool isRevision;
  final int? revisesStep;

  ThinkingStepModel({
    required this.stepNumber,
    required this.content,
    required this.timestamp,
    this.isRevision = false,
    this.revisesStep,
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
