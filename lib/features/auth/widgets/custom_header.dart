import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    
    
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. صورة الخلفية الخاصة بمشروع أثر
          Image.asset(
            'assets/images/image.png',
            fit: BoxFit.cover,
          ),
          
          // 2. التدرج اللوني لضمان وضوح النص
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // 3. نصوص الهيدر (العنوان والوصف)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 60), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              // التعديل الجوهري: CrossAxisAlignment.start تعني اليمين في العربي تلقائيًا
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  title,
                  // TextAlign.start تتبع اتجاه لغة التطبيق الحالية
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    // استخدام Playfair Display للإنجليزي كما هو مفضل لديكِ
                    fontFamily: 'Playfair Display', 
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}