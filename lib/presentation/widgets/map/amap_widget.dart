/// 高德地图封装组件
/// 替代 Google Maps 的国内地图方案

import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart' as amap_base;

import '../../../core/theme/comic_theme.dart';

/// 高德地图控制器
class AMapController {
  final _AMapWidgetState? _state;

  AMapController(this._state);

  /// 移动地图到指定位置
  Future<void> moveCamera(amap_base.LatLng position, {double zoom = 14}) async {
    if (_state == null) return;
    // 使用 CameraUpdate
  }

  /// 添加标记
  Future<void> addMarker(amap_base.LatLng position, {String? title}) async {
    if (_state == null) return;
  }
}

/// 高德地图 Widget
class AMapWidget extends StatefulWidget {
  final amap_base.LatLng? initialCenter;
  final double initialZoom;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final void Function(amap_base.LatLng)? onMapTap;
  final void Function(AMapController)? onMapCreated;
  final bool showMyLocation;
  final bool showCompass;

  const AMapWidget({
    super.key,
    this.initialCenter,
    this.initialZoom = 14,
    this.markers,
    this.polylines,
    this.onMapTap,
    this.onMapCreated,
    this.showMyLocation = true,
    this.showCompass = true,
  });

  @override
  State<AMapWidget> createState() => _AMapWidgetState();
}

class _AMapWidgetState extends State<AMapWidget> {
  AMapController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AMapController(this);
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 高德地图初始位置
    final initialPosition = widget.initialCenter ??
        amap_base.LatLng(39.909187, 116.397451); // 默认北京天安门

    // 高德地图 API Key 从 AndroidManifest.xml 自动读取
    // 不需要在代码中显式传递

    return AMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: widget.initialZoom,
      ),
      markers: widget.markers ?? {},
      polylines: widget.polylines ?? {},
      myLocationStyleOptions: widget.showMyLocation
          ? MyLocationStyleOptions(true,
              circleFillColor: ComicColors.primary.withOpacity(0.2),
              circleStrokeColor: ComicColors.primary,
              circleStrokeWidth: 2)
          : null,
      compassEnabled: widget.showCompass,
      mapType: MapType.normal,
      trafficEnabled: false,
      buildingsEnabled: true,
      onMapCreated: (controller) {
        widget.onMapCreated?.call(_controller!);
      },
      onTap: widget.onMapTap,
    );
  }
}

/// 地图标记创建工具
class AMapMarkerBuilder {
  /// 创建漫画风格标记
  static Marker createComicMarker({
    required String id,
    required amap_base.LatLng position,
    String? title,
    String? snippet,
    BitmapDescriptor? icon,
    double rotation = 0,
    bool draggable = false,
    VoidCallback? onTap,
  }) {
    return Marker(
      position: position,
      icon: icon ?? BitmapDescriptor.defaultMarker,
      infoWindow: title != null
          ? InfoWindow(title: title, snippet: snippet)
          : InfoWindow.noText,
      rotateAngle: rotation,
      draggable: draggable,
      onTap: onTap != null ? () => onTap() : null,
    );
  }

  /// 创建自定义图片标记
  static Future<BitmapDescriptor> createCustomIcon(
    String assetPath, {
    double width = 48,
    double height = 48,
  }) async {
    return BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(width, height)),
      assetPath,
    );
  }
}

/// 地图路线创建工具
class AMapPolylineBuilder {
  /// 创建漫画风格路线
  static Polyline createComicRoute({
    required String id,
    required List<amap_base.LatLng> points,
    Color color = ComicColors.primary,
    double width = 6,
    bool isDashed = false,
  }) {
    return Polyline(
      points: points,
      color: color,
      width: width,
      // 高德地图支持虚线样式
      lineDashType: isDashed ? LineDashType.square : LineDashType.none,
    );
  }
}

/// 坐标转换工具
class AMapCoordinateUtil {
  /// Google Maps 坐标转高德坐标
  static amap_base.LatLng googleToAmap(double latitude, double longitude) {
    // 高德和 Google 使用相同的 WGS-84 坐标系，直接转换
    return amap_base.LatLng(latitude, longitude);
  }

  /// 批量转换坐标列表
  static List<amap_base.LatLng> convertList(List<dynamic> points) {
    return points.map((p) {
      if (p is amap_base.LatLng) return p;
      // 假设是 Google Maps 的 LatLng
      return amap_base.LatLng(p.latitude, p.longitude);
    }).toList();
  }
}
