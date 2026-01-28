/// 地图服务抽象层 - Repository Pattern
/// 支持多地图提供商切换 (Google Maps / 高德地图 / OpenStreetMap)
/// 设计原则：依赖抽象而非具体实现

import 'package:flutter/foundation.dart';

// ==================== 实体定义 ====================

/// 地理坐标实体
@immutable
class LatLng {
  final double latitude;
  final double longitude;
  
  const LatLng(this.latitude, this.longitude);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;
  
  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

/// 地图标记点实体
@immutable
class MapMarker {
  final String id;
  final LatLng position;
  final String? title;
  final String? snippet;
  final MarkerType type;
  final String? iconAsset; // 漫画风格自定义图标
  final double rotation;
  final bool draggable;
  final VoidCallback? onTap;
  final Map<String, dynamic>? extraData; // 扩展数据

  const MapMarker({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
    this.type = MarkerType.default_marker,
    this.iconAsset,
    this.rotation = 0.0,
    this.draggable = false,
    this.onTap,
    this.extraData,
  });
}

/// 标记点类型枚举
enum MarkerType {
  default_marker,
  food,           // 美食
  attraction,     // 景点
  hotel,          // 酒店
  shopping,       // 购物
  transport,      // 交通
  photo,          // 拍照点
  favorite,       // 收藏
}

/// 地图路线实体
@immutable
class MapRoute {
  final String id;
  final List<LatLng> points;
  final RouteStyle style;
  final String? name;
  final Duration? duration;
  final double? distance; // 米
  final List<MapMarker>? waypoints;

  const MapRoute({
    required this.id,
    required this.points,
    this.style = const RouteStyle(),
    this.name,
    this.duration,
    this.distance,
    this.waypoints,
  });
}

/// 路线样式配置 (漫画风格)
@immutable
class RouteStyle {
  final String? color; // 十六进制颜色
  final double width;
  final RoutePattern pattern;
  final bool isHandDrawn; // 手绘效果
  final List<String>? gradientColors; // 渐变色

  const RouteStyle({
    this.color = '#FF6B35',
    this.width = 5.0,
    this.pattern = RoutePattern.solid,
    this.isHandDrawn = true,
    this.gradientColors,
  });
}

/// 路线样式模式
enum RoutePattern {
  solid,      // 实线
  dashed,     // 虚线 (漫画风格)
  dotted,     // 点线
  doubleLine, // 双线 (漫画描边效果)
  zigzag,     // 锯齿线 (动感)
}

/// 地图区域/边界
@immutable
class MapBounds {
  final LatLng southwest;
  final LatLng northeast;

  const MapBounds({
    required this.southwest,
    required this.northeast,
  });

  LatLng get center => LatLng(
    (southwest.latitude + northeast.latitude) / 2,
    (southwest.longitude + northeast.longitude) / 2,
  );
}

/// 地图配置实体
@immutable
class MapConfig {
  final String provider; // 'google', 'amap', 'openstreetmap'
  final String? styleJsonPath; // 漫画风格地图样式配置
  final LatLng? initialPosition;
  final double initialZoom;
  final bool showMyLocation;
  final bool showCompass;
  final bool enableZoomGestures;
  final bool enableRotateGestures;
  final String? language; // 'zh', 'en', 'ja'

  const MapConfig({
    this.provider = 'google',
    this.styleJsonPath,
    this.initialPosition,
    this.initialZoom = 14.0,
    this.showMyLocation = true,
    this.showCompass = true,
    this.enableZoomGestures = true,
    this.enableRotateGestures = true,
    this.language,
  });
}

/// 地点搜索结果
@immutable
class PlaceResult {
  final String id;
  final String name;
  final String? address;
  final LatLng position;
  final String? photoUrl;
  final double? rating;
  final List<String>? types;

  const PlaceResult({
    required this.id,
    required this.name,
    this.address,
    required this.position,
    this.photoUrl,
    this.rating,
    this.types,
  });
}

/// 导航模式
enum TravelNavigationMode {
  walking,      // 步行
  cycling,      // 骑行
  driving,      // 驾车
  transit,      // 公共交通
}

// ==================== 地图仓库接口 ====================

/// 地图服务仓库接口
/// 定义所有地图相关操作的契约
abstract class MapRepository {
  // ----- 生命周期 -----
  
  /// 初始化地图服务
  Future<void> initialize(MapConfig config);
  
  /// 释放资源
  Future<void> dispose();
  
  /// 切换地图提供商
  Future<void> switchProvider(String providerName);

  // ----- 地图控制 -----
  
  /// 移动相机到指定位置
  Future<void> animateCameraToPosition(LatLng position, {double? zoom});
  
  /// 移动相机显示指定区域
  Future<void> animateCameraToBounds(MapBounds bounds, {double padding = 50.0});
  
  /// 获取当前相机位置
  Future<LatLng> getCurrentCameraPosition();
  
  /// 设置地图样式 (JSON配置)
  Future<void> setMapStyle(String styleJson);

  // ----- 标记点管理 -----
  
  /// 添加单个标记
  Future<void> addMarker(MapMarker marker);
  
  /// 批量添加标记
  Future<void> addMarkers(List<MapMarker> markers);
  
  /// 移除标记
  Future<void> removeMarker(String markerId);
  
  /// 移除所有标记
  Future<void> clearAllMarkers();
  
  /// 更新标记位置
  Future<void> updateMarkerPosition(String markerId, LatLng newPosition);
  
  /// 高亮显示标记 (漫画弹跳效果)
  Future<void> highlightMarker(String markerId);

  // ----- 路线绘制 -----
  
  /// 绘制路线
  Future<void> drawRoute(MapRoute route);
  
  /// 绘制多点路线 (自动规划)
  Future<MapRoute> drawMultiStopRoute(
    List<LatLng> waypoints, {
    TravelNavigationMode mode = TravelNavigationMode.walking,
    RouteStyle? style,
  });
  
  /// 移除路线
  Future<void> removeRoute(String routeId);
  
  /// 清除所有路线
  Future<void> clearAllRoutes();
  
  /// 高亮显示路线
  Future<void> highlightRoute(String routeId);

  // ----- 地点搜索 -----
  
  /// 文本搜索地点
  Future<List<PlaceResult>> searchPlaces(String query, {LatLng? near});
  
  /// 附近搜索
  Future<List<PlaceResult>> searchNearby({
    required LatLng position,
    required double radius,
    String? type,
    String? keyword,
  });
  
  /// 获取地点详情
  Future<PlaceResult?> getPlaceDetails(String placeId);
  
  /// 地理编码 (地址转坐标)
  Future<LatLng?> geocode(String address);
  
  /// 逆地理编码 (坐标转地址)
  Future<String?> reverseGeocode(LatLng position);

  // ----- 导航功能 -----
  
  /// 计算路线
  Future<MapRoute?> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    TravelNavigationMode mode = TravelNavigationMode.walking,
  });
  
  /// 开始导航 (调用第三方导航APP)
  Future<void> startNavigation({
    required LatLng destination,
    String? destinationName,
    TravelNavigationMode mode = TravelNavigationMode.walking,
  });

  // ----- 事件流 -----
  
  /// 地图点击事件流
  Stream<LatLng> get onMapTap;
  
  /// 标记点击事件流
  Stream<MapMarker> get onMarkerTap;
  
  /// 相机移动事件流
  Stream<CameraPositionEvent> get onCameraMove;
  
  /// 我的位置更新流
  Stream<LatLng> get onMyLocationUpdate;
}

/// 相机位置事件
@immutable
class CameraPositionEvent {
  final LatLng position;
  final double zoom;
  final double bearing;
  final double tilt;
  final bool isGesture;

  const CameraPositionEvent({
    required this.position,
    required this.zoom,
    required this.bearing,
    required this.tilt,
    this.isGesture = false,
  });
}

// ==================== 地图提供商工厂 ====================

/// 地图提供商类型
enum MapProviderType {
  google,      // Google Maps (国际)
  amap,        // 高德地图 (国内)
  baidu,       // 百度地图 (备选)
  openstreetmap, // OpenStreetMap (开源备选)
}

/// 地图提供商配置
class MapProviderConfig {
  final MapProviderType type;
  final String apiKey;
  final String? apiKeyIOS;
  final Map<String, dynamic>? extraOptions;

  const MapProviderConfig({
    required this.type,
    required this.apiKey,
    this.apiKeyIOS,
    this.extraOptions,
  });
}

/// 地图仓库工厂接口
abstract class MapRepositoryFactory {
  /// 创建地图仓库实例
  MapRepository create(MapProviderConfig config);
  
  /// 根据区域自动选择最佳提供商
  MapProviderType autoSelectProvider(String region);
  
  /// 检查提供商可用性
  Future<bool> isProviderAvailable(MapProviderType type);
}

// ==================== 使用示例 ====================

/*
/// 使用示例代码:

// 1. 初始化
final mapRepo = MapRepositoryFactory.instance.create(
  MapProviderConfig(
    type: MapProviderType.google,
    apiKey: 'YOUR_API_KEY',
  ),
);

await mapRepo.initialize(MapConfig(
  provider: 'google',
  styleJsonPath: 'assets/map_styles/comic_map_style.json',
  initialPosition: LatLng(35.6762, 139.6503), // 东京
  initialZoom: 14.0,
));

// 2. 添加漫画风格标记
await mapRepo.addMarker(MapMarker(
  id: 'tokyo_tower',
  position: LatLng(35.6586, 139.7454),
  title: '东京塔',
  snippet: '东京地标建筑',
  type: MarkerType.attraction,
  iconAsset: 'assets/icons/marker_attraction.png',
));

// 3. 绘制漫画风格路线
await mapRepo.drawRoute(MapRoute(
  id: 'route_1',
  points: [LatLng(35.6586, 139.7454), LatLng(35.7100, 139.8107)],
  style: RouteStyle(
    color: '#FF6B35',
    width: 6.0,
    pattern: RoutePattern.dashed,
    isHandDrawn: true,
  ),
));

// 4. 监听事件
mapRepo.onMarkerTap.listen((marker) {
  print('点击了标记: ${marker.title}');
  // 显示漫画气泡对话框
});

// 5. 自动切换提供商 (根据用户位置)
if (userRegion == 'CN') {
  await mapRepo.switchProvider('amap');
}
*/
