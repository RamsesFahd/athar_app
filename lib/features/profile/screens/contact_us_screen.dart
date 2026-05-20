import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
                      isAr ? 'تواصل معنا' : 'Contact Us',
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
                    ? 'يسعدنا سماع اقتراحاتك أو ملاحظاتك لتحسين تجربة أثر.'
                    : 'We’d love to hear your suggestions or feedback to improve Athar.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              _ContactCard(
                icon: Icons.email_outlined,
                title: isAr ? 'البريد الإلكتروني' : 'Email',
                subtitle: 'support@atharapp.dev',
              ),

              _ContactCard(
                icon: Icons.alternate_email_rounded,
                title: 'X / Twitter',
                subtitle: '@athar_sa',
              ),

              _ContactCard(
                icon: Icons.location_on_outlined,
                title: isAr ? 'الموقع' : 'Location',
                subtitle: isAr ? 'المملكة العربية السعودية' : 'Saudi Arabia',
              ),

              const SizedBox(height: 26),

              Text(
                isAr ? 'نوع المساعدة' : 'Support Type',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.85,
                children: [
                  _SupportReasonCard(
                    icon: Icons.bug_report_outlined,
                    title: isAr ? 'الإبلاغ عن مشكلة' : 'Report Issue',
                  ),
                  _SupportReasonCard(
                    icon: Icons.lightbulb_outline_rounded,
                    title: isAr ? 'اقتراح ميزة' : 'Suggest Feature',
                  ),
                  _SupportReasonCard(
                    icon: Icons.badge_outlined,
                    title: isAr ? 'دعم المرشدين' : 'Guide Support',
                  ),
                  _SupportReasonCard(
                    icon: Icons.volunteer_activism_outlined,
                    title: isAr ? 'المساهمات الثقافية' : 'Contributions',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _MessageFormCard(isAr: isAr),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.colorScheme.primary == Colors.black;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isHighContrast
              ? Colors.black
              : theme.dividerColor.withValues(alpha: 0.12),
          width: isHighContrast ? 2 : 1,
        ),
        boxShadow: isHighContrast
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _SupportReasonCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SupportReasonCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.colorScheme.primary == Colors.black;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighContrast
              ? Colors.black
              : theme.colorScheme.primary.withValues(alpha: 0.14),
          width: isHighContrast ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageFormCard extends StatelessWidget {
  final bool isAr;

  const _MessageFormCard({
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.colorScheme.primary == Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighContrast
              ? Colors.black
              : theme.dividerColor.withValues(alpha: 0.12),
          width: isHighContrast ? 2 : 1,
        ),
        boxShadow: isHighContrast
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'أرسل رسالة' : 'Send a Message',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isAr
                ? 'اكتب رسالتك وسنراجعها في أقرب وقت.'
                : 'Write your message and we will review it as soon as possible.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            decoration: InputDecoration(
              hintText: isAr ? 'الاسم' : 'Your Name',
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            decoration: InputDecoration(
              hintText: isAr ? 'البريد الإلكتروني' : 'Your Email',
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: isAr ? 'اكتب رسالتك هنا...' : 'Write your message here...',
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAr
                          ? 'تم إرسال رسالتك بنجاح'
                          : 'Your message has been sent successfully',
                    ),
                  ),
                );
              },
              child: Text(
                isAr ? 'إرسال الرسالة' : 'Send Message',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}