import 'package:flutter/material.dart';

class DetailInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  const DetailInfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.padding = const EdgeInsets.only(bottom: 6.0),
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultLabelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.secondary,
    );

    final defaultValueStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "$label : ",
            style: labelStyle ?? defaultLabelStyle,
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? defaultValueStyle,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
