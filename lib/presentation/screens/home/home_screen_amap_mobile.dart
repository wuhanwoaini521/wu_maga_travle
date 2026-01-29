// Mobile 平台的高德地图实现
import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart' as base;
import '../../../core/theme/comic_theme.dart';

/// Mobile 平台创建 LatLng
base.LatLng createLatLng(double latitude, double longitude) {
  return base.LatLng(latitude, longitude);
}

/// Mobile 平台构建地图层
Widget buildMapLayer({
  required BuildContext context,
  required dynamic city,
  required Set<dynamic> markers,
  required Function(dynamic) onMapCreated,
  required Function() onTap,
}) {
  return AMapWidget(
    apiKey: const base.AMapApiKey(
      androidKey: 'YOUR_AMAP_ANDROID_KEY',
      iosKey: 'YOUR_AMAP_IOS_KEY',
    ),
    privacyStatement: const base.AMapPrivacyStatement(
      hasContains: true,
      hasShow: true,
      hasAgree: true,
    ),
    initialCameraPosition: CameraPosition(
      target: city.center,
      zoom: city.defaultZoom,
    ),
    markers: markers.cast<Marker>(),
    myLocationStyleOptions: MyLocationStyleOptions(
      true,
      circleFillColor: ComicColors.primary.withOpacity(0.2),
      circleStrokeColor: ComicColors.primary,
      circleStrokeWidth: 2,
    ),
    compassEnabled: true,
    mapType: MapType.normal,
    onMapCreated: (controller) {
      onMapCreated(controller);
    },
    onTap: (latLng) {
      onTap();
    },
  );
}

/// Mobile 平台移动相机
void moveCamera(dynamic controller, dynamic center, double zoom) {
  if (controller != null && controller is AMapController) {
    controller.moveCamera(
      CameraUpdate.newLatLngZoom(center, zoom),
    );
  }
}
