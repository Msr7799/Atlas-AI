import 'dart:io';
import 'package:dio/dio.dart';

class NetworkChecker {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// فحص الاتصال بالإنترنت العام
  static Future<bool> hasInternetConnection() async {
    try {
      final response = await _dio.get('https://www.google.com');
      return response.statusCode == 200;
    } catch (e) {
      print('[NETWORK] Internet connection check failed: $e');
      return false;
    }
  }

  /// فحص الاتصال بـ Groq API
  static Future<NetworkTestResult> testGroqConnection() async {
    try {
      final response = await _dio.get('https://api.groq.com');
      return NetworkTestResult(
        success: true,
        statusCode: response.statusCode,
        message: 'Groq API accessible',
      );
    } on DioException catch (e) {
      return NetworkTestResult(
        success: false,
        statusCode: e.response?.statusCode,
        message: 'Groq API connection failed: ${e.type} - ${e.message}',
        error: e,
      );
    } catch (e) {
      return NetworkTestResult(
        success: false,
        message: 'Groq API connection failed: $e',
        error: e,
      );
    }
  }

  /// فحص الاتصال بـ Tavily API
  static Future<NetworkTestResult> testTavilyConnection() async {
    try {
      final response = await _dio.get('https://api.tavily.com');
      return NetworkTestResult(
        success: true,
        statusCode: response.statusCode,
        message: 'Tavily API accessible',
      );
    } on DioException catch (e) {
      return NetworkTestResult(
        success: false,
        statusCode: e.response?.statusCode,
        message: 'Tavily API connection failed: ${e.type} - ${e.message}',
        error: e,
      );
    } catch (e) {
      return NetworkTestResult(
        success: false,
        message: 'Tavily API connection failed: $e',
        error: e,
      );
    }
  }

  /// فحص DNS
  static Future<bool> testDNSResolution(String hostname) async {
    try {
      await InternetAddress.lookup(hostname);
      return true;
    } catch (e) {
      print('[NETWORK] DNS resolution failed for $hostname: $e');
      return false;
    }
  }

  /// فحص شامل للشبكة
  static Future<NetworkDiagnostics> runFullDiagnostics() async {
    print('[NETWORK] Running full network diagnostics...');

    final hasInternet = await hasInternetConnection();
    final groqDNS = await testDNSResolution('api.groq.com');
    final tavilyDNS = await testDNSResolution('api.tavily.com');
    final groqTest = await testGroqConnection();
    final tavilyTest = await testTavilyConnection();

    return NetworkDiagnostics(
      hasInternetConnection: hasInternet,
      groqDNSResolved: groqDNS,
      tavilyDNSResolved: tavilyDNS,
      groqApiResult: groqTest,
      tavilyApiResult: tavilyTest,
    );
  }

  /// طباعة تقرير مفصل
  static void printDiagnosticsReport(NetworkDiagnostics diagnostics) {
    print('\n═══════════════════════════════════════');
    print('📊 ATLAS AI - NETWORK DIAGNOSTICS REPORT');
    print('═══════════════════════════════════════');

    print(
      '🌐 Internet Connection: ${diagnostics.hasInternetConnection ? "✅ Connected" : "❌ Failed"}',
    );
    print(
      '🔍 Groq DNS Resolution: ${diagnostics.groqDNSResolved ? "✅ Success" : "❌ Failed"}',
    );
    print(
      '🔍 Tavily DNS Resolution: ${diagnostics.tavilyDNSResolved ? "✅ Success" : "❌ Failed"}',
    );

    print('\n📡 API Connectivity Tests:');
    print(
      'Groq API: ${diagnostics.groqApiResult.success ? "✅" : "❌"} ${diagnostics.groqApiResult.message}',
    );
    if (diagnostics.groqApiResult.statusCode != null) {
      print('  Status Code: ${diagnostics.groqApiResult.statusCode}');
    }

    print(
      'Tavily API: ${diagnostics.tavilyApiResult.success ? "✅" : "❌"} ${diagnostics.tavilyApiResult.message}',
    );
    if (diagnostics.tavilyApiResult.statusCode != null) {
      print('  Status Code: ${diagnostics.tavilyApiResult.statusCode}');
    }

    if (!diagnostics.hasInternetConnection) {
      print('\n💡 RECOMMENDATIONS:');
      print('• Check your Wi-Fi or mobile data connection');
      print('• Try switching between Wi-Fi and mobile data');
      print('• Restart your network connection');
    }

    if (diagnostics.hasInternetConnection &&
        (!diagnostics.groqDNSResolved || !diagnostics.tavilyDNSResolved)) {
      print('\n💡 DNS ISSUES DETECTED:');
      print('• Try using a different DNS server (8.8.8.8, 1.1.1.1)');
      print('• Check if your network blocks certain domains');
      print('• Try using a VPN to bypass network restrictions');
    }

    print('═══════════════════════════════════════\n');
  }
}

class NetworkTestResult {
  final bool success;
  final int? statusCode;
  final String message;
  final dynamic error;

  NetworkTestResult({
    required this.success,
    this.statusCode,
    required this.message,
    this.error,
  });
}

class NetworkDiagnostics {
  final bool hasInternetConnection;
  final bool groqDNSResolved;
  final bool tavilyDNSResolved;
  final NetworkTestResult groqApiResult;
  final NetworkTestResult tavilyApiResult;

  NetworkDiagnostics({
    required this.hasInternetConnection,
    required this.groqDNSResolved,
    required this.tavilyDNSResolved,
    required this.groqApiResult,
    required this.tavilyApiResult,
  });

  bool get allTestsPassed =>
      hasInternetConnection &&
      groqDNSResolved &&
      tavilyDNSResolved &&
      groqApiResult.success &&
      tavilyApiResult.success;
}
