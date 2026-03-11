import 'package:flutter/material.dart';
import '../widgets/custom_stepper.dart';
import '../widgets/guide_card.dart';
import 'booking_summary_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class GuideSelectionScreen extends StatelessWidget {
final String tripTitle;
final double tripPrice;
final String date;
final String time;
final int adults;
final int children;
final String imageUrl;

const GuideSelectionScreen({super.key,required this.tripTitle,required this.date,required this.time,required this.adults,required this.children,required this.imageUrl,required this.tripPrice});

List<Map<String, dynamic>> getGuides(bool isAr) {
  return [
    {
      "name": isAr ? "أحمد الغامدي" : "Ahmed Al-Ghamdi",
      "rating": 4.9,
      "exp": isAr ? "8 سنوات" : "8 Years",
      "company": isAr ? "نخبة الإرشاد السياحي" : "Elite Tourism Guides",
      "availableDays": isAr ? ["الاثنين", "الأربعاء", "الخميس"] : ["Monday", "Wednesday", "Thursday"],
      "bio": isAr 
          ? "شغوف بسرد القصص التاريخية التي لا تجدها في الكتب. خبير في تحويل الأماكن الصامتة إلى تجارب حية، أمتلك قدرة فريدة على ربط الزوار بجوهر المكان وعمقه الحضاري."
          : "Passionate about telling historical stories not found in books. Expert in turning silent places into vivid experiences, I possess a unique ability to connect visitors to the essence and depth of the place.",
      "languages": isAr ? ["العربية", "الإنجليزية"] : ["Arabic", "English"],
      "skills": isAr 
          ? ["سرد قصصي", "إدارة الحشود", "دليل سياحي معتمد"] 
          : ["Storytelling", "Crowd Management", "Certified Guide"]
    },
    {
      "name": isAr ? "سارة العتيبي" : "Sarah Al-Otaibi",
      "rating": 5.0,
      "exp": isAr ? "6 سنوات" : "6 Years",
      "company": isAr ? "مسارات المغامرة" : "Adventure Paths",
      "availableDays": isAr ? ["الأحد", "الثلاثاء", "الجمعة"] : ["Sunday", "Tuesday", "Friday"],
      "bio": isAr 
          ? "متخصصة في صناعة ذكريات لا تُنسى. أدمج بين احترافية التخطيط وروح المغامرة، أحرص دائماً على أن تكون الرحلة أكثر من مجرد زيارة، بل تجربة استكشافية متكاملة."
          : "Specialized in creating unforgettable memories. I combine professional planning with an adventurous spirit, ensuring the journey is more than just a visit, but a complete exploratory experience.",
      "languages": isAr ? ["العربية", "الإنجليزية"] : ["Arabic", "English"],
      "skills": isAr 
          ? ["تصوير فوتوغرافي احترافي", "إسعافات أولية برية", "تخطيط رحلات خاصة"] 
          : ["Professional Photography", "Wilderness First Aid", "Private Trip Planning"]
    },
    {
      "name": isAr ? "خالد العنزي" : "Khaled Al-Enezi",
      "rating": 4.8,
      "exp": isAr ? "10 سنوات" : "10 Years",
      "company": isAr ? "تراث وأصالة" : "Heritage & Authenticity",
      "availableDays": isAr ? ["السبت", "الثلاثاء", "الأربعاء"] : ["Saturday", "Tuesday", "Wednesday"],
      "bio": isAr 
          ? "مرشد سياحي بطبع الباحث. أؤمن أن كل زاوية في مملكتنا تحمل إرثاً يستحق الاحتفاء به. أتميز بمعرفة واسعة بالتفاصيل الدقيقة والمسارات غير المألوفة التي تدهش الزوار."
          : "A tour guide by nature, a researcher at heart. I believe every corner of our kingdom holds a heritage worth celebrating. I excel in deep knowledge of intricate details and off-the-beaten-path trails that amaze visitors.",
      "languages": isAr ? ["العربية"] : ["Arabic"],
      "skills": isAr 
          ? ["معرفة عميقة بالآثار", "قيادة سيارات دفع رباعي", "مهارات الإرشاد الثقافي"] 
          : ["Archaeology Expertise", "4x4 Driving", "Cultural Guiding Skills"]
    },
  ];
}

void _showGuideDetails(BuildContext context,Map<String,dynamic> guide,AppLocalizations l10n){
showDialog(
context:context,
builder:(context)=>AlertDialog(
shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(guide['name']), // يظهر اسم المرشد المختار
    const SizedBox(height: 5),
    Row(
      children: List.generate(5, (index) => Icon(
        index < guide['rating'].floor() ? Icons.star : Icons.star_border,
        color: Colors.amber, 
        size: 18,
      )),
    ),
  ],
),
content: SingleChildScrollView(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 1. نبذة المرشد
      Text(guide['bio'], style: TextStyle(color: Colors.grey[700])),
      const SizedBox(height: 15),

      // 2. كود اللغات الجديد هنا:
      Text(l10n.languages, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: (guide['languages'] as List).map((lang) => Chip(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          label: Text(lang, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        )).toList(),
      ),
      const SizedBox(height: 15),
Text(l10n.available_days, style: const TextStyle(fontWeight: FontWeight.bold)),
const SizedBox(height:8),
Wrap(
spacing:8,
children:(guide['availableDays'] as List).map((day)=>Chip(
backgroundColor:Theme.of(context).primaryColor.withOpacity(0.1),
label:Text(day,style:TextStyle(color:Theme.of(context).primaryColor,fontWeight:FontWeight.bold)),
)).toList(),
),
const SizedBox(height:15),
Text(l10n.skills, style: const TextStyle(fontWeight: FontWeight.bold)),
Text("• ${guide['skills'].join('\n• ')}"),
],
),
),
actions:[
ElevatedButton(
style:ElevatedButton.styleFrom(
backgroundColor:Theme.of(context).primaryColor,
minimumSize:const Size(double.infinity,50),
),
onPressed: () {
  Navigator.pop(context); // إغلاق الـ Dialog أولاً
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookingSummaryScreen(
        tripTitle: tripTitle, // مستخدمة من الـ Stateless Widget مباشرة
        guideName: guide['name'],
        date: date,
        time: time,
        adults: adults,
        children: children,
        totalPrice: tripPrice,
        imageUrl: imageUrl,
      ),
    ),
  );
},
child: Text(l10n.select_this_guide, style: const TextStyle(color: Colors.white)),
),
],
),
);
}

@override
Widget build(BuildContext context){
final l10n = AppLocalizations.of(context)!;
  final isAr = Localizations.localeOf(context).languageCode == 'ar'; 
  final guides = getGuides(isAr);
return Scaffold(
appBar:AppBar(title:Text(l10n.choose_guide)),
body:Column(
children:[
const Padding(padding:EdgeInsets.all(16.0),child:CustomStepper(currentStep:3)),
Expanded(
child:ListView.builder(
padding:const EdgeInsets.symmetric(horizontal:16),
itemCount:guides.length,
itemBuilder:(context,index)=>GuideCard(
guide:guides[index],
onTap:()=>_showGuideDetails(context,guides[index], l10n),
),
),
),
],
),
);
}
}