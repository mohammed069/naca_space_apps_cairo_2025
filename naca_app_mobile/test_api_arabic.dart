import 'package:naca_app_mobile/data/repo.dart';

void main() async {
  print("اختبار الاتصال بـ NASA API...");
  
  try {
    // اختبار مع موقع القاهرة
    print("جاري جلب بيانات الحرارة...");
    final tempResult = await AppRepo.getProbabilityOfOneDay(
      "1004", // 4 أكتوبر
      "T2M", // الحرارة
      30.0444, // خط عرض القاهرة
      31.2357, // خط طول القاهرة
    );
    
    print("✅ نجح جلب بيانات الحرارة: ${tempResult.toStringAsFixed(1)}°C");
    
    // اختبار بيانات الرطوبة
    print("جاري جلب بيانات الرطوبة...");
    final humidityResult = await AppRepo.getProbabilityOfOneDay(
      "1004",
      "RH2M", // الرطوبة
      30.0444,
      31.2357,
    );
    
    print("✅ نجح جلب بيانات الرطوبة: ${humidityResult.toStringAsFixed(1)}%");
    
    print("🎉 API يعمل بشكل طبيعي!");
    
  } catch (e) {
    print("❌ فشل اختبار API: $e");
  }
}