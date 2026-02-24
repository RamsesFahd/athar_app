class HistoricalBotModel {
  final String botId;
  final String nameAr;
  final String nameEn;
  final String roleAr;
  final String roleEn;
  final String eraAr;
  final String eraEn;
  final String image;
  final String systemPrompt; 

  HistoricalBotModel({
    required this.botId,
    required this.nameAr,
    required this.nameEn,
    required this.roleAr,
    required this.roleEn,
    required this.eraAr,
    required this.eraEn,
    required this.image,
    required this.systemPrompt,
  });

  //  اختيار اللغة الصحيحة بناءً على إعدادات التطبيق
  String getName(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
  String getRole(String languageCode) => languageCode == 'ar' ? roleAr : roleEn;
  String getEra(String languageCode) => languageCode == 'ar' ? eraAr : eraEn;
}