// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: json['id'] as String,
  content: json['content'] as String,
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.sent,
  metadata: json['metadata'] as Map<String, dynamic>?,
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  thinkingProcess: json['thinkingProcess'] == null
      ? null
      : ThinkingProcessModel.fromJson(
          json['thinkingProcess'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$MessageStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
      'attachments': instance.attachments,
      'thinkingProcess': instance.thinkingProcess,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.failed: 'failed',
};

AttachmentModel _$AttachmentModelFromJson(Map<String, dynamic> json) =>
    AttachmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      size: (json['size'] as num).toInt(),
      path: json['path'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$AttachmentModelToJson(AttachmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'path': instance.path,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
    };

ThinkingProcessModel _$ThinkingProcessModelFromJson(
  Map<String, dynamic> json,
) => ThinkingProcessModel(
  id: json['id'] as String,
  steps: (json['steps'] as List<dynamic>)
      .map((e) => ThinkingStepModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  isComplete: json['isComplete'] as bool,
  startedAt: DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  status: json['status'] as String? ?? 'thinking',
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
);

Map<String, dynamic> _$ThinkingProcessModelToJson(
  ThinkingProcessModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'steps': instance.steps,
  'isComplete': instance.isComplete,
  'startedAt': instance.startedAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'status': instance.status,
  'endTime': instance.endTime?.toIso8601String(),
};

ThinkingStepModel _$ThinkingStepModelFromJson(Map<String, dynamic> json) =>
    ThinkingStepModel(
      id: json['id'] as String,
      stepNumber: (json['stepNumber'] as num).toInt(),
      message: json['message'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRevision: json['isRevision'] as bool? ?? false,
      revisesStep: (json['revisesStep'] as num?)?.toInt(),
      content: json['content'] as String,
    );

Map<String, dynamic> _$ThinkingStepModelToJson(ThinkingStepModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stepNumber': instance.stepNumber,
      'message': instance.message,
      'type': instance.type,
      'timestamp': instance.timestamp.toIso8601String(),
      'isRevision': instance.isRevision,
      'revisesStep': instance.revisesStep,
      'content': instance.content,
    };

ChatSessionModel _$ChatSessionModelFromJson(Map<String, dynamic> json) =>
    ChatSessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      settings: json['settings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChatSessionModelToJson(ChatSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'messages': instance.messages,
      'settings': instance.settings,
    };
