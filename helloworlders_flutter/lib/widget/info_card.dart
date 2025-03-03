import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoCard({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.children = const [],
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 2,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                Center(child: leading!),
                const SizedBox(height: 16),
              ],
              if (title.isNotEmpty) ...[
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(height: 8),
                Center(child: trailing!),
              ],
              if (children.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...children,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
