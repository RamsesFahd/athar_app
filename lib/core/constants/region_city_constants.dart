const Map<String, Map<String, String>> regionMap = {
  'central': {'ar': 'المنطقة الوسطى', 'en': 'Central Region'},
  'western': {'ar': 'المنطقة الغربية', 'en': 'Western Region'},
  'northern': {'ar': 'المنطقة الشمالية', 'en': 'Northern Region'},
  'eastern': {'ar': 'المنطقة الشرقية', 'en': 'Eastern Region'},
  'southern': {'ar': 'المنطقة الجنوبية', 'en': 'Southern Region'},
};

const Map<String, Map<String, String>> cityMap = {
  'riyadh': {'ar': 'الرياض', 'en': 'Riyadh'},
  'qassim': {'ar': 'القصيم', 'en': 'Qassim'},
  'hail': {'ar': 'حائل', 'en': 'Hail'},
  'jeddah': {'ar': 'جدة', 'en': 'Jeddah'},
  'makkah': {'ar': 'مكة', 'en': 'Makkah'},
  'madinah': {'ar': 'المدينة', 'en': 'Madinah'},
  'taif': {'ar': 'الطائف', 'en': 'Taif'},
  'tabuk': {'ar': 'تبوك', 'en': 'Tabuk'},
  'arar': {'ar': 'عرعر', 'en': 'Arar'},
  'sakaka': {'ar': 'سكاكا', 'en': 'Sakaka'},
  'dammam': {'ar': 'الدمام', 'en': 'Dammam'},
  'khobar': {'ar': 'الخبر', 'en': 'Khobar'},
  'al_ahsa': {'ar': 'الأحساء', 'en': 'Al Ahsa'},
  'jubail': {'ar': 'الجبيل', 'en': 'Jubail'},
  'abha': {'ar': 'أبها', 'en': 'Abha'},
  'khamis_mushait': {'ar': 'خميس مشيط', 'en': 'Khamis Mushait'},
  'jazan': {'ar': 'جازان', 'en': 'Jazan'},
  'najran': {'ar': 'نجران', 'en': 'Najran'},
  'al_baha': {'ar': 'الباحة', 'en': 'Al Baha'},
};

const Map<String, List<String>> regionCities = {
  'central': ['riyadh', 'qassim', 'hail'],
  'western': ['jeddah', 'makkah', 'madinah', 'taif'],
  'northern': ['tabuk', 'arar', 'sakaka'],
  'eastern': ['dammam', 'khobar', 'al_ahsa', 'jubail'],
  'southern': ['abha', 'khamis_mushait', 'jazan', 'najran', 'al_baha'],
};

String regionLabel(String regionId, {required bool isArabic}) =>
    regionMap[regionId]?[isArabic ? 'ar' : 'en'] ?? regionId;

String cityLabel(String cityId, {required bool isArabic}) =>
    cityMap[cityId]?[isArabic ? 'ar' : 'en'] ?? cityId;
