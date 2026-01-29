// Web 平台的高德地图替代实现
import 'package:flutter/material.dart';
import '../../../core/theme/comic_theme.dart';
import '../../widgets/comic_style/comic_container.dart';

/// Web 平台创建 LatLng（使用 Map 模拟）
Map<String, double> createLatLng(double latitude, double longitude) {
  return {'latitude': latitude, 'longitude': longitude};
}

/// Web 平台构建地图层
Widget buildMapLayer({
  required BuildContext context,
  required dynamic city,
  required Set<dynamic> markers,
  required Function(dynamic) onMapCreated,
  required Function() onTap,
}) {
  return _buildMapPlaceholder(context, city);
}

/// Web 平台移动相机（空实现）
void moveCamera(dynamic controller, dynamic center, double zoom) {
  // Web 平台不实现
}

/// Web 平台地图占位符
Widget _buildMapPlaceholder(BuildContext context, dynamic city) {
  return Container(
    color: const Color(0xFFE8E8E8),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: ComicColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            city.name,
            style: ComicTextStyles.title,
          ),
          const SizedBox(height: 8),
          Text(
            '高德地图在 Web 端需要单独配置',
            style: ComicTextStyles.body.copyWith(
              color: ComicColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请在 Android/iOS 端体验完整地图功能',
            style: ComicTextStyles.body.copyWith(
              color: ComicColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ComicButton(
            text: '模拟定位',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已定位到当前城市')),
              );
            },
          ),
        ],
      ),
    ),
  );
}
