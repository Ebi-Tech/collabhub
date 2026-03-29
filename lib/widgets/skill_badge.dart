import 'package:flutter/material.dart';
import 'package:collabhub/utils/constants.dart';

// small chip for displaying a skill tag
class SkillBadge extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;

  const SkillBadge({super.key, required this.label, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 4, onRemove != null ? 6 : 10, 4),
      decoration: BoxDecoration(
        color: AppColors.badgeBg(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface(context),
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 14, color: AppColors.gray500),
            ),
          ],
        ],
      ),
    );
  }
}
