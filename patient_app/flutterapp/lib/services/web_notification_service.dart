// lib/services/web_notification_service.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// A service for handling web notifications.
///
/// This service is only intended to be used when the app is running on the web platform.
class WebNotificationService {
  /// Requests permission and shows a test notification on the web.
  static void showNotification() {
    html.Notification.requestPermission().then((permission) {
      if (permission == 'granted') {
        html.Notification(
          'Test Erinnerung',
          body: 'Bitte nehmen Sie Ihr Medikament!',
        );
      }
    });
  }
}
