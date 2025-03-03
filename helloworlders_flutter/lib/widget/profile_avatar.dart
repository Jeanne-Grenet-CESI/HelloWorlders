import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/global/utils.dart';
import 'dart:io';

class ProfileAvatar extends StatelessWidget {
  final String? imageRepository;
  final String? imageFileName;
  final File? imageFile;
  final String? initials;
  final double radius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color textColor;
  final IconData? icon;

  const ProfileAvatar({
    Key? key,
    this.imageRepository,
    this.imageFileName,
    this.imageFile,
    this.initials,
    this.radius = 40,
    this.onTap,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = Theme.of(context).colorScheme.primary;

    if (imageFile != null) {
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(imageFile!),
          backgroundColor: backgroundColor ?? defaultBackgroundColor,
        ),
      );
    } else if (imageRepository != null && imageFileName != null) {
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(
            Global.getImagePath(imageRepository!, imageFileName!),
          ),
          backgroundColor: backgroundColor ?? defaultBackgroundColor,
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? defaultBackgroundColor,
          child: initials != null && initials!.isNotEmpty
              ? Text(
                  initials!.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: radius * 0.8,
                    color: textColor,
                  ),
                )
              : Icon(
                  icon ?? Icons.person,
                  size: radius * 0.8,
                  color: textColor,
                ),
        ),
      );
    }
  }
}
