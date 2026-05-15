import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/core/constants/region_city_constants.dart';

void main() {
  group('RegionCityConstants', () {
    // ─── regionLabel ────────────────────────────────────────────────────────

    group('regionLabel', () {
      test(
          'UT-47: regionLabel: "central" isArabic=true → "المنطقة الوسطى"',
          () {
        // Arrange
        const regionId = 'central';

        // Act
        final label = regionLabel(regionId, isArabic: true);

        // Assert — value from regionMap in source
        expect(label, 'المنطقة الوسطى');
      });

      test(
          'UT-48: regionLabel: "central" isArabic=false → "Central Region"',
          () {
        // Arrange
        const regionId = 'central';

        // Act
        final label = regionLabel(regionId, isArabic: false);

        // Assert
        expect(label, 'Central Region');
      });

      test(
          'UT-49: regionLabel: unknown "xyz_unknown" isArabic=true → falls back to the key itself',
          () {
        // Arrange
        const regionId = 'xyz_unknown';

        // Act
        final label = regionLabel(regionId, isArabic: true);

        // Assert — source: regionMap[regionId]?[...] ?? regionId
        expect(label, regionId);
      });
    });

    // ─── cityLabel ──────────────────────────────────────────────────────────

    group('cityLabel', () {
      test('UT-50: cityLabel: "riyadh" isArabic=true → "الرياض"', () {
        // Arrange
        const cityId = 'riyadh';

        // Act
        final label = cityLabel(cityId, isArabic: true);

        // Assert
        expect(label, 'الرياض');
      });

      test('UT-51: cityLabel: "riyadh" isArabic=false → "Riyadh"', () {
        // Arrange
        const cityId = 'riyadh';

        // Act
        final label = cityLabel(cityId, isArabic: false);

        // Assert
        expect(label, 'Riyadh');
      });
    });
  });
}
