/// 地图服务抽象层 - 高德地图版本
/// 针对国内用户的地图服务接口

import 'package:flutter/material.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart' as amap_base;
import 'package:amap_flutter_map/amap_flutter_map.dart';

// ==================== 实体定义 ====================

/// 地点搜索结果
@immutable
class AMapPlaceResult {
  final String id;
  final String name;
  final String? address;
  final amap_base.LatLng position;
  final String? photoUrl;
  final double? rating;
  final List<String>? types;

  const AMapPlaceResult({
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
enum AMapNavigationMode {
  walking,      // 步行
  cycling,      // 骑行
  driving,      // 驾车
  transit,      // 公交
}

/// 地图配置
@immutable
class AMapConfig {
  final String apiKeyAndroid;
  final String apiKeyIOS;
  final amap_base.LatLng? initialPosition;
  final double initialZoom;
  final bool showMyLocation;
  final bool showCompass;

  const AMapConfig({
    required this.apiKeyAndroid,
    required this.apiKeyIOS,
    this.initialPosition,
    this.initialZoom = 14.0,
    this.showMyLocation = true,
    this.showCompass = true,
  });
}

// ==================== 高德地图仓库接口 ====================

abstract class AMapRepository {
  // ----- 生命周期 -----
  
  /// 初始化地图服务
  Future<void> initialize(AMapConfig config);
  
  /// 释放资源
  Future<void> dispose();

  // ----- 地图控制 -----
  
  /// 移动相机到指定位置
  Future<void> animateCameraToPosition(amap_base.LatLng position, {double? zoom});
  
  /// 移动相机显示指定区域
  Future<void> animateCameraToBounds(List<amap_base.LatLng> bounds, {double padding = 50.0});
  
  /// 获取当前相机位置
  Future<amap_base.LatLng> getCurrentCameraPosition();

  // ----- 标记点管理 -----
  
  /// 添加单个标记
  Future<Marker> addMarker({
    required amap_base.LatLng position,
    String? title,
    String? snippet,
    BitmapDescriptor? icon,
  });
  
  /// 批量添加标记
  Future<List<Marker>> addMarkers(List<amap_base.LatLng> positions);
  
  /// 移除标记
  Future<void> removeMarker(Marker marker);
  
  /// 清除所有标记
  Future<void> clearAllMarkers();

  // ----- 路线绘制 -----
  
  /// 绘制路线
  Future<Polyline> drawRoute({
    required List<amap_base.LatLng> points,
    Color color = Colors.blue,
    double width = 6.0,
    bool isDashed = false,
  });
  
  /// 绘制多点路线 (自动规划)
  Future<List<Polyline>> drawNavigationRoute({
    required amap_base.LatLng origin,
    required amap_base.LatLng destination,
    List<amap_base.LatLng>? waypoints,
    AMapNavigationMode mode = AMapNavigationMode.driving,
  });
  
  /// 移除路线
  Future<void> removeRoute(Polyline polyline);
  
  /// 清除所有路线
  Future<void> clearAllRoutes();

  // ----- 地点搜索 -----
  
  /// 关键词搜索
  Future<List<AMapPlaceResult>> searchPlaces(String keyword, {amap_base.LatLng? near});
  
  /// 周边搜索
  Future<List<AMapPlaceResult>> searchNearby({
    required amap_base.LatLng center,
    required double radius,
    String? keyword,
  });
  
  /// 地理编码 (地址转坐标)
  Future<amap_base.LatLng?> geocode(String address);
  
  /// 逆地理编码 (坐标转地址)
  Future<String?> reverseGeocode(amap_base.LatLng position);

  // ----- 导航功能 -----
  
  /// 开始导航 (调用高德导航APP)
  Future<void> startNavigation({
    required amap_base.LatLng destination,
    String? destinationName,
    AMapNavigationMode mode = AMapNavigationMode.driving,
  });
}

/// 高德地图仓库实现
class AMapRepositoryImpl implements AMapRepository {
  AMapController? _controller;
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];

  @override
  Future<void> initialize(AMapConfig config) async {
    // 高德地图通过 Widget 初始化，这里可以做一些配置
    debugPrint('🗺️ 高德地图服务已初始化');
  }

  @override
  Future<void> dispose() async {
    _controller = null;
    _markers.clear();
    _polylines.clear();
  }

  @override
  Future<void> animateCameraToPosition(amap_base.LatLng position, {double? zoom}) async {
    if (_controller == null) return;
    
    final cameraUpdate = zoom != null
        ? CameraUpdate.newLatLngZoom(position, zoom)
        : CameraUpdate.newLatLng(position);
    
    _controller!.moveCamera(cameraUpdate);
  }

  @override
  Future<void> animateCameraToBounds(List<amap_base.LatLng> bounds, {double padding = 50.0}) async {
    if (_controller == null || bounds.length < 2) return;
    
    // 计算边界
    double minLat = bounds.first.latitude;
    double maxLat = bounds.first.latitude;
    double minLng = bounds.first.longitude;
    double maxLng = bounds.first.longitude;
    
    for (final point in bounds) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    
    final southwest = amap_base.LatLng(minLat, minLng);
    final northeast = amap_base.LatLng(maxLat, maxLng);
    
    _controller!.moveCamera(
      CameraUpdate.newLatLngBounds(
        amap_base.LatLngBounds(southwest: southwest, northeast: northeast),
        padding,
      ),
    );
  }

  @override
  Future<amap_base.LatLng> getCurrentCameraPosition() async {
    // 高德地图需要通过回调获取
    return amap_base.LatLng(39.909187, 116.397451);
  }

  @override
  Future<Marker> addMarker({
    required amap_base.LatLng position,
    String? title,
    String? snippet,
    BitmapDescriptor? icon,
  }) async {
    final marker = Marker(
      position: position,
      infoWindow: InfoWindow(title: title ?? '', snippet: snippet ?? ''),
      icon: icon ?? BitmapDescriptor.defaultMarker,
    );
    _markers.add(marker);
    return marker;
  }

  @override
  Future<List<Marker>> addMarkers(List<amap_base.LatLng> positions) async {
    final markers = <Marker>[];
    for (final position in positions) {
      final marker = await addMarker(position: position);
      markers.add(marker);
    }
    return markers;
  }

  @override
  Future<void> removeMarker(Marker marker) async {
    _markers.remove(marker);
  }

  @override
  Future<void> clearAllMarkers() async {
    _markers.clear();
  }

  @override
  Future<Polyline> drawRoute({
    required List<amap_base.LatLng> points,
    Color color = Colors.blue,
    double width = 6.0,
    bool isDashed = false,
  }) async {
    final polyline = Polyline(
      points: points,
      color: color,
      width: width,
      // 高德地图虚线样式需通过 texture 或其他方式设置
    );
    _polylines.add(polyline);
    return polyline;
  }

  @override
  Future<List<Polyline>> drawNavigationRoute({
    required amap_base.LatLng origin,
    required amap_base.LatLng destination,
    List<amap_base.LatLng>? waypoints,
    AMapNavigationMode mode = AMapNavigationMode.driving,
  }) async {
    // 实际项目中调用高德路径规划 API
    // 这里返回简单的直连线
    final points = [origin, destination];
    final polyline = await drawRoute(points: points, color: Colors.orange);
    return [polyline];
  }

  @override
  Future<void> removeRoute(Polyline polyline) async {
    _polylines.remove(polyline);
  }

  @override
  Future<void> clearAllRoutes() async {
    _polylines.clear();
  }

  @override
  Future<List<AMapPlaceResult>> searchPlaces(String keyword, {amap_base.LatLng? near}) async {
    // 调用高德搜索 API
    return [];
  }

  @override
  Future<List<AMapPlaceResult>> searchNearby({
    required amap_base.LatLng center,
    required double radius,
    String? keyword,
  }) async {
    // 调用高德周边搜索 API
    return [];
  }

  @override
  Future<amap_base.LatLng?> geocode(String address) async {
    // 调用高德地理编码 API
    return null;
  }

  @override
  Future<String?> reverseGeocode(amap_base.LatLng position) async {
    // 调用高德逆地理编码 API
    return null;
  }

  @override
  Future<void> startNavigation({
    required amap_base.LatLng destination,
    String? destinationName,
    AMapNavigationMode mode = AMapNavigationMode.driving,
  }) async {
    // 调用高德导航 APP
    // 使用 url_launcher 打开高德导航
  }

  // 设置控制器
  void setController(AMapController controller) {
    _controller = controller;
  }
}
