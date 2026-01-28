/// 漫画风格气泡对话框组件
/// 支持多种漫画气泡样式：对话、思考、喊叫、旁白等

import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/comic_theme.dart';

/// 气泡类型枚举
enum BubbleType {
  speech,      // 普通对话
  thought,     // 思考
  shout,       // 喊叫/强调 (锯齿边框)
  whisper,     // 小声 (虚线边框)
  narration,   // 旁白 (方框)
  action,      // 动作效果
}

/// 气泡指向方向
enum BubbleDirection {
  left,
  right,
  top,
  bottom,
  leftTop,
  leftBottom,
  rightTop,
  rightBottom,
  none, // 无指向 (思考气泡)
}

/// 漫画气泡对话框
class SpeechBubble extends StatelessWidget {
  final String text;
  final BubbleType type;
  final BubbleDirection direction;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final double maxWidth;
  final EdgeInsets padding;
  final Widget? avatar; // 角色头像
  final String? characterName; // 角色名
  final VoidCallback? onTap;
  final bool isTyping; // 打字机效果

  const SpeechBubble({
    super.key,
    required this.text,
    this.type = BubbleType.speech,
    this.direction = BubbleDirection.leftBottom,
    this.backgroundColor,
    this.borderColor,
    this.textStyle,
    this.maxWidth = 280,
    this.padding = const EdgeInsets.all(16),
    this.avatar,
    this.characterName,
    this.onTap,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget bubble = CustomPaint(
      painter: _BubblePainter(
        type: type,
        direction: direction,
        backgroundColor: backgroundColor ?? Colors.white,
        borderColor: borderColor ?? ComicColors.outline,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: _getPaddingForDirection(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (characterName != null) ...[
              Text(
                characterName!,
                style: ComicTextStyles.badge.copyWith(
                  color: ComicColors.primary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
            ],
            _buildText(),
          ],
        ),
      ),
    );

    // 添加头像布局
    if (avatar != null) {
      bubble = _buildWithAvatar(bubble);
    }

    if (onTap != null) {
      bubble = GestureDetector(onTap: onTap, child: bubble);
    }

    return bubble;
  }

  Widget _buildText() {
    if (isTyping) {
      return _TypingText(
        text: text,
        style: textStyle ?? ComicTextStyles.speech,
      );
    }
    return Text(
      text,
      style: textStyle ?? ComicTextStyles.speech,
    );
  }

  Widget _buildWithAvatar(Widget bubble) {
    final isAvatarLeft = direction == BubbleDirection.left || 
                         direction == BubbleDirection.leftTop || 
                         direction == BubbleDirection.leftBottom;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isAvatarLeft) ...[
          _buildAvatar(),
          const SizedBox(width: 8),
        ],
        Flexible(child: bubble),
        if (!isAvatarLeft) ...[
          const SizedBox(width: 8),
          _buildAvatar(),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ComicColors.outline, width: 3),
        boxShadow: ComicShadows.small,
      ),
      child: ClipOval(child: avatar),
    );
  }

  EdgeInsets _getPaddingForDirection() {
    final basePadding = padding;
    switch (direction) {
      case BubbleDirection.left:
        return basePadding.copyWith(left: basePadding.left + 16);
      case BubbleDirection.right:
        return basePadding.copyWith(right: basePadding.right + 16);
      case BubbleDirection.top:
        return basePadding.copyWith(top: basePadding.top + 12);
      case BubbleDirection.bottom:
        return basePadding.copyWith(bottom: basePadding.bottom + 12);
      case BubbleDirection.leftTop:
      case BubbleDirection.leftBottom:
        return basePadding.copyWith(left: basePadding.left + 16);
      case BubbleDirection.rightTop:
      case BubbleDirection.rightBottom:
        return basePadding.copyWith(right: basePadding.right + 16);
      case BubbleDirection.none:
        return basePadding;
    }
  }
}

/// 气泡绘制器
class _BubblePainter extends CustomPainter {
  final BubbleType type;
  final BubbleDirection direction;
  final Color backgroundColor;
  final Color borderColor;

  _BubblePainter({
    required this.type,
    required this.direction,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _createBubblePath(size);

    // 绘制阴影
    canvas.save();
    canvas.translate(3, 3);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // 绘制填充
    canvas.drawPath(path, paint);

    // 绘制边框
    if (type == BubbleType.whisper) {
      _drawDashedBorder(canvas, path, borderPaint);
    } else {
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  Path _createBubblePath(Size size) {
    switch (type) {
      case BubbleType.speech:
        return _createSpeechBubblePath(size);
      case BubbleType.thought:
        return _createThoughtBubblePath(size);
      case BubbleType.shout:
        return _createShoutBubblePath(size);
      case BubbleType.whisper:
        return _createSpeechBubblePath(size);
      case BubbleType.narration:
        return _createNarrationPath(size);
      case BubbleType.action:
        return _createActionPath(size);
    }
  }

  Path _createSpeechBubblePath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    const radius = 16.0;

    // 主体圆角矩形
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(radius),
    ));

    // 添加指向尾巴
    if (direction != BubbleDirection.none) {
      path.addPath(_createTail(w, h), Offset.zero);
    }

    return path;
  }

  Path _createTail(double w, double h) {
    final path = Path();
    const tailWidth = 16.0;
    const tailHeight = 20.0;

    switch (direction) {
      case BubbleDirection.left:
      case BubbleDirection.leftBottom:
        path.moveTo(0, h * 0.7);
        path.lineTo(-tailHeight, h * 0.7 + tailWidth / 2);
        path.lineTo(0, h * 0.7 + tailWidth);
        break;
      case BubbleDirection.right:
      case BubbleDirection.rightBottom:
        path.moveTo(w, h * 0.7);
        path.lineTo(w + tailHeight, h * 0.7 + tailWidth / 2);
        path.lineTo(w, h * 0.7 + tailWidth);
        break;
      case BubbleDirection.bottom:
        path.moveTo(w * 0.5 - tailWidth / 2, h);
        path.lineTo(w * 0.5, h + tailHeight);
        path.lineTo(w * 0.5 + tailWidth / 2, h);
        break;
      case BubbleDirection.top:
        path.moveTo(w * 0.5 - tailWidth / 2, 0);
        path.lineTo(w * 0.5, -tailHeight);
        path.lineTo(w * 0.5 + tailWidth / 2, 0);
        break;
      default:
        break;
    }
    path.close();
    return path;
  }

  Path _createThoughtBubblePath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // 主气泡
    path.addOval(Rect.fromLTWH(10, 10, w - 20, h - 40));

    // 思考小圆圈
    path.addOval(Rect.fromLTWH(w * 0.3, h - 25, 12, 12));
    path.addOval(Rect.fromLTWH(w * 0.2, h - 12, 8, 8));
    path.addOval(Rect.fromLTWH(w * 0.1, h - 5, 5, 5));

    return path;
  }

  Path _createShoutBubblePath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    const spikes = 12;

    // 创建锯齿边框
    for (int i = 0; i < spikes; i++) {
      final angle = (i / spikes) * 2 * 3.14159;
      final nextAngle = ((i + 1) / spikes) * 2 * 3.14159;
      
      final innerR = 10.0;
      final outerR = (i % 2 == 0) ? 0.0 : 8.0;

      final x1 = w / 2 + (w / 2 - innerR) * cos(angle);
      final y1 = h / 2 + (h / 2 - innerR) * sin(angle);
      final x2 = w / 2 + (w / 2 - innerR + outerR) * cos(nextAngle);
      final y2 = h / 2 + (h / 2 - innerR + outerR) * sin(nextAngle);

      if (i == 0) {
        path.moveTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();

    return path;
  }

  Path _createNarrationPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // 简单矩形带内边框
    path.addRect(Rect.fromLTWH(0, 0, w, h));
    
    return path;
  }

  Path _createActionPath(Size size) {
    // 倾斜的矩形，表示动作
    final path = Path();
    final w = size.width;
    final h = size.height;
    const skew = 10.0;

    path.moveTo(skew, 0);
    path.lineTo(w, 0);
    path.lineTo(w - skew, h);
    path.lineTo(0, h);
    path.close();

    return path;
  }

  void _drawDashedBorder(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance);
        final end = metric.getTangentForOffset(distance + dashWidth);
        if (start != null && end != null) {
          canvas.drawLine(start.position, end.position, paint);
        }
        distance += dashWidth + dashSpace;
      }
    }
  }
}

/// 打字机效果文字
class _TypingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;

  const _TypingText({
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 50),
  });

  @override
  State<_TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<_TypingText> {
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    Future.doWhile(() async {
      if (_currentIndex >= widget.text.length) return false;
      
      await Future.delayed(widget.speed);
      if (mounted) {
        setState(() {
          _displayedText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      }
      return _currentIndex < widget.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}

/// AI 导游对话框组件
class AIGuideBubble extends StatelessWidget {
  final String message;
  final String? guideName;
  final String? avatarAsset;
  final bool isTyping;
  final VoidCallback? onActionTap;
  final String? actionText;

  const AIGuideBubble({
    super.key,
    required this.message,
    this.guideName = '小漫导游',
    this.avatarAsset,
    this.isTyping = false,
    this.onActionTap,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return SpeechBubble(
      text: message,
      type: BubbleType.speech,
      direction: BubbleDirection.leftBottom,
      backgroundColor: ComicColors.accent.withOpacity(0.3),
      borderColor: ComicColors.accent,
      characterName: guideName,
      avatar: avatarAsset != null
          ? Image.asset(avatarAsset!, fit: BoxFit.cover)
          : _buildDefaultAvatar(),
      isTyping: isTyping,
      padding: const EdgeInsets.all(12),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: ComicColors.primary,
      child: const Icon(Icons.smart_toy, color: Colors.white),
    );
  }
}

/// 用户消息气泡
class UserBubble extends StatelessWidget {
  final String message;

  const UserBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SpeechBubble(
        text: message,
        type: BubbleType.speech,
        direction: BubbleDirection.rightBottom,
        backgroundColor: ComicColors.primary.withOpacity(0.9),
        textStyle: ComicTextStyles.speech.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// 漫画风格提示框
class ComicTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const ComicTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: ComicColors.outline,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: ComicTextStyles.badge,
      child: child,
    );
  }
}
