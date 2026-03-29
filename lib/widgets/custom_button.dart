import 'package:flutter/material.dart';
import 'package:collabhub/utils/constants.dart';

enum AppButtonVariant { primary, outline }
enum AppButtonSize { normal, small }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.normal,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == AppButtonVariant.primary;
    final isSmall = size == AppButtonSize.small;

    final bg = isPrimary ? AppColors.primary : Colors.transparent;
    final fgColor = isPrimary ? AppColors.white : AppColors.onSurface(context);
    final border = isPrimary
        ? BorderSide.none
        : const BorderSide(color: AppColors.cardBorder);

    final vPad = isSmall ? 6.0 : 10.0;
    final hPad = isSmall ? 12.0 : 16.0;
    final fontSize = isSmall ? 14.0 : 16.0;

    Widget content = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fgColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                  height: 1.5,
                ),
              ),
            ],
          );

    final btn = Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: (onPressed != null && !isLoading) ? onPressed : null,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
          decoration: BoxDecoration(
            border: Border.all(
              color: border.color,
              width: border == BorderSide.none ? 0 : 1,
              style: border == BorderSide.none
                  ? BorderStyle.none
                  : BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: content,
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
