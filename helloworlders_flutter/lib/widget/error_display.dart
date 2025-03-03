import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final String retryButtonText;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;

  const ErrorDisplay({
    Key? key,
    required this.errorMessage,
    this.onRetry,
    this.retryButtonText = 'Réessayer',
    this.padding = const EdgeInsets.all(16.0),
    this.textStyle,
    this.buttonStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = const TextStyle(
      color: Colors.red,
      fontSize: 16,
    );

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
            Text(
              errorMessage,
              style: textStyle ?? defaultTextStyle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: buttonStyle ?? defaultButtonStyle,
                child: Text(retryButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
