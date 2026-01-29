/// 高德地图封装组件
/// 替代 Google Maps 的国内地图方案

import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart' as amap;
import 'package:amap_flutter_base/amap_flutter_base.dart' as base;

import '../../../core/theme/comic_theme.dart';

/// 高德地图控制器包装器
class AMapControllerWrapper {
  final amap.AMapController? _controller;

  AMapControllerWrapper(this._controller);

  /// 移动地图到指定位置
  Future<void> moveCamera(amap.CameraUpdate cameraUpdate) async {
    if (_controller == null) return;
    await _controller!.moveCamera(cameraUpdate);
  }

  /// 添加标记
  Future<void> addMarker(amap.Marker marker) async {
    // 标记通过 Set<Marker> 传递给 AMapWidget
  }
}

/// 高德地图 Widget 包装器
class AMapWidget extends StatefulWidget {
  final base.LatLng? initialCenter;
  final double initialZoom;
  final Set<amap.Marker>? markers;
  final Set<amap.Polyline>? polylines;
  final void Function(base.LatLng)? onMapTap;
  final void Function(AMapControllerWrapper)? onMapCreated;
  final bool showMyLocation;
  final bool showCompass;
  final base.AMapApiKey? apiKey;
  final base.AMapPrivacyStatement? privacyStatement;

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
    this.apiKey,
    this.privacyStatement,
  });

  @override
  State<AMapWidget> createState() => AMapWidgetState();
}

class AMapWidgetState extends State<AMapWidget> {
  AMapControllerWrapper? _controller;

  @override
  void initState() {
    super.initState();
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
        const base.LatLng(39.909187, 116.397451); // 默认北京天安门

    return amap.AMapWidget(
      apiKey: widget.apiKey,
      privacyStatement: widget.privacyStatement,
      initialCameraPosition: amap.CameraPosition(
        target: initialPosition,
        zoom: widget.initialZoom,
      ),
      markers: widget.markers ?? const {},
      polylines: widget.polylines ?? const {},
      myLocationStyleOptions: widget.showMyLocation
          ? amap.MyLocationStyleOptions(
              true,
              circleFillColor: ComicColors.primary.withOpacity(0.2),
              circleStrokeColor: ComicColors.primary,
              circleStrokeWidth: 2,
            )
          : null,
      compassEnabled: widget.showCompass,
      mapType: amap.MapType.normal,
      trafficEnabled: false,
      buildingsEnabled: true,
      onMapCreated: (controller) {
        _controller = AMapControllerWrapper(controller);
        widget.onMapCreated?.call(_controller!);
      },
      onTap: widget.onMapTap,
    );
  }
}

/// 地图标记创建工具
class AMapMarkerBuilder {
  /// 创建漫画风格标记
  static amap.Marker createComicMarker({
    required String id,
    required base.LatLng position,
    String? title,
    String? snippet,
    amap.BitmapDescriptor? icon,
    double rotation = 0,
    bool draggable = false,
    VoidCallback? onTap,
  }) {
    return amap.Marker(
      position: position,
      icon: icon ?? amap.BitmapDescriptor.defaultMarker,
      infoWindow: title != null
          ? amap.InfoWindow(title: title, snippet: snippet)
          : amap.InfoWindow.noText,
      draggable: draggable,
      onTap: onTap != null ? (String id) => onTap() : null,
    );
  }

  /// 创建自定义图片标记
  static Future<amap.BitmapDescriptor> createCustomIcon(
    String assetPath, {
    double width = 48,
    double height = 48,
  }) async {
    return amap.BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(width, height)),
      assetPath,
    );
  }
}

/// 地图路线创建工具
class AMapPolylineBuilder {
  /// 创建漫画风格路线
  static amap.Polyline createComicRoute({
    required String id,
    required List<base.LatLng> points,
    Color color = ComicColors.primary,
    double width = 6,
    bool isDashed = false,
  }) {
    return amap.Polyline(
      points: points,
      color: color,
      width: width,
    );
  }
}

/// 坐标转换工具
class AMapCoordinateUtil {
  /// Google Maps 坐标转高德坐标
  static base.LatLng googleToAmap(double latitude, double longitude) {
    // 高德和 Google 使用相同的 WGS-84 坐标系，直接转换
    return base.LatLng(latitude, longitude);
  }

  /// 批量转换坐标列表
  static List<base.LatLng> convertList(List<dynamic> points) {
    return points.map((p) {
      if (p is base.LatLng) return p;
      // 假设是 Google Maps 的 LatLng
      return base.LatLng(p.latitude, p.longitude);
    }).toList();
  }
}
