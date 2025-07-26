import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

/// Provider for error handler service
final errorHandlerServiceProvider = Provider<ErrorHandlerService>((ref) {
  return ErrorHandlerService();
});

/// Service for handling and categorizing application errors
/// Provides user-friendly error messages and recovery suggestions
class ErrorHandlerService {
  
  /// Handle API errors and return user-friendly messages
  String handleApiError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your network connection.';
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          switch (statusCode) {
            case 401:
              return 'Authentication failed. Please check your credentials.';
            case 403:
              return 'Access denied. You don\'t have permission to access this resource.';
            case 404:
              return 'Server endpoint not found. Please check your server configuration.';
            case 500:
              return 'Server error. Please try again later.';
            default:
              return 'Server returned error code $statusCode.';
          }
        
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        
        case DioExceptionType.unknown:
        default:
          return 'Network error. Please check your connection and server settings.';
      }
    }
    
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    
    return 'An unexpected error occurred: ${error.toString()}';
  }

  /// Handle authentication errors
  String handleAuthError(dynamic error) {
    if (error.toString().contains('401')) {
      return 'Invalid username or password. Please check your credentials.';
    }
    
    if (error.toString().contains('timeout')) {
      return 'Connection timeout. Please check your server URL and network connection.';
    }
    
    return 'Authentication failed. Please verify your server settings and credentials.';
  }

  /// Handle video streaming errors
  String handleStreamError(dynamic error) {
    if (error.toString().contains('404')) {
      return 'Camera stream not found. The camera may be offline or misconfigured.';
    }
    
    if (error.toString().contains('timeout')) {
      return 'Stream connection timeout. Please check your network connection.';
    }
    
    return 'Unable to load video stream. Please check camera settings.';
  }

  /// Handle local storage errors
  String handleStorageError(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'Storage permission denied. Please check app permissions.';
    }
    
    if (error.toString().contains('space')) {
      return 'Insufficient storage space. Please free up some space and try again.';
    }
    
    return 'Storage error occurred. Please try again.';
  }

  /// Get recovery suggestions for different error types
  List<String> getRecoverySuggestions(String errorType) {
    switch (errorType.toLowerCase()) {
      case 'network':
        return [
          'Check your internet connection',
          'Verify server URL and port settings',
          'Try connecting to a different network',
          'Contact your network administrator',
        ];
      
      case 'authentication':
        return [
          'Verify your username and password',
          'Check if your account is active',
          'Ensure server authentication is enabled',
          'Try logging in through the web interface',
        ];
      
      case 'stream':
        return [
          'Check if the camera is online',
          'Verify camera stream settings',
          'Try refreshing the camera list',
          'Check network bandwidth',
        ];
      
      case 'storage':
        return [
          'Free up device storage space',
          'Check app permissions',
          'Restart the application',
          'Clear app cache if needed',
        ];
      
      default:
        return [
          'Try again in a few moments',
          'Check your network connection',
          'Restart the application',
          'Contact support if the problem persists',
        ];
    }
  }

  /// Log error for debugging purposes
  void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    print('ERROR [$context]: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}
