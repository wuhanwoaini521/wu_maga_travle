/// 漫画风格容器组件
/// 提供粗描边、阴影、不规则边框等漫画效果

import 'package:flutter/material.dart';
import '../../../core/theme/comic_theme.dart';

/// 漫画风格容器 - 基础组件
/// 
/// 特性:
/// - 粗黑描边 (Outlines)
/// - 硬边阴影 (Hard shadows)
/// - 可选的不规则边框
/// - 渐变背景支持
class ComicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final double borderWidth;
  final Color borderColor;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;
  final bool irregular;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  const ComicContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradientColors,
    this.borderWidth = 3.0,
    this.borderColor = ComicColors.outline,
    this.borderRadius = 12.0,
    this.shadows,
    this.width,
    this.height,
    this.irregular = false,
    this.onTap,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: gradientColors == null ? (backgroundColor ?? Colors.white) : null,
        gradient: gradientColors != null
            ? LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: irregular ? null : BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadows ?? ComicShadows.standard,
      ),
      child: child,
    );

    // 不规则边框使用 CustomPaint
    if (irregular) {
      container = CustomPaint(
        painter: _IrregularBorderPainter(
          color: borderColor,
          width: borderWidth,
          radius: borderRadius,
        ),
        child: ClipPath(
          clipper: _IrregularClipper(radius: borderRadius),
          child: container,
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 100),
          child: container,
        ),
      );
    }

    return container;
  }
}

/// 漫画风格按钮
class ComicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isOutlined;
  final bool isAccent;

  const ComicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.icon,
    this.isOutlined = false,
    this.isAccent = false,
  });

  @override
  State<ComicButton> createState() => _ComicButtonState();
}

class _ComicButtonState extends State<ComicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isOutlined
        ? Colors.white
        : (widget.backgroundColor ??
            (widget.isAccent ? ComicColors.accent : ComicColors.primary));
    
    final fgColor = widget.isOutlined
        ? ComicColors.textPrimary
        : (widget.textColor ?? Colors.white);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(
          _isPressed ? 2 : 0,
          _isPressed ? 2 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ComicColors.outline, width: 3),
          boxShadow: _isPressed
              ? []
              : [
                  const BoxShadow(
                    color: ComicColors.outline,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fgColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: ComicTextStyles.button.copyWith(color: fgColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 漫画风格卡片
class ComicCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? header;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const ComicCard({
    super.key,
    required this.child,
    this.title,
    this.header,
    this.backgroundColor,
    this.gradientColors,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ComicContainer(
      backgroundColor: backgroundColor,
      gradientColors: gradientColors,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: 12),
          ],
          if (title != null) ...[
            Text(title!, style: ComicTextStyles.title),
            const SizedBox(height: 8),
          ],
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// 漫画风格徽章/标签
class ComicBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isPill;
  final IconData? icon;

  const ComicBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.isPill = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? ComicColors.primary,
        borderRadius: BorderRadius.circular(isPill ? 20 : 8),
        border: Border.all(color: ComicColors.outline, width: 2),
        boxShadow: ComicShadows.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor ?? Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: ComicTextStyles.badge.copyWith(
              color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 漫画风格输入框
class ComicTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final bool readOnly;

  const ComicTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ComicColors.outline, width: 3),
        boxShadow: ComicShadows.small,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onTap: onTap,
        onChanged: onChanged,
        maxLines: maxLines,
        readOnly: readOnly,
        style: ComicTextStyles.body,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: ComicTextStyles.body.copyWith(
            color: ComicColors.textSecondary,
          ),
          labelText: labelText,
          labelStyle: ComicTextStyles.body.copyWith(
            color: ComicColors.textSecondary,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// 不规则边框绘制器
class _IrregularBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  final double radius;

  _IrregularBorderPainter({
    required this.color,
    required this.width,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _createIrregularPath(size, radius);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  Path _createIrregularPath(Size size, double radius) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = radius;

    // 创建略微不规则的圆角矩形
    path.moveTo(r + _randomOffset(2), _randomOffset(2));
    
    // 上边
    path.lineTo(w - r + _randomOffset(2), _randomOffset(2));
    path.quadraticBezierTo(
      w + _randomOffset(2), _randomOffset(2),
      w + _randomOffset(2), r + _randomOffset(2),
    );
    
    // 右边
    path.lineTo(w + _randomOffset(2), h - r + _randomOffset(2));
    path.quadraticBezierTo(
      w + _randomOffset(2), h + _randomOffset(2),
      w - r + _randomOffset(2), h + _randomOffset(2),
    );
    
    // 下边
    path.lineTo(r + _randomOffset(2), h + _randomOffset(2));
    path.quadraticBezierTo(
      _randomOffset(2), h + _randomOffset(2),
      _randomOffset(2), h - r + _randomOffset(2),
    );
    
    // 左边
    path.lineTo(_randomOffset(2), r + _randomOffset(2));
    path.quadraticBezierTo(
      _randomOffset(2), _randomOffset(2),
      r + _randomOffset(2), _randomOffset(2),
    );
    
    path.close();
    return path;
  }

  double _randomOffset(double max) => (max * 0.5) - (max * 0.25);
}

/// 不规则裁剪器
class _IrregularClipper extends CustomClipper<Path> {
  final double radius;

  _IrregularClipper({required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = radius;

    path.moveTo(r, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldDelegate) => false;
}

/// 漫画风格加载动画
class ComicLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const ComicLoading({
    super.key,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation(
          color ?? ComicColors.primary,
        ),
      ),
    );
  }
}

/// 漫画风格分割线 (速度线效果)
class ComicDivider extends StatelessWidget {
  final double height;
  final Color? color;
  final bool isVertical;

  const ComicDivider({
    super.key,
    this.height = 3,
    this.color,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Container(
        width: height,
        color: color ?? ComicColors.outline,
      );
    }
    return Container(
      height: height,
      color: color ?? ComicColors.outline,
    );
  }
}
