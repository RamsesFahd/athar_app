import 'package:flutter/material.dart';
import 'package:athar_app/core/theme/app_theme.dart';

class AboutAtharScreen extends StatelessWidget {
  const AboutAtharScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isAr, theme),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _QuoteCard(
                    text: isAr
                        ? 'أثر ليس مجرد تطبيق، بل رحلة رقمية تربط الماضي بالحاضر، وتحول التراث السعودي إلى تجربة حية يمكن اكتشافها، فهمها، ومشاركتها.'
                        : 'Athar is not just an app. It is a digital journey that connects the past with the present and turns Saudi heritage into a living experience.',
                  ),
                  const SizedBox(height: 28),

                  _SectionTitle(
                    title: isAr ? 'لماذا أثر؟' : 'Why Athar?',
                    subtitle: isAr
                        ? 'لأن التراث يحتاج مساحة حديثة تحفظه وتقرّبه من الناس.'
                        : 'Because heritage deserves a modern space that preserves it and brings it closer to people.',
                  ),
                  const SizedBox(height: 16),

                  _InfoCard(
                    icon: Icons.auto_stories_outlined,
                    title: isAr ? 'قصص تستحق أن تُروى' : 'Stories worth telling',
                    desc: isAr
                        ? 'نساعد المستخدمين على فهم الحكايات خلف الأماكن والعادات والتجارب الثقافية.'
                        : 'We help users understand the stories behind places, traditions, and cultural experiences.',
                  ),
                  _InfoCard(
                    icon: Icons.explore_outlined,
                    title: isAr ? 'اكتشاف تفاعلي' : 'Interactive discovery',
                    desc: isAr
                        ? 'استكشف المواقع التراثية والفعاليات والتجارب بطريقة سهلة ومرئية.'
                        : 'Explore heritage sites, events, and experiences in a simple visual way.',
                  ),
                  _InfoCard(
                    icon: Icons.volunteer_activism_outlined,
                    title: isAr ? 'حفظ ومشاركة' : 'Preserve and share',
                    desc: isAr
                        ? 'يتيح أثر للمجتمع المساهمة في توثيق التراث ونقله للأجيال القادمة.'
                        : 'Athar allows the community to contribute to documenting heritage for future generations.',
                  ),

                  const SizedBox(height: 28),

                  _SectionTitle(
                    title: isAr ? 'رحلتك داخل أثر' : 'Your Journey in Athar',
                    subtitle: isAr
                        ? 'من الاكتشاف إلى المشاركة، كل خطوة تقرّبك من الثقافة.'
                        : 'From discovery to contribution, every step brings culture closer.',
                  ),
                  const SizedBox(height: 16),

                  _JourneyStep(
                    number: '01',
                    title: isAr ? 'اكتشف' : 'Discover',
                    desc: isAr
                        ? 'تصفح المواقع والمعالم والقصص التراثية.'
                        : 'Browse heritage places, landmarks, and stories.',
                  ),
                  _JourneyStep(
                    number: '02',
                    title: isAr ? 'استمع لراوي' : 'Listen to Rawi',
                    desc: isAr
                        ? 'تعرف على الحكايات الثقافية بطريقة ذكية ومبسطة.'
                        : 'Learn cultural stories through smart storytelling.',
                  ),
                  _JourneyStep(
                    number: '03',
                    title: isAr ? 'عِش التجربة' : 'Experience',
                    desc: isAr
                        ? 'احضر فعاليات أو تواصل مع مرشدين موثوقين.'
                        : 'Attend events or connect with verified local guides.',
                  ),
                  _JourneyStep(
                    number: '04',
                    title: isAr ? 'ساهم' : 'Contribute',
                    desc: isAr
                        ? 'شارك محتوى ثقافي يساعد في حفظ التراث.'
                        : 'Share cultural content that helps preserve heritage.',
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: Text(
                      isAr
                          ? 'لأن لكل تراثٍ أثرًا يستحق أن يبقى.'
                          : 'Because every heritage leaves a trace worth preserving.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Athar v1.0',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAr, ThemeData theme) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/about_athar.jpeg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.80),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: isAr ? Alignment.topRight : Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  isAr
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          PositionedDirectional(
            start: 20,
            end: 20,
            bottom: 20,
            child: Text(
              isAr
                  ? 'كل أرض لها حكاية…\nوأثر يأخذك لاكتشافها.'
                  : 'Every land has a story.\nAthar helps you discover it.',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.35,
                shadows: const [
                  Shadow(color: Colors.black87, blurRadius: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String text;

  const _QuoteCard({required this.text});

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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighContrast
              ? theme.colorScheme.onSurface
              : theme.dividerColor.withValues(alpha: 0.12),
          width: isHighContrast ? 2 : 1,
        ),
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
                  desc,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  final String number;
  final String title;
  final String desc;

  const _JourneyStep({
    required this.number,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.18),
                  ),
                ),
              ),
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
                    desc,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
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
