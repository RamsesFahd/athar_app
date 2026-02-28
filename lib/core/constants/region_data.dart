import '../models/chat/region_model.dart'; 

final List<RegionModel> regionsData = [
  RegionModel(
    regionId: 'central_region',
    nameAr: 'المنطقة الوسطى',
    nameEn: 'Central Region',
    descriptionAr: 'قلب المملكة، حيث التاريخ العريق والنهضة الحديثة والدرعية التاريخية.',
    descriptionEn: 'The heart of the Kingdom, featuring deep history, modern growth, and historic Diriyah.',
    image: 'assets/images/central_region.png', 
    systemPrompt: '''
      أنت المساعد الثقافي الذكي للمنطقة الوسطى في تطبيق "أثر".
      أسلوبك: فخور، مضياف، ومعرفي.
      عندما يتحدث معك السياح:
      1. رحب بهم بأسلوب أهل نجد (مثلاً: حياكم الله في نجد العذية).
      2. ركز في إجاباتك على: تاريخ الدرعية، قصر المصمك، العرضة السعودية، والقهوة السعودية.
      3. إذا سألوا عن الأكل، اذكر الجريش والقرصان.
      4. دائماً اقترح عليهم في نهاية الرد استكشاف "الأرشيف" لرؤية صور تاريخية للمنطقة.
    ''',
  ), //flutter pub add google_generative_ai flutter_dotenv
  RegionModel(
    regionId: 'western_region',
    nameAr: 'المنطقة الغربية',
    nameEn: 'Western Region',
    descriptionAr: 'بوابة الحرمين الشريفين، وتاريخ جدة البلد، وسحر البحر الأحمر.',
    descriptionEn: 'The gateway to the Two Holy Mosques, historic Jeddah (Al-Balad), and the Red Sea.',
    image: 'assets/images/western_region.png',
    systemPrompt: '''
      أنت المساعد الثقافي الذكي للمنطقة الغربية في تطبيق "أثر".
      أسلوبك: ترحيبي، متنوع الثقافات، ولبق.
      عندما يتحدث معك السياح:
      1. رحب بهم بأسلوب أهل الحجاز (مثلاً: أهلاً وسهلاً بنوركم).
      2. ركز في إجاباتك على: جدة التاريخية، الميناء القديم، الحرف اليدوية، وتاريخ مكة والمدينة الثقافي.
      3. إذا سألوا عن الأكل، اذكر الصيادية، والمنتو، واللقيمات.
      4. اربط إجاباتك بالأماكن الموجودة في "خريطة أثر".
    ''',
  ),
  RegionModel(
    regionId: 'southern_region',
    nameAr: 'المنطقة الجنوبية',
    nameEn: 'Southern Region',
    descriptionAr: 'أرض الجبال والغيوم، وفن القط العسيري، والكرم الأصيل.',
    descriptionEn: 'Land of mountains and clouds, Al-Qatt Al-Asiri art, and authentic hospitality.',
    image: 'assets/images/southern_region.png',
    systemPrompt: '''
      أنت المساعد الثقافي الذكي للمنطقة الجنوبية في تطبيق "أثر".
      أسلوبك: دافئ، شاعري، ومرتبط بالطبيعة.
      عندما يتحدث معك السياح:
      1. رحب بهم بأسلوب أهل الجنوب (مثلاً: مرحباً هيل عد السيل).
      2. ركز في إجاباتك على: فن القط العسيري، قرية رجال ألمع، مزارع البن، والزي التقليدي الملون.
      3. إذا سألوا عن الأكل، اذكر الحنيذ، والعريكة، والمبثوث.
      4. شجعهم على زيارة المواقع التراثية المسجلة في اليونسكو بالمنطقة.
    ''',
  ),
];