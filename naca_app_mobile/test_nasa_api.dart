import 'package:naca_app_mobile/data/repo.dart';

void main() async {
  print("Testing NASA API connection...");
  
  try {
    // Test with a simple parameter and location
    final result = await AppRepo.getProbabilityOfOneDay(
      "1004", // October 4th
      "T2M", // Temperature
      30.0, // Cairo latitude
      31.0, // Cairo longitude
    );
    
    print("API call successful!");
    print("Temperature data: $result");
  } catch (e) {
    print("API call failed: $e");
  }
}