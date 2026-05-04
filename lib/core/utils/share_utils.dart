import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareUtils {
  ShareUtils._();

  static void shareCulturalItem({
    required BuildContext context,
    required String titleAr,
    required String titleEn,
    required String regionAr,
    required String regionEn,
    required String descriptionAr,
    required String descriptionEn,
    required bool isAr,
  }) {
    final title = isAr ? titleAr : titleEn;
    final region = isAr ? regionAr : regionEn;
    final fullDesc = isAr ? descriptionAr : descriptionEn;
    final desc = fullDesc.length > 120
        ? '${fullDesc.substring(0, 120)}...'
        : fullDesc;
    final appTag = isAr ? 'تطبيق أثر' : 'Athar App';
    final text = '$title\n$region\n\n$desc\n\n$appTag';
    _copyAndNotify(context: context, text: text, isAr: isAr);
  }

  static void shareTrip({
    required BuildContext context,
    required String titleAr,
    required String titleEn,
    required String cityAr,
    required String cityEn,
    required double adultPrice,
    required bool isAr,
  }) {
    final text =
        '$titleAr | $titleEn\n$cityAr | $cityEn\n${adultPrice.toInt()} SAR\nAthar App';
    _copyAndNotify(context: context, text: text, isAr: isAr);
  }

  static void _copyAndNotify({
    required BuildContext context,
    required String text,
    required bool isAr,
  }) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAr ? 'تم نسخ النص' : 'Text copied'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
