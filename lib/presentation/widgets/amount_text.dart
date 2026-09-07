import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _fmt = NumberFormat('#,###');

class AmountText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showSign;

  const AmountText({
    super.key,
    required this.amount,
    this.style,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final sign = showSign && amount > 0 ? '+' : '';
    return Text(
      '$sign¥${_fmt.format(amount.abs())}',
      style: style,
    );
  }
}
