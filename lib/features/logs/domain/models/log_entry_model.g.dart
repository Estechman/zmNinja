// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => LogEntry(
  id: json['id'] as String,
  level: $enumDecode(_$LogLevelEnumMap, json['level']),
  message: json['message'] as String,
  source: json['source'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  details: json['details'] as String?,
  stackTrace: json['stackTrace'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$LogEntryToJson(LogEntry instance) => <String, dynamic>{
  'id': instance.id,
  'level': _$LogLevelEnumMap[instance.level]!,
  'message': instance.message,
  'source': instance.source,
  'timestamp': instance.timestamp.toIso8601String(),
  'details': instance.details,
  'stackTrace': instance.stackTrace,
  'metadata': instance.metadata,
};

const _$LogLevelEnumMap = {
  LogLevel.debug: 'debug',
  LogLevel.info: 'info',
  LogLevel.warning: 'warning',
  LogLevel.error: 'error',
  LogLevel.fatal: 'fatal',
};
