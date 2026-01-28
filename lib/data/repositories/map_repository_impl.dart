/// 地图仓库实现类
/// 实现 MapRepository 接口，封装 Google Maps 和 高德地图 的具体实现

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';

import '../../domain/repositories/map_repository.dart';

/// 地图仓库实现
class MapRepositoryImpl implements MapRepository {
  // 当前使用的地图提供商
  MapProviderType _currentProvider = MapProviderType.google;
  
  // Google Maps 控制器
  gmaps.GoogleMapController? _googleMapController;
  
  // 标记点缓存
  final Map<String, gmaps.Marker> _markers = {};
  final Map<String, MapMarker> _markerData = {};
  
  // 路线缓存
  final Map<String, gmaps.Polyline> _polylines = {};
  
  // 事件控制器
  final _onMapTapController = StreamController<LatLng>.broadcast();
  final _onMarkerTapController = StreamController<MapMarker>.broadcast();
  final _onCameraMoveController = StreamController<CameraPositionEvent>.broadcast();
  final _onMyLocationUpdateController = StreamController<LatLng>.broadcast();
  
  // 配置
  MapConfig? _config;
  
  // 位置监听
  StreamSubscription<Position>? _positionSubscription;

  // ==================== 生命周期 ====================
  
  @override
  Future<void> initialize(MapConfig config) async {
    _config = config;
    
    // 请求位置权限
    await _requestLocationPermission();
    
    // 开始监听位置更新
    _startLocationTracking();
    
    debugPrint('🗺️ 地图服务已初始化: ${config.provider}');
  }
  
  @override
  Future<void> dispose() async {
    _googleMapController?.dispose();
    await _positionSubscription?.cancel();
    await _onMapTapController.close();
    await _onMarkerTapController.close();
    await _onCameraMoveController.close();
    await _onMyLocationUpdateController.close();
  }
  
  @override
  Future<void> switchProvider(String providerName) async {
    // 保存当前状态
    final currentMarkers = List<MapMarker>.from(_markerData.values);
    
    // 清理当前地图
    _googleMapController?.dispose();
    _googleMapController = null;
    _markers.clear();
    _polylines.clear();
    
    // 切换提供商
    _currentProvider = MapProviderType.values.firstWhere(
      (e) => e.name == providerName,
      orElse: () => MapProviderType.google,
    );
    
    // 重新初始化
    debugPrint('🔄 已切换到地图提供商: $providerName');
    
    // 恢复标记点
    await addMarkers(currentMarkers);
  }

  // ==================== 地图控制 ====================
  
  @override
  Future<void> animateCameraToPosition(LatLng position, {double? zoom}) async {
    if (_googleMapController == null) return;
    
    await _googleMapController!.animateCamera(
      gmaps.CameraUpdate.newLatLngZoom(
        gmaps.LatLng(position.latitude, position.longitude),
        zoom ?? _config?.initialZoom ?? 14.0,
      ),
    );
  }
  
  @override
  Future<void> animateCameraToBounds(MapBounds bounds, {double padding = 50.0}) async {
    if (_googleMapController == null) return;
    
    await _googleMapController!.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(
        gmaps.LatLngBounds(
          southwest: gmaps.LatLng(bounds.southwest.latitude, bounds.southwest.longitude),
          northeast: gmaps.LatLng(bounds.northeast.latitude, bounds.northeast.longitude),
        ),
        padding,
      ),
    );
  }
  
  @override
  Future<LatLng> getCurrentCameraPosition() async {
    if (_googleMapController == null) {
      return _config?.initialPosition ?? const LatLng(35.6762, 139.6503);
    }
    
    final position = await _googleMapController!.getVisibleRegion();
    return LatLng(
      (position.southwest.latitude + position.northeast.latitude) / 2,
      (position.southwest.longitude + position.northeast.longitude) / 2,
    );
  }
  
  @override
  Future<void> setMapStyle(String styleJson) async {
    if (_googleMapController == null) return;
    await _googleMapController!.setMapStyle(styleJson);
  }

  // ==================== 标记点管理 ====================
  
  @override
  Future<void> addMarker(MapMarker marker) async {
    // 加载自定义图标
    gmaps.BitmapDescriptor? icon;
    if (marker.iconAsset != null) {
      icon = await gmaps.BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        marker.iconAsset!,
      );
    } else {
      icon = await _getDefaultMarkerIcon(marker.type);
    }
    
    final gmapsMarker = gmaps.Marker(
      markerId: gmaps.MarkerId(marker.id),
      position: gmaps.LatLng(marker.position.latitude, marker.position.longitude),
      icon: icon,
      rotation: marker.rotation,
      draggable: marker.draggable,
      infoWindow: gmaps.InfoWindow(
        title: marker.title,
        snippet: marker.snippet,
      ),
      onTap: () {
        _onMarkerTapController.add(marker);
        marker.onTap?.call();
      },
    );
    
    _markers[marker.id] = gmapsMarker;
    _markerData[marker.id] = marker;
    
    await _updateGoogleMapMarkers();
  }
  
  @override
  Future<void> addMarkers(List<MapMarker> markers) async {
    for (final marker in markers) {
      await addMarker(marker);
    }
  }
  
  @override
  Future<void> removeMarker(String markerId) async {
    _markers.remove(markerId);
    _markerData.remove(markerId);
    await _updateGoogleMapMarkers();
  }
  
  @override
  Future<void> clearAllMarkers() async {
    _markers.clear();
    _markerData.clear();
    await _updateGoogleMapMarkers();
  }
  
  @override
  Future<void> updateMarkerPosition(String markerId, LatLng newPosition) async {
    final existingMarker = _markerData[markerId];
    if (existingMarker == null) return;
    
    await removeMarker(markerId);
    await addMarker(MapMarker(
      id: existingMarker.id,
      position: newPosition,
      title: existingMarker.title,
      snippet: existingMarker.snippet,
      type: existingMarker.type,
      iconAsset: existingMarker.iconAsset,
      rotation: existingMarker.rotation,
      draggable: existingMarker.draggable,
      onTap: existingMarker.onTap,
      extraData: existingMarker.extraData,
    ));
  }
  
  @override
  Future<void> highlightMarker(String markerId) async {
    // 实现漫画弹跳动画效果
    final marker = _markerData[markerId];
    if (marker == null) return;
    
    // 模拟弹跳效果 (通过多次更新位置)
    final originalPos = marker.position;
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      // 向上偏移
      await updateMarkerPosition(
        markerId,
        LatLng(originalPos.latitude + 0.0001, originalPos.longitude),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      // 回到原位
      await updateMarkerPosition(markerId, originalPos);
    }
  }

  // ==================== 路线绘制 ====================
  
  @override
  Future<void> drawRoute(MapRoute route) async {
    final pattern = _convertRoutePattern(route.style.pattern);
    
    final polyline = gmaps.Polyline(
      polylineId: gmaps.PolylineId(route.id),
      points: route.points
          .map((p) => gmaps.LatLng(p.latitude, p.longitude))
          .toList(),
      color: _hexToColor(route.style.color ?? '#FF6B35'),
      width: route.style.width.toInt(),
      patterns: pattern,
      geodesic: true,
    );
    
    _polylines[route.id] = polyline;
    await _updateGoogleMapPolylines();
  }
  
  @override
  Future<MapRoute> drawMultiStopRoute(
    List<LatLng> waypoints, {
    TravelNavigationMode mode = TravelNavigationMode.walking,
    RouteStyle? style,
  }) async {
    // 使用 Google Directions API 或高德路径规划 API
    // 这里简化处理，直接连接各点
    
    final route = MapRoute(
      id: 'multi_stop_${DateTime.now().millisecondsSinceEpoch}',
      points: waypoints,
      style: style ?? const RouteStyle(),
      name: '自动规划路线',
    );
    
    await drawRoute(route);
    return route;
  }
  
  @override
  Future<void> removeRoute(String routeId) async {
    _polylines.remove(routeId);
    await _updateGoogleMapPolylines();
  }
  
  @override
  Future<void> clearAllRoutes() async {
    _polylines.clear();
    await _updateGoogleMapPolylines();
  }
  
  @override
  Future<void> highlightRoute(String routeId) async {
    final polyline = _polylines[routeId];
    if (polyline == null) return;
    
    // 实现闪烁高亮效果
    // 通过改变颜色和宽度来实现
  }

  // ==================== 地点搜索 ====================
  
  @override
  Future<List<PlaceResult>> searchPlaces(String query, {LatLng? near}) async {
    // 调用 Google Places API 或高德搜索 API
    // 返回模拟数据
    return [
      PlaceResult(
        id: 'place_1',
        name: '$query - 搜索结果1',
        position: near ?? const LatLng(35.6762, 139.6503),
        address: '东京都港区',
      ),
    ];
  }
  
  @override
  Future<List<PlaceResult>> searchNearby({
    required LatLng position,
    required double radius,
    String? type,
    String? keyword,
  }) async {
    // 调用附近搜索 API
    return [];
  }
  
  @override
  Future<PlaceResult?> getPlaceDetails(String placeId) async {
    // 调用地点详情 API
    return null;
  }
  
  @override
  Future<LatLng?> geocode(String address) async {
    // 调用地理编码 API
    return null;
  }
  
  @override
  Future<String?> reverseGeocode(LatLng position) async {
    // 调用逆地理编码 API
    return null;
  }

  // ==================== 导航功能 ====================
  
  @override
  Future<MapRoute?> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    TravelNavigationMode mode = TravelNavigationMode.walking,
  }) async {
    // 调用 Directions API 计算路线
    // 返回模拟路线
    return MapRoute(
      id: 'route_${DateTime.now().millisecondsSinceEpoch}',
      points: [origin, destination],
      style: const RouteStyle(),
      duration: const Duration(minutes: 30),
      distance: 2000.0,
    );
  }
  
  @override
  Future<void> startNavigation({
    required LatLng destination,
    String? destinationName,
    TravelNavigationMode mode = TravelNavigationMode.walking,
  }) async {
    // 调用系统导航或第三方导航APP
  }

  // ==================== 事件流 ====================
  
  @override
  Stream<LatLng> get onMapTap => _onMapTapController.stream;
  
  @override
  Stream<MapMarker> get onMarkerTap => _onMarkerTapController.stream;
  
  @override
  Stream<CameraPositionEvent> get onCameraMove => _onCameraMoveController.stream;
  
  @override
  Stream<LatLng> get onMyLocationUpdate => _onMyLocationUpdateController.stream;

  // ==================== 内部方法 ====================
  
  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('位置权限被拒绝');
    }
  }
  
  void _startLocationTracking() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      _onMyLocationUpdateController.add(
        LatLng(position.latitude, position.longitude),
      );
    });
  }
  
  Future<void> _updateGoogleMapMarkers() async {
    // 更新 Google Map 的标记集合
    // 需要在 Widget 层调用 setState 或通知 Provider
  }
  
  Future<void> _updateGoogleMapPolylines() async {
    // 更新 Google Map 的路线集合
  }
  
  Future<gmaps.BitmapDescriptor> _getDefaultMarkerIcon(MarkerType type) async {
    // 根据类型返回不同的默认图标
    switch (type) {
      case MarkerType.food:
        return gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueOrange,
        );
      case MarkerType.attraction:
        return gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueRed,
        );
      case MarkerType.hotel:
        return gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueBlue,
        );
      default:
        return gmaps.BitmapDescriptor.defaultMarker;
    }
  }
  
  List<gmaps.PatternItem> _convertRoutePattern(RoutePattern pattern) {
    switch (pattern) {
      case RoutePattern.dashed:
        return [
          gmaps.PatternItem.dash(20),
          gmaps.PatternItem.gap(10),
        ];
      case RoutePattern.dotted:
        return [
          gmaps.PatternItem.dot,
          gmaps.PatternItem.gap(5),
        ];
      default:
        return [];
    }
  }
  
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
  
  // 设置 Google Map 控制器 (由 Widget 层调用)
  void setGoogleMapController(gmaps.GoogleMapController controller) {
    _googleMapController = controller;
  }
  
  // 获取当前标记集合 (供 Widget 层使用)
  Set<gmaps.Marker> get currentMarkers => _markers.values.toSet();
  Set<gmaps.Polyline> get currentPolylines => _polylines.values.toSet();
}
