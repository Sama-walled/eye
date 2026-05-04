class ApiConstants {
  // For Android Emulator, use 10.0.2.2
  // For Physical Device, use your computer's local IP (e.g., 192.168.1.4)
  // For Desktop/Web, use 127.0.0.1
  static const String baseUrl = '';
  
  static const String loginUrl = '$baseUrl/api/login';
  static const String registerUrl = '$baseUrl/api/register';
  static const String predictUrl = '$baseUrl/api/predict';
  static const String historyUrl = '$baseUrl/api/history';
}
