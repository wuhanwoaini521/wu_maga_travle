/// 漫画风格主题配置
/// 定义全局颜色、字体、描边样式等

import 'package:flutter/material.dart';

/// 漫画主题颜色
class ComicColors {
  // 主色调 - 活力橙 (漫画常见强调色)
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8C61);
  static const Color primaryDark = Color(0xFFE85D2E);
  
  // 辅助色
  static const Color secondary = Color(0xFF4ECDC4); // 青色
  static const Color accent = Color(0xFFFFD93D);    // 明黄
  static const Color highlight = Color(0xFFFF6B9D); // 粉红
  
  // 漫画经典色
  static const Color speedLine = Color(0xFF2D2D2D); // 速度线深色
  static const Color halftone = Color(0xFF666666);  // 网点灰
  static const Color burst = Color(0xFFFF0000);     // 爆发红
  static const Color shock = Color(0xFF00FFFF);     // 震惊青
  
  // 背景色
  static const Color background = Color(0xFFFEF9E7); // 米白漫画纸
  static const Color backgroundDark = Color(0xFF2D2D2D);
  static const Color panelBg = Colors.white;
  
  // 描边色
  static const Color outline = Color(0xFF1A1A1A);
  static const Color outlineLight = Color(0xFF333333);
  
  // 文字色
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textInverse = Colors.white;
  
  // 功能色
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFF5222D);
  static const Color info = Color(0xFF1890FF);
}

/// 漫画描边样式
class ComicBorders {
  // 标准粗描边
  static BorderSide get thick => const BorderSide(
    color: ComicColors.outline,
    width: 3.0,
  );
  
  // 中等描边
  static BorderSide get medium => const BorderSide(
    color: ComicColors.outline,
    width: 2.0,
  );
  
  // 细描边
  static BorderSide get thin => const BorderSide(
    color: ComicColors.outline,
    width: 1.5,
  );
  
  // 圆角边框 - 标准
  static RoundedRectangleBorder get roundedRect => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: thick,
  );
  
  // 圆角边框 - 小
  static RoundedRectangleBorder get roundedRectSmall => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    side: medium,
  );
  
  // 圆角边框 - 大 (对话框)
  static RoundedRectangleBorder get roundedRectLarge => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: thick,
  );
  
  // 漫画风格不规则边框 (通过 CustomPainter 实现)
  static ShapeBorder get irregular => const _IrregularBorder();
}

/// 不规则边框 (手绘感)
class _IrregularBorder extends ShapeBorder {
  const _IrregularBorder();
  
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => 
      getOuterPath(rect, textDirection: textDirection);
  
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // 创建略微不规则的路径模拟手绘效果
    final path = Path();
    final r = rect;
    
    path.moveTo(r.left + 5, r.top);
    path.lineTo(r.right - 5, r.top + 2);
    path.lineTo(r.right, r.top + 10);
    path.lineTo(r.right - 2, r.bottom - 5);
    path.lineTo(r.right - 8, r.bottom);
    path.lineTo(r.left + 5, r.bottom - 2);
    path.lineTo(r.left, r.bottom - 10);
    path.lineTo(r.left + 2, r.top + 5);
    path.close();
    
    return path;
  }
  
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = ComicColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(getOuterPath(rect), paint);
  }
  
  @override
  ShapeBorder scale(double t) => this;
}

/// 漫画阴影样式
class ComicShadows {
  // 标准漫画阴影 (偏移明显)
  static List<BoxShadow> get standard => const [
    BoxShadow(
      color: ComicColors.outline,
      offset: Offset(4, 4),
      blurRadius: 0,
    ),
  ];
  
  // 小阴影
  static List<BoxShadow> get small => const [
    BoxShadow(
      color: ComicColors.outline,
      offset: Offset(2, 2),
      blurRadius: 0,
    ),
  ];
  
  // 大阴影 (突出效果)
  static List<BoxShadow> get large => const [
    BoxShadow(
      color: ComicColors.outline,
      offset: Offset(6, 6),
      blurRadius: 0,
    ),
  ];
  
  // 彩色阴影
  static List<BoxShadow> colored(Color color) => [
    BoxShadow(
      color: color,
      offset: const Offset(4, 4),
      blurRadius: 0,
    ),
  ];
  
  // 多层阴影 (立体感)
  static List<BoxShadow> get multiLayer => const [
    BoxShadow(
      color: ComicColors.outline,
      offset: Offset(2, 2),
      blurRadius: 0,
    ),
    BoxShadow(
      color: ComicColors.outline,
      offset: Offset(4, 4),
      blurRadius: 0,
    ),
  ];
}

/// 漫画文字样式
class ComicTextStyles {
  // 大标题 - 漫画冲击效果
  static TextStyle get headline => const TextStyle(
    fontFamily: 'MangaBold',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: ComicColors.textPrimary,
    letterSpacing: 1.5,
    shadows: [
      Shadow(
        color: ComicColors.outline,
        offset: Offset(2, 2),
        blurRadius: 0,
      ),
    ],
  );
  
  // 标题
  static TextStyle get title => const TextStyle(
    fontFamily: 'MangaBold',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ComicColors.textPrimary,
  );
  
  // 副标题
  static TextStyle get subtitle => const TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ComicColors.textPrimary,
  );
  
  // 正文
  static TextStyle get body => const TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 16,
    color: ComicColors.textPrimary,
    height: 1.5,
  );
  
  // 对话框文字 (手写风格)
  static TextStyle get speech => const TextStyle(
    fontFamily: 'Handwritten',
    fontSize: 16,
    color: ComicColors.textPrimary,
    height: 1.4,
  );
  
  // 标签/徽章
  static TextStyle get badge => const TextStyle(
    fontFamily: 'MangaBold',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  // 按钮文字
  static TextStyle get button => const TextStyle(
    fontFamily: 'MangaBold',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.0,
  );
}

/// 漫画主题数据
class ComicTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: ComicColors.primary,
    scaffoldBackgroundColor: ComicColors.background,
    colorScheme: const ColorScheme.light(
      primary: ComicColors.primary,
      secondary: ComicColors.secondary,
      surface: ComicColors.panelBg,
      error: ComicColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ComicColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ComicColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: ComicTextStyles.title.copyWith(color: Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: ComicColors.panelBg,
      elevation: 0,
      shape: ComicBorders.roundedRect,
      margin: const EdgeInsets.all(8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ComicColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: ComicTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ComicColors.outline, width: 2),
        ),
        shadowColor: ComicColors.outline,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ComicColors.textPrimary,
        side: ComicBorders.thick,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: ComicTextStyles.button.copyWith(color: ComicColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: ComicBorders.thick,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: ComicBorders.medium,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ComicColors.primary, width: 3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ComicColors.background,
      selectedColor: ComicColors.primary,
      labelStyle: ComicTextStyles.body,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: ComicBorders.medium,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ComicColors.accent,
      foregroundColor: ComicColors.outline,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: ComicColors.primary,
      unselectedItemColor: ComicColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
  
  static ThemeData get darkTheme => lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ComicColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: ComicColors.primary,
      secondary: ComicColors.secondary,
      surface: Color(0xFF3D3D3D),
      background: ComicColors.backgroundDark,
    ),
  );
}

/// 漫画装饰预设
class ComicDecorations {
  // 标准漫画卡片
  static BoxDecoration get card => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: ComicColors.outline, width: 3),
    boxShadow: ComicShadows.standard,
  );
  
  // 对话框
  static BoxDecoration get speechBubble => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: ComicColors.outline, width: 3),
    boxShadow: ComicShadows.small,
  );
  
  // 强调卡片
  static BoxDecoration get accentCard => BoxDecoration(
    color: ComicColors.accent,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: ComicColors.outline, width: 3),
    boxShadow: ComicShadows.standard,
  );
  
  // 渐变背景
  static BoxDecoration gradientCard(List<Color> colors) => BoxDecoration(
    gradient: LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: ComicColors.outline, width: 3),
    boxShadow: ComicShadows.standard,
  );
  
  // 网点背景 (漫画风格)
  static BoxDecoration get halftone => BoxDecoration(
    color: ComicColors.background,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: ComicColors.outline, width: 3),
    image: const DecorationImage(
      image: AssetImage('assets/images/halftone_pattern.png'),
      repeat: ImageRepeat.repeat,
      opacity: 0.1,
    ),
  );
}
