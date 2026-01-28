/// 首页 - 地图主页
/// 漫画风格旅游App主界面

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../../core/theme/comic_theme.dart';
import '../../../domain/repositories/map_repository.dart';
import '../../widgets/comic_style/comic_container.dart';
import '../../widgets/comic_style/speech_bubble.dart';
import '../../widgets/map/comic_map_marker.dart';

// ==================== 状态管理 (Riverpod) ====================

/// 当前选中城市Provider
final selectedCityProvider = StateProvider<City>((ref) => cities.first);

/// 地图标记点列表Provider
final markersProvider = StateProvider<List<ComicMapMarkerData>>((ref) => []);

/// 选中的标记Provider
final selectedMarkerProvider =
    StateProvider<ComicMapMarkerData?>((ref) => null);

/// AI导游消息Provider
final aiGuideMessagesProvider = StateProvider<List<GuideMessage>>((ref) => []);

/// 地图控制器Provider
final mapControllerProvider = Provider<MapRepository>((ref) {
  // 实际项目中通过依赖注入获取
  throw UnimplementedError();
});

// ==================== 数据模型 ====================

class City {
  final String id;
  final String name;
  final String nameJp;
  final LatLng center;
  final double defaultZoom;
  final String coverImage;

  const City({
    required this.id,
    required this.name,
    required this.nameJp,
    required this.center,
    this.defaultZoom = 13,
    required this.coverImage,
  });
}

class GuideMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const GuideMessage({
    required this.text,
    this.isUser = false,
    required this.timestamp,
  });
}

// 示例城市数据
final cities = [
  const City(
    id: 'tokyo',
    name: '东京',
    nameJp: '東京',
    center: LatLng(35.6762, 139.6503),
    defaultZoom: 13,
    coverImage: 'assets/cities/tokyo_cover.png',
  ),
  const City(
    id: 'kyoto',
    name: '京都',
    nameJp: '京都',
    center: LatLng(35.0116, 135.7681),
    defaultZoom: 14,
    coverImage: 'assets/cities/kyoto_cover.png',
  ),
  const City(
    id: 'osaka',
    name: '大阪',
    nameJp: '大阪',
    center: LatLng(34.6937, 135.5023),
    defaultZoom: 13,
    coverImage: 'assets/cities/osaka_cover.png',
  ),
];

// ==================== 首页主组件 ====================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  gmaps.GoogleMapController? _mapController;
  bool _isMapLoaded = false;

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider);
    final markers = ref.watch(markersProvider);
    final selectedMarker = ref.watch(selectedMarkerProvider);

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
                _buildBottomArea(selectedMarker),
              ],
            ),
          ),

          // ===== 标记信息弹窗 =====
          if (selectedMarker != null)
            Positioned(
              top: 120,
              left: 20,
              right: 20,
              child: _buildMarkerInfoCard(selectedMarker),
            ),
        ],
      ),

      // ===== 底部导航栏 =====
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==================== 地图层 ====================

  Widget _buildMapLayer(City city, List<ComicMapMarkerData> markers) {
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(city.center.latitude, city.center.longitude),
        zoom: city.defaultZoom,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _loadMapStyle(controller);
        setState(() => _isMapLoaded = true);
      },
      markers: _buildGoogleMapMarkers(markers),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onTap: (_) {
        // 点击地图空白处关闭信息窗口
        ref.read(selectedMarkerProvider.notifier).state = null;
      },
    );
  }

  Future<void> _loadMapStyle(gmaps.GoogleMapController controller) async {
    // 加载漫画风格地图样式JSON
    // String styleJson = await rootBundle.loadString('assets/map_styles/comic_map_style.json');
    // await controller.setMapStyle(styleJson);
  }

  Set<gmaps.Marker> _buildGoogleMapMarkers(List<ComicMapMarkerData> markers) {
    return markers.map((data) {
      return gmaps.Marker(
        markerId: gmaps.MarkerId(data.id),
        position: gmaps.LatLng(data.latitude, data.longitude),
        onTap: () {
          ref.read(selectedMarkerProvider.notifier).state = data;
          data.onTap?.call();
        },
        // 使用自定义图标
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          _getCategoryHue(data.category),
        ),
      );
    }).toSet();
  }

  double _getCategoryHue(MarkerCategory category) {
    switch (category) {
      case MarkerCategory.food:
        return gmaps.BitmapDescriptor.hueOrange;
      case MarkerCategory.attraction:
        return gmaps.BitmapDescriptor.hueRed;
      case MarkerCategory.hotel:
        return gmaps.BitmapDescriptor.hueBlue;
      case MarkerCategory.shopping:
        return gmaps.BitmapDescriptor.hueViolet;
      case MarkerCategory.photo:
        return gmaps.BitmapDescriptor.hueGreen;
      case MarkerCategory.transport:
        return gmaps.BitmapDescriptor.hueCyan;
      default:
        return gmaps.BitmapDescriptor.hueRose;
    }
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
                // 显示搜索提示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('搜索功能即将上线！')),
                );
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
        // 显示菜单提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('菜单功能即将上线！')),
        );
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

  Widget _buildBottomArea(ComicMapMarkerData? selectedMarker) {
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
    return const AIGuideBubble(
      message: '欢迎来到东京！我是你的专属导游小漫~ 想吃什么美食？我可以给你推荐附近的拉面店哦！🍜',
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
        _mapController?.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(
            gmaps.LatLng(35.6762, 139.6503), // 东京默认位置
            13,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已定位到当前城市')),
        );
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

  // ==================== 标记信息卡片 ====================

  Widget _buildMarkerInfoCard(ComicMapMarkerData marker) {
    return ComicInfoWindow(
      data: marker,
      onClose: () {
        ref.read(selectedMarkerProvider.notifier).state = null;
      },
      onNavigate: () {
        // 开始导航
        _startNavigation(marker);
      },
      onFavorite: () {
        // 切换收藏状态
        _toggleFavorite(marker);
      },
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
        if (!isSelected) {
          // 显示功能提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label 页面即将上线！')),
          );
        }
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
      builder: (context) => ComicContainer(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('选择城市', style: ComicTextStyles.title),
            const SizedBox(height: 16),
            ...cities.map((city) => _buildCityItem(city)),
          ],
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
        _mapController?.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(
            gmaps.LatLng(city.center.latitude, city.center.longitude),
            city.defaultZoom,
          ),
        );
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
                  Text(city.nameJp,
                      style: ComicTextStyles.body.copyWith(
                        color: ComicColors.textSecondary,
                      )),
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
    // 显示路线规划页面
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('路线规划'),
        content: const Text('路线规划功能即将上线！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFavorites() {
    // 显示收藏页面
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('我的收藏'),
        content: const Text('收藏功能即将上线！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showPhotoSpots() {
    // 显示拍照打卡点页面
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拍照打卡'),
        content: const Text('拍照打卡功能即将上线！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _startNavigation(ComicMapMarkerData marker) {
    // 调用地图导航
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('导航到 ${marker.title}'),
        content: Text('开始导航到 ${marker.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 这里可以集成实际的导航功能
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('正在导航到 ${marker.title}...')),
              );
            },
            child: const Text('开始导航'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(ComicMapMarkerData marker) {
    // 切换收藏状态
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${marker.title} 已添加到收藏')),
    );
  }
}

// ==================== 城市选择器弹窗 ====================

class CityPickerDialog extends StatelessWidget {
  final List<City> cities;
  final City selectedCity;
  final Function(City) onCitySelected;

  const CityPickerDialog({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ComicContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('选择城市', style: ComicTextStyles.title),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child:
                      const Icon(Icons.close, color: ComicColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...cities.map((city) => _buildCityItem(context, city)),
          ],
        ),
      ),
    );
  }

  Widget _buildCityItem(BuildContext context, City city) {
    final isSelected = city.id == selectedCity.id;

    return GestureDetector(
      onTap: () {
        onCitySelected(city);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? ComicColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ComicColors.primary : ComicColors.outline,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected ? ComicShadows.small : null,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ComicColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ComicColors.outline, width: 2),
              ),
              child:
                  const Icon(Icons.location_city, color: ComicColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city.name, style: ComicTextStyles.subtitle),
                  Text(
                    city.nameJp,
                    style: ComicTextStyles.body.copyWith(
                      color: ComicColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: ComicColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
