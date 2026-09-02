import 'package:dio/dio.dart';
import 'package:flutterapp/services/jwt_service.dart';

//erstellt einen Dio http client mit einer baseUrl, der für die gesamte App verwendet wird

final dio = Dio()
      // URL mit 10.0.2.2:8000 für Android Emulator
      // URL mit 127.0.0.1:8000 für Edge und co
..options.baseUrl = "http://10.0.2.2:8000/api"
..interceptors.add(LogInterceptor(requestHeader: true, requestBody: true))
..interceptors.add(   //fügt einen Interceptor zu dem dio http client hinzu
                      //das .. ist ein cascade operator (https://medium.com/@rk0936626/all-about-cascade-operator-in-dart-flutter-530b1e788a03)
  QueuedInterceptorsWrapper(
      onRequest: (requestOptions, handler) async {  //immer wenn eine http request gemacht wird....
        final token = await JwtService().getToken(); //...ruft dio die methode getToken auf um das acesstoken zu erhalten
        if (token != null) {   //wenn das token nicht null ist = wenn ein Token vorhanden ist
          requestOptions.headers['Authorization'] =        //dann wird es bei der request als header mitgeschickt
              'Bearer $token';
        }
        return handler.next(requestOptions);
      },
  )
);
