import 'package:flutter/material.dart';
import '../widgets/trip_card.dart'; 
import 'package:athar_app/core/models/trip/trip.dart'; 
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../../../core/widgets/search_bar.dart';
import 'package:athar_app/features/guide_market/screens/trip_details_screen.dart';

class TripsListScreen extends StatefulWidget {
  final String? selectedRegion;

  const TripsListScreen({super.key, this.selectedRegion});
  
  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen> {
  // القائمة الكاملة كما هي في طلبك
  final List<Trip> allTrips = [
  Trip(
    id: "1",
    titleAr: "رحلة استكشاف جبال السودة في أبها",
    titleEn: "Al-Sawda Mountains Exploration Trip in Abha",
    city: "أبها",
    guide: "فاطمة عسيري",
    company: "عسير للمغامرات",
    price: "400 ر.س",
    imageUrl: "https://www.spectacularmountains.com/wp-content/uploads/2019/05/Sawda_COR_8386_edited.jpg",
    descriptionAr: "استعد لرحلة تأخذك فوق السحاب:\n\n• تجربة استثنائية: زيارة قمة السودة...\n\nانطلق معنا في مغامرة تجمع بين فخامة الجبال وهدوء الطبيعة.",
    descriptionEn: "Get ready for a trip above the clouds:\n\n• Exceptional experience: Visit Al-Sawda peak...\n\nJoin us for an adventure combining mountain luxury and natural serenity.",
    license: "ترخيص 1",
    shortDescriptionAr: "استكشف قمة السودة ومنتزه السحاب في أجواء أبها الباردة.",
    shortDescriptionEn: "Explore Al-Sawda peak and Al-Sahab park in Abha's cool weather.",
  ),
  Trip(
    id: "2",
    titleAr: "جولة في قرية رجال ألمع التراثية",
    titleEn: "Tour of Rijal Almaa Heritage Village",
    city: "أبها",
    guide: "سعيد الشهراني",
    company: "تراث الجنوب",
    price: "300 ر.س",
    imageUrl: "https://static.sayidaty.net/2021-10/7593.jpeg",
    descriptionAr: "رحلة عبر الزمن في رجال ألمع:\n\n• استكشاف الهندسة المعمارية العسيرية الملونة.\n\nعش التاريخ واكتشف عراقة العمارة.",
    descriptionEn: "A journey through time in Rijal Almaa:\n\n• Explore colorful Asir architectural design.\n\nLive the history and discover ancient architecture.",
    license: "ترخيص 2",
    shortDescriptionAr: "جولة في قرية رجال ألمع التاريخية ومعمارها العسيري الفريد.",
    shortDescriptionEn: "A tour of the historic Rijal Almaa village and its unique Asiri architecture.",
  ),
  Trip(
    id: "3",
    titleAr: "مغامرة في جبال العلا",
    titleEn: "Adventure in Al-Ula Mountains",
    city: "العلا",
    guide: "خالد العنزي",
    company: "ديزرت بوينت",
    price: "500 ر.س",
    imageUrl: "https://blog.gathern.co/wp-content/uploads/2024/05/AlUla_Featured-image-copy-2-1024x767.webp",
    descriptionAr: "سحر التاريخ والجيولوجيا في العلا:\n\n• جولة في التشكيلات الصخرية الفريدة.\n\nاكتشف حضارات عريقة.",
    descriptionEn: "The magic of history and geology in Al-Ula:\n\n• Tour of unique rock formations.\n\nDiscover ancient civilizations.",
    license: "ترخيص 3",
    shortDescriptionAr: "مغامرة بين التشكيلات الصخرية والواحات التاريخية في العلا.",
    shortDescriptionEn: "Adventure among rock formations and historic oases in Al-Ula.",
  ),
];
  late List<Trip> displayedTrips;
  bool isGridView = true;
  
  @override
void initState() {
  super.initState();
  // ابدئي دائماً بعرض كل الرحلات
  displayedTrips = allTrips; 
}

void _runFilter(String enteredKeyword) {
  List<Trip> results = [];
  
  // 1. نحدد اللغة الحالية
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  
  if (enteredKeyword.isEmpty) {
    results = allTrips;
  } else {
    // 2. نستخدم الدالة الذكية getTitle للبحث في النص الذي يظهر للمستخدم
    results = allTrips.where((t) => 
        t.getTitle(isAr).toLowerCase().contains(enteredKeyword.toLowerCase()) || 
        t.company.toLowerCase().contains(enteredKeyword.toLowerCase())
    ).toList();
  }
  
  setState(() {
    displayedTrips = results;
  });
}
   void _sortTripsByPrice({required bool ascending}) {
  setState(() {
    displayedTrips.sort((a, b) {
      // 1. إزالة أي أحرف غير رقمية
      final priceA = int.tryParse(a.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final priceB = int.tryParse(b.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      
      // 2. المقارنة بناءً على قيمة ascending
      return ascending 
          ? priceA.compareTo(priceB) // من الأصغر للأكبر
          : priceB.compareTo(priceA); // من الأكبر للأصغر
    });
  });
}
  @override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    return Scaffold(
      appBar: AppBar(
  title: Text(
    widget.selectedRegion == null 
        ? l10n.all_trips 
            : l10n.trips_in(widget.selectedRegion!),
  ),
),
      body: Column(
        children: [
          // دمج الـ CustomSearchBar هنا
          CustomSearchBar(
          hintText: l10n.search_trips_hint,
            isGridView: isGridView,
            onChanged: _runFilter,
            onFilterTap: () async {
  // الحصول على موقع الزر الحالي بدقة
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  
  // تحديد موضع القائمة (تظهر بالقرب من الزر)
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );

  // إظهار القائمة المنسدلة
  final String? result = await showMenu<String>(
    context: context,
    position: position,
    items: [
       PopupMenuItem<String>(
        value: 'low',
        child: Row(
          children: [
            Icon(Icons.arrow_upward, size: 20),
            SizedBox(width: 10),
           Text(l10n.price_low_first),
          ],
        ),
      ),
       PopupMenuItem<String>(
        value: 'high',
        child: Row(
          children: [
            Icon(Icons.arrow_downward, size: 20),
            SizedBox(width: 10),
            Text(l10n.price_high_first),
          ],
        ),
      ),
    ],
  );

  // تنفيذ الترتيب بناءً على الاختيار
  if (result == 'low') {
    _sortTripsByPrice(ascending: true);
  } else if (result == 'high') {
    _sortTripsByPrice(ascending: false);
  }
},
            onToggleView: () {
              setState(() => isGridView = !isGridView);
            },
          ),
          
          Expanded(
            child: isGridView
              ? GridView.builder( 
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: displayedTrips.length,
                  itemBuilder: (context, index) => TripCard(
                  trip: displayedTrips[index], 
                  isGridView: true, // تأكدي من تمرير الحالة
                ),
                )
              : ListView.builder( // عرض القائمة
                  padding: const EdgeInsets.all(16),
                  itemCount: displayedTrips.length,
                  itemBuilder: (context, index) => TripCard(
                  trip: displayedTrips[index], 
                  isGridView: false, // تأكدي من تمرير الحالة
                 ),
                ),
          ),
        ],
      ),
    );
  }
}