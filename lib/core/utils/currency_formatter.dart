import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrencyFormatter {
  static const String _riyalAssetPath = 'assets/icons/saudi_riyal.svg';

  /// Formats the amount as a Widget with the Saudi Riyal symbol as an SVG.
  /// Use this whenever displaying prices in the UI.
  static Widget format(
    num amount, {
    int decimals = 0,
    TextStyle? style,
    double? symbolSize,
  }) {
    return _RiyalPrice(
      amount: amount,
      decimals: decimals,
      style: style,
      symbolSize: symbolSize,
    );
  }

  /// Returns only the numeric value as a string (no symbol).
  /// Use this when you need the value alone (e.g. for input fields).
  static String formatNumber(num amount, {int decimals = 0}) {
    return decimals > 0
        ? amount.toStringAsFixed(decimals)
        : amount.toInt().toString();
  }
}

class _RiyalPrice extends StatelessWidget {
  final num amount;
  final int decimals;
  final TextStyle? style;
  final double? symbolSize;

  const _RiyalPrice({
    required this.amount,
    required this.decimals,
    this.style,
    this.symbolSize,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final size = symbolSize ?? (textStyle?.fontSize ?? 14);
    final color = textStyle?.color ?? 
        Theme.of(context).textTheme.bodyMedium?.color;

    final formattedAmount = decimals > 0
        ? amount.toStringAsFixed(decimals)
        : amount.toInt().toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(formattedAmount, style: textStyle),
        const SizedBox(width: 4),
        SvgPicture.asset(
          CurrencyFormatter._riyalAssetPath,
          height: size,
          width: size,
          colorFilter: color != null
              ? ColorFilter.mode(color, BlendMode.srcIn)
              : null,
        ),
      ],
    );
  }
}