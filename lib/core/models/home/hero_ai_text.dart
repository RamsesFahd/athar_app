class HeroAiText {
  final String titleAr;
  final String subtitleAr;
  final String titleEn;
  final String subtitleEn;

  const HeroAiText({
    required this.titleAr,
    required this.subtitleAr,
    required this.titleEn,
    required this.subtitleEn,
  });

  Map<String, dynamic> toMap() => {
        'titleAr': titleAr,
        'subtitleAr': subtitleAr,
        'titleEn': titleEn,
        'subtitleEn': subtitleEn,
      };

  factory HeroAiText.fromMap(Map<String, dynamic> map) => HeroAiText(
        titleAr: map['titleAr']?.toString() ?? '',
        subtitleAr: map['subtitleAr']?.toString() ?? '',
        titleEn: map['titleEn']?.toString() ?? '',
        subtitleEn: map['subtitleEn']?.toString() ?? '',
      );
}
