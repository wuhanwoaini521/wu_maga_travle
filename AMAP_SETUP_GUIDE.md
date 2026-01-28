# 高德地图接入指南

## 1. 申请高德地图 API Key

### 1.1 注册高德开发者账号
- 访问 [高德开放平台](https://lbs.amap.com/)
- 注册并登录开发者账号
- 完成开发者认证（个人/企业）

### 1.2 创建应用并获取 Key
1. 进入控制台 → 应用管理 → 创建新应用
2. 添加 Key：
   - **Key 名称**：manga_travel_android
   - **服务平台**：Android 平台
   - **发布版安全码 SHA1**：需要生成（见下文）
   - **PackageName**：`com.example.manga_travel`

3. 添加 iOS Key（如需要）：
   - **Key 名称**：manga_travel_ios
   - **服务平台**：iOS 平台
   - **Bundle Identifier**：你的 iOS Bundle ID

## 2. 生成 Android 签名 SHA1

### 2.1 调试版 SHA1
```bash
# 进入 Android 项目目录
cd android

# 使用 Gradle 获取调试签名
./gradlew signingReport
```

在输出中找到 `Variant: debug` 的 `SHA1` 值。

### 2.2 发布版 SHA1
```bash
# 如果你有发布版 keystore
keytool -list -v -keystore your-release-key.keystore
```

## 3. 配置项目

### 3.1 修改 Android 配置

**android/app/build.gradle.kts**
```kotlin
defaultConfig {
    applicationId = "com.example.manga_travel"
    minSdk = 21  // 高德地图需要 minSdk 21
    
    // 替换为你的高德 Key
    manifestPlaceholders["AMAP_API_KEY"] = "你的高德Android Key"
}
```

### 3.2 隐私合规（重要）

高德地图需要隐私合规声明，在应用启动时调用：

```dart
import 'package:amap_flutter_location/amap_flutter_location.dart';

void main() {
  // 更新隐私合规
  AMapFlutterLocation.updatePrivacyShow(true, true);
  AMapFlutterLocation.updatePrivacyAgree(true);
  
  runApp(MyApp());
}
```

## 4. 高德地图 vs Google Maps 差异

| 功能 | Google Maps | 高德地图 |
|------|-------------|----------|
| 坐标系 | WGS-84 | GCJ-02（火星坐标系）|
| 国内精度 | 偏移较大 | 精准 |
| 海外数据 | 完整 | 有限 |
| POI 数据 | 一般 | 丰富（国内）|
| 导航功能 | 需跳转 Google Maps | 内置导航 SDK |

## 5. 坐标转换（重要）

如果你需要同时使用 Google Maps 和高德地图，需要坐标转换：

```dart
/// WGS-84 (Google) 转 GCJ-02 (高德)
LatLng wgs84ToGcj02(double lat, double lng) {
  // 使用第三方库或自行实现转换算法
}

/// GCJ-02 (高德) 转 WGS-84 (Google)
LatLng gcj02ToWgs84(double lat, double lng) {
  // 使用第三方库或自行实现转换算法
}
```

## 6. 常见问题

### Q: 地图显示空白？
A: 检查：
1. API Key 是否正确
2. 是否添加了必要权限
3. 隐私合规是否已调用

### Q: 定位偏移？
A: 这是正常现象，高德使用 GCJ-02 坐标系，与 GPS 的 WGS-84 有约 100-500 米偏移。

### Q: 海外地图显示？
A: 高德地图主要覆盖中国境内，海外数据有限。如需海外地图，建议保留 Google Maps 作为备选。

## 7. 双地图方案（推荐）

根据用户位置自动切换地图：

```dart
Widget buildMap() {
  if (isInChina(userLocation)) {
    return AMapWidget(...);  // 国内用高德
  } else {
    return GoogleMap(...);    // 海外用 Google
  }
}
```
