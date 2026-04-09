import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. الجزء العلوي الفني (صورة مع تأثير التلاشي)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("تفاصيل الفعالية", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // استبدليها بصورة مهرجان القهوة
                  Image.network(
                    'https://images.unsplash.com/photo-1559496417-e7f25cb247f3?q=80&w=1000', 
                    fit: BoxFit.cover,
                  ),
                  // طبقة تعتيم خفيفة عشان النص يبان
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. محتوى الصفحة بلمسة فنية
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان مع خط مزخرف أو مميز
                  Text(
                    "مهرجان القهوة السعودية",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // بطاقة المعلومات السريعة (توزيع عرضي فني)
                  Row(
                    children: [
                      _buildInfoIcon(context, Icons.calendar_month, "20 مايو", "التاريخ"),
                      const Spacer(),
                      _buildInfoIcon(context, Icons.location_on_outlined, "مكة", "الموقع"),
                      const Spacer(),
                      _buildInfoIcon(context, Icons.access_time, "8:00 م", "الوقت"),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(thickness: 1),
                  ),

                  // قسم "عن الفعالية" بتصميم مرتب
                  Text(
                    "عن الفعالية",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "فعالية ثقافية لاستعراض طرق تحضير القهوة السعودية والاحتفاء بالقيم الثقافية الأصيلة التي ترتبط بهذا الرمز السعودي العريق.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: Colors.grey[700]),
                  ),
                  
                  const SizedBox(height: 40),

                  // زر تفاعلي (اختياري)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {},
                      child: const Text("احجز مكانك الآن", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجيت صغير لعرض الأيقونات بشكل فني
  Widget _buildInfoIcon(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}