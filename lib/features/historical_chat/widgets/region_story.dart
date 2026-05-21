import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:athar_app/features/historical_chat/screens/chat_screen.dart';
import 'package:athar_app/core/constants/region_data.dart'; //
import 'package:athar_app/generated/l10n/app_localizations.dart';

class RegionStoryScreen extends StatefulWidget {
  final int initialIndex;

  const RegionStoryScreen({super.key, required this.initialIndex});

  @override
  State<RegionStoryScreen> createState() => _RegionStoryScreenState();
}

class _RegionStoryScreenState extends State<RegionStoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // إعداد التايمر لمدة 10 ثوانٍ
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _animController.addListener(() {
      setState(() {});
    });

    _startStory();
  }

  void _startStory() {
    _animController.reset();
    _animController.forward().whenComplete(() {
      _nextStory();
    });
  }

  void _nextStory() {
    if (_currentIndex < regionsData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) Navigator.pop(context);
        },
        onLongPressStart: (_) => _animController.stop(),
        onLongPressEnd: (_) => _animController.forward(),
        child: Stack(
          children: [
            // عرض صور المناطق
            PageView.builder(
              controller: _pageController,
              itemCount: regionsData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _startStory();
              },
              itemBuilder: (context, index) {
                final region = regionsData[index];
                final isAr =
                    Localizations.localeOf(context).languageCode == 'ar';

                final imagePath = switch (region.regionId) {
                  'central_region' => isAr
                      ? 'assets/images/central_ar.png'
                      : 'assets/images/central_en.png',
                  'western_region' => isAr
                      ? 'assets/images/western_ar.png'
                      : 'assets/images/western_en.png',
                  'northern_region' => isAr
                      ? 'assets/images/northern_ar.png'
                      : 'assets/images/northern_en.png',
                  'eastern_region' => isAr
                      ? 'assets/images/eastern_ar.png'
                      : 'assets/images/eastern_en.png',
                  'southern_region' => isAr
                      ? 'assets/images/southern_ar.png'
                      : 'assets/images/southern_en.png',
                  _ => region.storyImage,
                };

                return Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                );
              },
            ),

            // (1) شريط تقدم واحد كامل العرض لكل ستوري
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  // يأخذ القيمة الحالية للأنيميشن مباشرة (من 0 إلى 1)
                  value: _animController.value,
                  backgroundColor:
                      theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary),
                  minHeight: 3, // سمك الشريط
                ),
              ),
            ),

            // زر الانتقال للشات
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 24),
                child: _buildGlassButton(regionsData[_currentIndex]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton(dynamic region) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF354431).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
              ),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 60),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(region: region)),
                );
              },
              child: Text(
                l10n.rawiStoryStartChat,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
