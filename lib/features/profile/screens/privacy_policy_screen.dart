import 'package:flutter/material.dart';
import 'package:athar_app/core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      isAr
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.arrow_back_ios_new_rounded,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      isAr
                          ? 'سياسة الخصوصية'
                          : 'Privacy Policy',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                isAr
                    ? 'خصوصيتك جزء من ثقتك بنا.'
                    : 'Your privacy is part of your trust in us.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              _IntroCard(
                text: isAr
                    ? 'في أثر، نؤمن أن حماية خصوصيتك جزء أساسي من حفظ تجربتك الثقافية. توضح هذه السياسة كيف نجمع البيانات ونستخدمها ونحميها داخل التطبيق.'
                    : 'At Athar, we believe protecting your privacy is part of protecting your cultural journey. This policy explains how we collect, use, and safeguard data within the app.',
              ),

              const SizedBox(height: 24),

              _PolicySection(
                icon: Icons.person_outline_rounded,
                title: isAr
                    ? 'البيانات التي نجمعها'
                    : 'Data We Collect',
                items: isAr
                    ? [
                        'معلومات الحساب مثل الاسم والبريد الإلكتروني ورقم الهاتف.',
                        'الاهتمامات الثقافية لتحسين التوصيات.',
                        'بيانات الحجوزات عند استخدام خدمات المرشدين.',
                        'المساهمات الثقافية التي يشاركها المستخدم داخل التطبيق.',
                      ]
                    : [
                        'Account information such as name, email, and phone number.',
                        'Cultural interests to improve recommendations.',
                        'Booking data when using guide services.',
                        'Cultural contributions shared by users within the app.',
                      ],
              ),

              _PolicySection(
                icon: Icons.auto_awesome_outlined,
                title: isAr
                    ? 'كيف نستخدم البيانات'
                    : 'How We Use Data',
                items: isAr
                    ? [
                        'تخصيص تجربة المستخدم داخل أثر.',
                        'عرض توصيات ثقافية أكثر ملاءمة.',
                        'إدارة الحجوزات والتواصل بين السياح والمرشدين.',
                        'تحسين جودة المحتوى والخدمات داخل التطبيق.',
                      ]
                    : [
                        'To personalize the user experience in Athar.',
                        'To provide more relevant cultural recommendations.',
                        'To manage bookings and communication between tourists and guides.',
                        'To improve content quality and app services.',
                      ],
              ),

              _PolicySection(
                icon: Icons.location_on_outlined,
                title: isAr
                    ? 'بيانات الموقع'
                    : 'Location Data',
                items: isAr
                    ? [
                        'قد يستخدم أثر الموقع الجغرافي لاقتراح أماكن وتجارب قريبة.',
                        'لا يتم استخدام الموقع إلا لتحسين تجربة الاستكشاف داخل التطبيق.',
                        'يمكن للمستخدم التحكم في أذونات الموقع من إعدادات الجهاز.',
                      ]
                    : [
                        'Athar may use location data to suggest nearby places and experiences.',
                        'Location is used only to improve exploration inside the app.',
                        'Users can control location permissions through device settings.',
                      ],
              ),

              _PolicySection(
                icon: Icons.volunteer_activism_outlined,
                title: isAr
                    ? 'المساهمات المجتمعية'
                    : 'Community Contributions',
                items: isAr
                    ? [
                        'قد تظهر المساهمات الثقافية بعد مراجعتها واعتمادها.',
                        'يجب أن تكون المشاركات مناسبة وتحترم الهوية الثقافية.',
                        'يحق لأثر مراجعة أو إزالة المحتوى غير المناسب.',
                      ]
                    : [
                        'Cultural contributions may appear after review and approval.',
                        'Submissions must be appropriate and respectful of cultural identity.',
                        'Athar may review or remove inappropriate content.',
                      ],
              ),

              _PolicySection(
                icon: Icons.security_outlined,
                title: isAr
                    ? 'حماية البيانات'
                    : 'Data Protection',
                items: isAr
                    ? [
                        'نستخدم وسائل حماية مناسبة لتقليل الوصول غير المصرح به.',
                        'يتم التعامل مع البيانات بما يدعم خصوصية المستخدم وأمانه.',
                        'لا نشارك بياناتك الشخصية مع أطراف غير مصرح لها.',
                      ]
                    : [
                        'We use appropriate safeguards to reduce unauthorized access.',
                        'Data is handled in a way that supports user privacy and security.',
                        'We do not share personal data with unauthorized parties.',
                      ],
              ),

              _PolicySection(
                icon: Icons.manage_accounts_outlined,
                title: isAr
                    ? 'حقوق المستخدم'
                    : 'User Rights',
                items: isAr
                    ? [
                        'يمكنك تعديل بيانات حسابك من صفحة الملف الشخصي.',
                        'يمكنك طلب حذف حسابك من إعدادات الحساب.',
                        'يمكنك التحكم في بعض الأذونات من إعدادات الجهاز.',
                      ]
                    : [
                        'You can edit your account information from the profile page.',
                        'You can request account deletion from account settings.',
                        'You can manage some permissions through device settings.',
                      ],
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  isAr
                      ? 'آخر تحديث: 2026'
                      : 'Last updated: 2026',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final String text;

  const _IntroCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: isHighContrast
              ? theme.colorScheme.onSurface
              : theme.colorScheme.primary.withValues(alpha: 0.12),
          width: isHighContrast ? 2 : 1,
        ),

        boxShadow: isHighContrast
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),

      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _PolicySection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: isHighContrast
              ? theme.colorScheme.onSurface
              : theme.dividerColor.withValues(alpha: 0.12),
          width: isHighContrast ? 2 : 1,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.circle,
                    size: 7,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
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
}
