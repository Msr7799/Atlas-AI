/// استثناءات مخصصة لتطبيق Atlas AI
/// Custom exceptions for Atlas AI application
library;

/// استثناء عام للتطبيق
/// Base application exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

/// استثناء تهيئة الخدمات
/// Service initialization exception
class ServiceInitializationException extends AppException {
  const ServiceInitializationException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ServiceInitializationException: $message';
}

/// استثناء تحميل الجلسات
/// Session loading exception
class SessionLoadException extends AppException {
  const SessionLoadException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'SessionLoadException: $message';
}

/// استثناء إدخال غير صحيح
/// Invalid input exception
class InvalidInputException extends AppException {
  const InvalidInputException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'InvalidInputException: $message';
}

/// استثناء تجاوز حد الرسائل
/// Rate limit exceeded exception
class RateLimitExceededException extends AppException {
  const RateLimitExceededException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'RateLimitExceededException: $message';
}

/// استثناء أمني
/// Security exception
class SecurityException extends AppException {
  const SecurityException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'SecurityException: $message';
}

/// استثناء الشبكة
/// Network exception
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// استثناء الخدمة
/// Service exception
class ServiceException extends AppException {
  const ServiceException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ServiceException: $message';
}

/// استثناء الرسالة الطويلة
/// Message too long exception
class MessageTooLongException extends AppException {
  const MessageTooLongException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'MessageTooLongException: $message';
}

/// استثناء API
/// API exception
class ApiException extends AppException {
  final int? statusCode;
  
  const ApiException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// استثناء مفتاح API
/// API key exception
class ApiKeyException extends AppException {
  const ApiKeyException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ApiKeyException: $message';
}
