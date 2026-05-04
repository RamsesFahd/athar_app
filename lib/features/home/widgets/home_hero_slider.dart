import 'dart:async';
import 'package:flutter/material.dart';

class HomeHeroSlider extends StatefulWidget {
  const HomeHeroSlider({super.key});

  @override
  State<HomeHeroSlider> createState() => _HomeHeroSliderState();
}

class _HomeHeroSliderState extends State<HomeHeroSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controller.hasClients) {
        int nextPage = _currentIndex + 1;

        if (nextPage >= 3) {
          nextPage = 0;
        }

        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final images = [
      isAr
          ? 'assets/images/saudi_heritage_journey_ar.png'
          : 'assets/images/saudi_heritage_journey_en.png',
      isAr
          ? 'assets/images/legacy_of_the_past_ar.png'
          : 'assets/images/legacy_of_the_past_en.png',
      isAr
          ? 'assets/images/journey_to_saudi_heritage_ar.png'
          : 'assets/images/journey_to_saudi_heritage_en.png',
    ];

    return SizedBox(
      height: 420, // كبرنا السلايدر
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return Image.asset(
                images[index],
                width: double.infinity,
                height: 420,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              );
            },
          ),

          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = index == _currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: isActive ? 0.95 : 0.45,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}