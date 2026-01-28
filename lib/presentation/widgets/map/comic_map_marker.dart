/// 漫画风格地图标记组件
/// 自定义大头针、地标插画、弹跳动画效果

import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/comic_theme.dart';

/// 漫画风格地图标记数据
class ComicMapMarkerData {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String? subtitle;
  final MarkerCategory category;
  final String? imageUrl;
  final double? rating;
  final bool isFavorite;
  final VoidCallback? onTap;

  const ComicMapMarkerData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.subtitle,
    this.category = MarkerCategory.other,
    this.imageUrl,
    this.rating,
    this.isFavorite = false,
    this.onTap,
  });
}

/// 标记分类
enum MarkerCategory {
  food,
  attraction,
  hotel,
  shopping,
  photo,
  transport,
  other,
}

/// 漫画风格标记图标生成器
class ComicMarkerIcon extends StatelessWidget {
  final MarkerCategory category;
  final bool isSelected;
  final bool isFavorite;
  final double size;

  const ComicMarkerIcon({
    super.key,
    required this.category,
    this.isSelected = false,
    this.isFavorite = false,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size * 1.3,
      child: CustomPaint(
        painter: _MarkerPainter(
          category: category,
          isSelected: isSelected,
          isFavorite: isFavorite,
        ),
        size: Size(size, size * 1.3),
      ),
    );
  }
}

/// 标记绘制器
class _MarkerPainter extends CustomPainter {
  final MarkerCategory category;
  final bool isSelected;
  final bool isFavorite;

  _MarkerPainter({
    required this.category,
    this.isSelected = false,
    this.isFavorite = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pinHeadRadius = w * 0.4;
    
    // 选择颜色
    final color = _getCategoryColor();
    final accentColor = isSelected ? ComicColors.accent : color;

    // 绘制阴影
    _drawShadow(canvas, w, h, pinHeadRadius);

    // 绘制大头针主体
    _drawPinBody(canvas, w, h, pinHeadRadius, accentColor);

    // 绘制描边
    _drawOutline(canvas, w, h, pinHeadRadius);

    // 绘制图标
    _drawIcon(canvas, w, pinHeadRadius);

    // 绘制收藏标记
    if (isFavorite) {
      _drawFavoriteBadge(canvas, w);
    }

    // 选中效果 - 外圈光环
    if (isSelected) {
      _drawSelectionRing(canvas, w, pinHeadRadius);
    }
  }

  void _drawShadow(Canvas canvas, double w, double h, double radius) {
    final shadowPaint = Paint()
      ..color = ComicColors.outline.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // 阴影偏移
    canvas.save();
    canvas.translate(3, 3);
    
    final path = Path();
    path.addOval(Rect.fromCircle(
      center: Offset(w / 2, radius),
      radius: radius,
    ));
    path.moveTo(w / 2 - radius * 0.4, radius * 1.8);
    path.lineTo(w / 2, h - 2);
    path.lineTo(w / 2 + radius * 0.4, radius * 1.8);
    path.close();
    
    canvas.drawPath(path, shadowPaint);
    canvas.restore();
  }

  void _drawPinBody(Canvas canvas, double w, double h, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 绘制圆形头部
    canvas.drawCircle(
      Offset(w / 2, radius),
      radius,
      paint,
    );

    // 绘制针尖
    final pinPath = Path();
    pinPath.moveTo(w / 2 - radius * 0.4, radius * 1.5);
    pinPath.lineTo(w / 2, h);
    pinPath.lineTo(w / 2 + radius * 0.4, radius * 1.5);
    pinPath.close();
    canvas.drawPath(pinPath, paint);

    // 绘制高光 (漫画风格)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(w / 2 - radius * 0.3, radius * 0.7),
      radius * 0.25,
      highlightPaint,
    );
  }

  void _drawOutline(Canvas canvas, double w, double h, double radius) {
    final outlinePaint = Paint()
      ..color = ComicColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 头部描边
    canvas.drawCircle(
      Offset(w / 2, radius),
      radius,
      outlinePaint,
    );

    // 针尖描边
    final pinPath = Path();
    pinPath.moveTo(w / 2 - radius * 0.4, radius * 1.5);
    pinPath.lineTo(w / 2, h);
    pinPath.lineTo(w / 2 + radius * 0.4, radius * 1.5);
    canvas.drawPath(pinPath, outlinePaint);
  }

  void _drawIcon(Canvas canvas, double w, double radius) {
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(w / 2, radius);
    final iconSize = radius * 0.5;

    switch (category) {
      case MarkerCategory.food:
        // 绘制餐具图标简化版
        _drawFoodIcon(canvas, center, iconSize, iconPaint);
        break;
      case MarkerCategory.attraction:
        // 绘制地标图标
        _drawAttractionIcon(canvas, center, iconSize, iconPaint);
        break;
      case MarkerCategory.hotel:
        // 绘制床图标
        _drawHotelIcon(canvas, center, iconSize, iconPaint);
        break;
      case MarkerCategory.shopping:
        // 绘制购物袋图标
        _drawShoppingIcon(canvas, center, iconSize, iconPaint);
        break;
      case MarkerCategory.photo:
        // 绘制相机图标
        _drawPhotoIcon(canvas, center, iconSize, iconPaint);
        break;
      case MarkerCategory.transport:
        // 绘制交通图标
        _drawTransportIcon(canvas, center, iconSize, iconPaint);
        break;
      default:
        // 绘制点
        canvas.drawCircle(center, iconSize * 0.3, iconPaint);
    }
  }

  void _drawFoodIcon(Canvas canvas, Offset center, double size, Paint paint) {
    // 简化叉子
    final path = Path();
    path.moveTo(center.dx - size * 0.2, center.dy - size * 0.3);
    path.lineTo(center.dx - size * 0.2, center.dy + size * 0.3);
    path.moveTo(center.dx + size * 0.2, center.dy - size * 0.3);
    path.lineTo(center.dx + size * 0.2, center.dy + size * 0.3);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  void _drawAttractionIcon(Canvas canvas, Offset center, double size, Paint paint) {
    // 简化塔/建筑
    final path = Path();
    path.moveTo(center.dx, center.dy - size * 0.4);
    path.lineTo(center.dx - size * 0.3, center.dy + size * 0.4);
    path.lineTo(center.dx + size * 0.3, center.dy + size * 0.4);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHotelIcon(Canvas canvas, Offset center, double size, Paint paint) {
    // 简化床
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size * 0.8, height: size * 0.5),
      paint,
    );
  }

  void _drawShoppingIcon(Canvas canvas, Offset center, double size, Paint paint) {
    // 简化购物袋
    final path = Path();
    path.addRect(Rect.fromCenter(center: center, width: size * 0.6, height: size * 0.6));
    canvas.drawPath(path, paint);
    // 提手
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy - size * 0.2), width: size * 0.3, height: size * 0.3),
      3.14,
      3.14,
      false,
      paint..style = PaintingStyle.stroke..strokeWidth = 2,
    );
  }

  void _drawPhotoIcon(Canvas canvas, Offset center, double size, Paint paint) {
    // 简化相机
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size * 0.8, height: size * 0.5),
      paint,
    );
    canvas.drawCircle(center, size * 0.2, paint..color = ComicColors.outline);
  }

  void _drawTransportIcon(Canvas canvas, Offset center, double size, Paint paint) {
    // 简化火车/地铁
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - size * 0.3, center.dy - size * 0.3),
      Offset(center.dx + size * 0.3, center.dy - size * 0.3),
      paint..style = PaintingStyle.stroke..strokeWidth = 2,
    );
  }

  void _drawFavoriteBadge(Canvas canvas, double w) {
    final paint = Paint()
      ..color = ComicColors.highlight
      ..style = PaintingStyle.fill;

    // 心形简化
    final center = Offset(w * 0.8, w * 0.2);
    canvas.drawCircle(center, 8, paint);
    
    // 白色心形
    final heartPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, heartPaint);
  }

  void _drawSelectionRing(Canvas canvas, double w, double radius) {
    final ringPaint = Paint()
      ..color = ComicColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // 外圈光环
    canvas.drawCircle(
      Offset(w / 2, radius),
      radius + 6,
      ringPaint,
    );

    // 放射线效果 (漫画风格)
    final linePaint = Paint()
      ..color = ComicColors.accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 3.14159 * 2;
      final startR = radius + 10;
      final endR = radius + 18;
      
      canvas.drawLine(
        Offset(
          w / 2 + startR * cos(angle),
          radius + startR * sin(angle),
        ),
        Offset(
          w / 2 + endR * cos(angle),
          radius + endR * sin(angle),
        ),
        linePaint,
      );
    }
  }

  Color _getCategoryColor() {
    switch (category) {
      case MarkerCategory.food:
        return const Color(0xFFFF6B35); // 橙色
      case MarkerCategory.attraction:
        return const Color(0xFFE74C3C); // 红色
      case MarkerCategory.hotel:
        return const Color(0xFF3498DB); // 蓝色
      case MarkerCategory.shopping:
        return const Color(0xFF9B59B6); // 紫色
      case MarkerCategory.photo:
        return const Color(0xFF2ECC71); // 绿色
      case MarkerCategory.transport:
        return const Color(0xFF1ABC9C); // 青色
      default:
        return const Color(0xFF95A5A6); // 灰色
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 漫画风格信息窗口 (点击标记后弹出)
class ComicInfoWindow extends StatelessWidget {
  final ComicMapMarkerData data;
  final VoidCallback? onClose;
  final VoidCallback? onNavigate;
  final VoidCallback? onFavorite;

  const ComicInfoWindow({
    super.key,
    required this.data,
    this.onClose,
    this.onNavigate,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ComicColors.outline, width: 3),
        boxShadow: ComicShadows.standard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          if (data.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: Stack(
                children: [
                  Image.network(
                    data.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // 关闭按钮
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildActionButton(
                      Icons.close,
                      onClose,
                      Colors.white,
                      ComicColors.outline,
                    ),
                  ),
                ],
              ),
            ),

          // 内容区域
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和分类
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: ComicTextStyles.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildCategoryBadge(),
                  ],
                ),
                
                if (data.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle!,
                    style: ComicTextStyles.body.copyWith(
                      color: ComicColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // 评分
                if (data.rating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        final filled = index < data.rating!.floor();
                        return Icon(
                          filled ? Icons.star : Icons.star_border,
                          size: 16,
                          color: ComicColors.accent,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        data.rating!.toStringAsFixed(1),
                        style: ComicTextStyles.badge.copyWith(
                          color: ComicColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                // 操作按钮
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildComicButton(
                        '导航',
                        Icons.navigation,
                        ComicColors.primary,
                        onNavigate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildComicButton(
                      '',
                      data.isFavorite ? Icons.favorite : Icons.favorite_border,
                      data.isFavorite ? ComicColors.highlight : ComicColors.textSecondary,
                      onFavorite,
                      isSmall: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final colors = {
      MarkerCategory.food: ComicColors.primary,
      MarkerCategory.attraction: Colors.red,
      MarkerCategory.hotel: Colors.blue,
      MarkerCategory.shopping: Colors.purple,
      MarkerCategory.photo: Colors.green,
      MarkerCategory.transport: Colors.teal,
      MarkerCategory.other: Colors.grey,
    };

    final labels = {
      MarkerCategory.food: '美食',
      MarkerCategory.attraction: '景点',
      MarkerCategory.hotel: '酒店',
      MarkerCategory.shopping: '购物',
      MarkerCategory.photo: '拍照',
      MarkerCategory.transport: '交通',
      MarkerCategory.other: '其他',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[data.category],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ComicColors.outline, width: 1.5),
      ),
      child: Text(
        labels[data.category]!,
        style: ComicTextStyles.badge.copyWith(fontSize: 10),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback? onTap,
    Color bgColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: ComicColors.outline, width: 2),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  Widget _buildComicButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isSmall ? 36 : 40,
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 8 : 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ComicColors.outline, width: 2),
          boxShadow: ComicShadows.small,
        ),
        child: Center(
          child: label.isEmpty
              ? Icon(icon, color: Colors.white, size: 18)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: ComicTextStyles.button.copyWith(fontSize: 13),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// 标记弹跳动画包装器
class BouncingMarker extends StatefulWidget {
  final Widget child;
  final bool shouldBounce;

  const BouncingMarker({
    super.key,
    required this.child,
    this.shouldBounce = false,
  });

  @override
  State<BouncingMarker> createState() => _BouncingMarkerState();
}

class _BouncingMarkerState extends State<BouncingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -15.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 0.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(BouncingMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldBounce && !oldWidget.shouldBounce) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
