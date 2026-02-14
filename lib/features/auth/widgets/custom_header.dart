import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/image.png',
            fit: BoxFit.cover,
          ),
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
          // قمنا بتغيير الـ Padding والـ Alignment ليتناسب مع شكل التصميم
          Padding(
            padding: const EdgeInsets.fromLTRB(
                24, 0, 24, 60), // زدنا الـ bottom لرفع النص قليلاً عن المنحنى
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              // جعلنا المحاذاة تعتمد على اللغة بشكل مباشر
              crossAxisAlignment:
                  isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32, // صغرنا الحجم قليلاً ليتناسق مع فيجما
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'Playfair Display', // تأكدي من إضافة الخط إذا كان موجوداً
                  ),
                ),
                const SizedBox(
                    height: 4), // مسافة بسيطة جداً بين العنوان والوصف
                Text(
                  subtitle,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
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
