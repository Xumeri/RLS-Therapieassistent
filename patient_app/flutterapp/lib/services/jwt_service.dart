import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterapp/dio_setup.dart';

// Code für den JWT Service wurde nach Vorlage von
// https://medium.com/@areesh-ali/building-a-secure-flutter-app-with-jwt-and-apis-e22ade2b2d5f
// angepasst: auth_service und token_service in einer Klasse JwtService zusammengeführt

/// Service for managing JSON Web Tokens (JWT) and user authentication.
///
/// This service handles saving, retrieving, and deleting tokens from secure storage,
/// as well as performing login, signup, and logout operations.
class JwtService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Saves the [tokenString] to the secure storage.
  Future<void> saveToken(String tokenString) async {
    await _storage.write(key: 'jwt', value: tokenString); //speichert erhaltenes Token als String in securestorage
  }

  /// Retrieves the JWT access token from secure storage.
  ///
  /// Returns the access token string if it exists and is valid, otherwise returns `null`.
  Future<String?> getToken() async {
    final tokenString = await _storage.read(key: 'jwt'); //holt Token als String aus securestorage
    if (tokenString != null){
      final Map<String, dynamic> tokenJson = jsonDecode(tokenString); //konvertiert den String in eine JSON
      return tokenJson["access"]; //gibt von dieser Json das element mit dem key "access" = das access token zurück
    }
    else{
      return null;
    }
  }

  /// Deletes the JWT token from secure storage.
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt');
  }

  /// Authenticates a user with their [username] and [password].
  ///
  /// Returns `true` if authentication is successful and the token is saved.
  Future<bool> login(String username, String password) async {
    try {
      final response = await dio.post("/token/",   //verwendet dio das in dio_setup erstellt wurde
        data: {'username': username, 'password': password},  // sendet username und password an Django
      );

      if (response.statusCode == 200) {
        final tokenJson = response.data; //speichert erhaltene Antwort in Variable tokenJson
        if (tokenJson != null) {
          String tokenString = jsonEncode(tokenJson); //konvertiert erhaltene JSON in einen String
          await saveToken(tokenString); //sendet String zum Speichern an saveToken Methode
          return true;
        }
      }
    } catch (e) {     // Catch wenn Einloggen schiefgeht
      print('Login error: $e');
    }
    return false;
  }

  /// Registers a new user with the given [username] and [password].
  ///
  /// Returns `true` if registration is successful.
  Future<bool> signup(String username, String password) async {
    try {
      final response = await dio.post("/register/",
            data: {"username": username, "password": password}, // sendet username und password an Django
      );

      if (response.statusCode == 201) { //Wenn User erfolgreich registriert wurde
        final resp = response.data; 
        if (resp != null) {
          return true;  // wird true zurückgegeben
        }
      }

    } on DioException catch (e) {   // Catch wenn Registrierung schiefgeht
      if (e.response != null) {
        // Fehlertext vom Backend
        print('Status: ${e.response!.statusCode}');
        print('Fehlerdaten: ${e.response!.data}');
      } else {
        // Kein Server erreicht
        print('Request error: ${e.message}');
      }
      print('Signup error: $e');
    }
    return false;
  }

  /// Logs the user out by deleting their JWT token.
  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }
}
