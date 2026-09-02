import 'package:dio/dio.dart';
import 'package:flutterapp/services/jwt_service.dart';

/// Provides a pre-configured [Dio] HTTP client for the entire application.
///
/// This client includes a base URL and an interceptor that automatically attaches
/// a JWT Bearer token to every outgoing request if a token is available.
final dio = Dio()
      // URL with 10.0.2.2:8000 for Android Emulator
      // URL with 127.0.0.1:8000 for Edge and others
..options.baseUrl = "http://10.0.2.2:8000/api"
..interceptors.add(LogInterceptor(requestHeader: true, requestBody: true))
..interceptors.add(
  QueuedInterceptorsWrapper(
      /// Intercepts every request to add the Authorization header.
      onRequest: (requestOptions, handler) async {
        final token = await JwtService().getToken();
        if (token != null) {
          requestOptions.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(requestOptions);
      },
  )
);
