/// 首页 - 地图主页 (高德地图版本)
/// 使用高德地图 Flutter 插件

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart' as amap;
import 'package:amap_flutter_base/amap_flutter_base.dart' as base;

import '../../../core/theme/comic_theme.dart';
import '../../widgets/comic_style/comic_container.dart';
import '../../widgets/comic_style/speech_bubble.dart' as speech;

// ==================== 状态管理 (Riverpod) ====================

/// 当前选中城市Provider
final selectedCityProvider = StateProvider<City>((ref) => cities.first);

/// 地图标记点列表Provider
final markersProvider = StateProvider<Set<amap.Marker>>((ref) => {});

/// 选中的标记Provider
final selectedMarkerProvider = StateProvider<amap.Marker?>((ref) => null);

/// 地图控制器Provider
final amapControllerProvider =
    StateProvider<amap.AMapController?>((ref) => null);

// ==================== 数据模型 ====================

class City {
  final String id;
  final String name;
  final String nameEn;
  final base.LatLng center;
  final double defaultZoom;

  const City({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.center,
    this.defaultZoom = 13,
  });
}

// 示例城市数据 - 中国主要城市
final cities = [
  const City(
    id: 'beijing',
    name: '北京',
    nameEn: 'Beijing',
    center: base.LatLng(39.909187, 116.397451),
    defaultZoom: 13,
  ),
  const City(
    id: 'shanghai',
    name: '上海',
    nameEn: 'Shanghai',
    center: base.LatLng(31.230416, 121.473701),
    defaultZoom: 13,
  ),
  const City(
    id: 'guangzhou',
    name: '广州',
    nameEn: 'Guangzhou',
    center: base.LatLng(23.129163, 113.264435),
    defaultZoom: 13,
  ),
  const City(
    id: 'shenzhen',
    name: '深圳',
    nameEn: 'Shenzhen',
    center: base.LatLng(22.543099, 114.057868),
    defaultZoom: 13,
  ),
  const City(
    id: 'chengdu',
    name: '成都',
    nameEn: 'Chengdu',
    center: base.LatLng(30.572815, 104.066801),
    defaultZoom: 13,
  ),
  const City(
    id: 'hangzhou',
    name: '杭州',
    nameEn: 'Hangzhou',
    center: base.LatLng(30.274085, 120.155070),
    defaultZoom: 13,
  ),
];

// ==================== 首页主组件 ====================

class HomeScreenAMap extends ConsumerStatefulWidget {
  const HomeScreenAMap({super.key});

  @override
  ConsumerState<HomeScreenAMap> createState() => _HomeScreenAMapState();
}

class _HomeScreenAMapState extends ConsumerState<HomeScreenAMap> {
  bool _isMapLoaded = false;

  // 高德地图 API Key - 请替换为您的实际 Key
  static const String _amapAndroidKey = 'YOUR_AMAP_ANDROID_KEY';
  static const String _amapIOSKey = 'YOUR_AMAP_IOS_KEY';

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider);
    final markers = ref.watch(markersProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ===== 地图层 =====
          _buildMapLayer(selectedCity, markers),

          // ===== UI覆盖层 =====
          SafeArea(
            child: Column(
              children: [
                // 顶部栏：城市切换 + 搜索
                _buildTopBar(selectedCity),

                const Spacer(),

                // 底部区域：AI导游 + 功能按钮
                _buildBottomArea(),
              ],
            ),
          ),
        ],
      ),

      // ===== 底部导航栏 =====
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==================== 地图层 ====================

  Widget _buildMapLayer(City city, Set<amap.Marker> markers) {
    // Web 平台暂时显示占位符（高德地图 Web 支持需要额外配置）
    if (kIsWeb) {
      return _buildMapPlaceholder(city);
    }

    // Android 和 iOS 使用高德地图
    return amap.AMapWidget(
      apiKey: const base.AMapApiKey(
        androidKey: _amapAndroidKey,
        iosKey: _amapIOSKey,
      ),
      privacyStatement: const base.AMapPrivacyStatement(
        hasContains: true,
        hasShow: true,
        hasAgree: true,
      ),
      initialCameraPosition: amap.CameraPosition(
        target: city.center,
        zoom: city.defaultZoom,
      ),
      markers: markers,
      myLocationStyleOptions: amap.MyLocationStyleOptions(
        true,
        circleFillColor: ComicColors.primary.withOpacity(0.2),
        circleStrokeColor: ComicColors.primary,
        circleStrokeWidth: 2,
      ),
      compassEnabled: true,
      mapType: amap.MapType.normal,
      trafficEnabled: false,
      buildingsEnabled: true,
      onMapCreated: (controller) {
        ref.read(amapControllerProvider.notifier).state = controller;
        setState(() => _isMapLoaded = true);
      },
      onTap: (latLng) {
        // 点击地图空白处关闭信息窗口
        ref.read(selectedMarkerProvider.notifier).state = null;
      },
    );
  }

  /// Web 平台地图占位符
  Widget _buildMapPlaceholder(City city) {
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
              '高德地图 Web 端需要额外配置',
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

  // ==================== 顶部栏 ====================

  Widget _buildTopBar(City city) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 城市选择器 (漫画风格下拉)
          _buildCitySelector(city),

          const SizedBox(width: 12),

          // 搜索框
          Expanded(
            child: ComicTextField(
              hintText: '搜索景点、美食...',
              prefixIcon:
                  const Icon(Icons.search, color: ComicColors.textSecondary),
              onTap: () {
                // 打开搜索页面
              },
            ),
          ),

          const SizedBox(width: 12),

          // 菜单按钮
          _buildMenuButton(),
        ],
      ),
    );
  }

  Widget _buildCitySelector(City city) {
    return GestureDetector(
      onTap: () => _showCityPicker(context),
      child: ComicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: ComicColors.primary,
        borderRadius: 20,
        shadows: ComicShadows.small,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              city.name,
              style: ComicTextStyles.button.copyWith(fontSize: 14),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: () {
        // 打开侧边栏菜单
      },
      child: ComicContainer(
        padding: const EdgeInsets.all(10),
        backgroundColor: Colors.white,
        borderRadius: 12,
        shadows: ComicShadows.small,
        child: const Icon(Icons.menu, color: ComicColors.outline),
      ),
    );
  }

  // ==================== 底部区域 ====================

  Widget _buildBottomArea() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI导游气泡
          _buildAIGuideBubble(),

          const SizedBox(height: 16),

          // 功能按钮行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureButton(
                icon: Icons.route,
                label: '路线规划',
                color: ComicColors.secondary,
                onTap: () => _showRoutePlanning(),
              ),
              _buildFeatureButton(
                icon: Icons.favorite,
                label: '我的收藏',
                color: ComicColors.highlight,
                onTap: () => _showFavorites(),
              ),
              _buildFeatureButton(
                icon: Icons.camera_alt,
                label: '拍照打卡',
                color: ComicColors.accent,
                onTap: () => _showPhotoSpots(),
              ),
              _buildLocationButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIGuideBubble() {
    return const speech.AIGuideBubble(
      message: '欢迎来到北京！我是你的专属导游小漫~ 想去故宫还是长城？我可以给你规划最佳路线哦！🏯',
      guideName: '小漫导游',
      // avatarAsset: 'assets/characters/guide_avatar.png',
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ComicContainer(
            width: 56,
            height: 56,
            padding: EdgeInsets.zero,
            backgroundColor: color,
            borderRadius: 16,
            shadows: ComicShadows.small,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: ComicTextStyles.body.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: () {
        // 定位到当前位置
        final controller = ref.read(amapControllerProvider);
        if (controller != null) {
          controller.moveCamera(
            amap.CameraUpdate.zoomTo(16),
          );
        }
      },
      child: ComicContainer(
        width: 56,
        height: 56,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        borderRadius: 28,
        shadows: ComicShadows.standard,
        child: const Icon(
          Icons.my_location,
          color: ComicColors.primary,
          size: 28,
        ),
      ),
    );
  }

  // ==================== 底部导航栏 ====================

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: ComicColors.outline, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: ComicColors.outline.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.map, '地图', true),
              _buildNavItem(Icons.explore, '发现', false),
              _buildNavItem(Icons.chat_bubble, 'AI导游', false),
              _buildNavItem(Icons.person, '我的', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    final color = isSelected ? ComicColors.primary : ComicColors.textSecondary;

    return GestureDetector(
      onTap: () {
        // 切换页面
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: ComicTextStyles.body.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 交互方法 ====================

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ComicContainer(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('选择城市', style: ComicTextStyles.title),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cities.length,
                  itemBuilder: (context, index) =>
                      _buildCityItem(cities[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityItem(City city) {
    final isSelected = ref.watch(selectedCityProvider).id == city.id;

    return GestureDetector(
      onTap: () {
        ref.read(selectedCityProvider.notifier).state = city;
        // 移动地图到选中城市
        final controller = ref.read(amapControllerProvider);
        if (controller != null) {
          controller.moveCamera(
            amap.CameraUpdate.newLatLngZoom(city.center, city.defaultZoom),
          );
        }
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? ComicColors.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ComicColors.primary
                : ComicColors.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: ComicColors.primary.withOpacity(0.2),
                child:
                    const Icon(Icons.location_city, color: ComicColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city.name, style: ComicTextStyles.subtitle),
                  Text(
                    city.nameEn,
                    style: ComicTextStyles.body.copyWith(
                      color: ComicColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: ComicColors.primary),
          ],
        ),
      ),
    );
  }

  void _showRoutePlanning() {
    // 打开路线规划页面
  }

  void _showFavorites() {
    // 打开收藏页面
  }

  void _showPhotoSpots() {
    // 打开拍照打卡点页面
  }
}
