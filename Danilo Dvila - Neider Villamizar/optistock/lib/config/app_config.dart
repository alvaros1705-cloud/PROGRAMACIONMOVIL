class AppConfig {
  // Use 10.0.2.2 for Android Emulator to access localhost
  // Replace with your PC IP (e.g., 192.168.1.50) if testing on a real device
  static const String baseUrl = 'http://10.10.12.62:8000';
  
  static const String analyzeInventoryUrl = '$baseUrl/analyze-inventory';
  static const String uploadInitialInventoryUrl = '$baseUrl/upload-initial-inventory';
  static const String exportReportUrl = '$baseUrl/export-report';
}
