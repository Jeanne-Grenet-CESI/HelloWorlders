import 'package:flutter/material.dart';

class EmptyStateDisplay extends StatelessWidget {
  final String message;
  final IconData? icon;
  final double iconSize;
  final VoidCallback? onActionPressed;
  final String? actionButtonText;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final Color? iconColor;
  final ButtonStyle? buttonStyle;

  const EmptyStateDisplay({
    Key? key,
    required this.message,
    this.icon,
    this.iconSize = 64,
    this.onActionPressed,
    this.actionButtonText,
    this.padding = const EdgeInsets.all(24.0),
    this.textStyle,
    this.iconColor,
    this.buttonStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 16,
    );

    final defaultIconColor = Theme.of(context).colorScheme.primary;

    final defaultButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 1,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? defaultIconColor,
              ),
              const SizedBox(height: 24),
            ],
            Text(
              message,
              style: textStyle ?? defaultTextStyle,
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionButtonText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: buttonStyle ?? defaultButtonStyle,
                child: Text(actionButtonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
