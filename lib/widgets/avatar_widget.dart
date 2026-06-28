import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double radius;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.initials,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        color: AppColors.surface,
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(imageUrl!, fit: BoxFit.cover)
            : Center(
                child: Text(
                  initials.isNotEmpty ? initials[0].toUpperCase() : '?',
                  style: AppTextStyles.font(
                    context,
                    fontSize: radius * 0.8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
      ),
    );
  }
}
