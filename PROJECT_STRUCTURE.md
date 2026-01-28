# Manga Travel App - 项目结构文档

## 项目概述
一款基于Flutter的漫画风格旅游App，支持地图导航、AI导游、路线规划等功能。

## 推荐状态管理方案

### 推荐: Riverpod (本项目使用)
**理由:**
- 编译时安全，无需 BuildContext
- 支持代码生成，减少样板代码
- 优秀的依赖注入和测试支持
- 适合中型到大型项目

### 替代方案: Bloc
- 适合需要严格分层架构的大型团队
- 事件驱动，状态流转清晰

## 项目目录结构

```
lib/
├── main.dart                          # 应用入口
├── app.dart                           # 应用配置 (主题、路由)
│
├── core/                              # 核心层 - 全局共享
│   ├── constants/                     # 常量定义
│   │   ├── api_constants.dart         # API 地址
│   │   ├── app_constants.dart         # 应用常量
│   │   └── storage_keys.dart          # 存储键名
│   ├── theme/                         # 主题配置
│   │   ├── comic_theme.dart           # 漫画主题 (颜色、字体、描边)
│   │   └── app_theme.dart             # Material 主题适配
│   ├── utils/                         # 工具类
│   │   ├── logger.dart                # 日志工具
│   │   ├── extensions.dart            # 扩展方法
│   │   └── helpers.dart               # 辅助函数
│   └── extensions/                    # Dart 扩展
│       ├── context_extension.dart
│       └── string_extension.dart
│
├── config/                            # 配置层
│   ├── themes/                        # 主题配置
│   ├── routes/                        # 路由配置
│   │   ├── app_router.dart            # GoRouter 配置
│   │   └── route_names.dart           # 路由名称常量
│   └── di/                            # 依赖注入
│       ├── injection.dart             # GetIt 配置
│       └── modules/                   # 模块注入
│
├── domain/                            # 领域层 - 业务核心
│   ├── entities/                      # 实体 (纯数据)
│   │   ├── city.dart
│   │   ├── place.dart
│   │   ├── route.dart
│   │   └── user.dart
│   ├── repositories/                  # 仓库接口
│   │   ├── map_repository.dart        # 地图仓库接口
│   │   ├── place_repository.dart      # 地点仓库接口
│   │   ├── favorite_repository.dart   # 收藏仓库接口
│   │   └── ai_guide_repository.dart   # AI导游仓库接口
│   └── usecases/                      # 用例 (业务逻辑)
│       ├── get_nearby_places.dart
│       ├── plan_route.dart
│       └── get_ai_recommendation.dart
│
├── data/                              # 数据层 - 实现细节
│   ├── models/                        # 数据模型 (DTO)
│   │   ├── place_model.dart
│   │   ├── route_model.dart
│   │   └── city_model.dart
│   ├── repositories/                  # 仓库实现
│   │   ├── map_repository_impl.dart   # 地图仓库实现
│   │   ├── place_repository_impl.dart
│   │   └── favorite_repository_impl.dart
│   ├── datasources/                   # 数据源
│   │   ├── local/                     # 本地数据源
│   │   │   ├── database/              # Isar 数据库
│   │   │   ├── cache/                 # 缓存管理
│   │   │   └── preferences/           # SharedPreferences
│   │   └── remote/                    # 远程数据源
│   │       ├── api/                   # REST API
│   │       │   ├── place_api.dart
│   │       │   └── route_api.dart
│   │       └── llm/                   # LLM API
│   │           ├── openai_service.dart
│   │           └── prompt_templates.dart
│   └── services/                      # 服务
│       ├── location_service.dart      # 定位服务
│       ├── map_style_service.dart     # 地图样式服务
│       └── connectivity_service.dart  # 网络状态服务
│
├── presentation/                      # 表现层 - UI
│   ├── screens/                       # 页面
│   │   ├── home/                      # 首页 (地图)
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/               # 页面专属组件
│   │   ├── route_planning/            # 路线规划
│   │   │   └── route_planning_screen.dart
│   │   ├── favorites/                 # 收藏
│   │   │   └── favorites_screen.dart
│   │   ├── ai_guide/                  # AI导游
│   │   │   └── ai_guide_screen.dart
│   │   ├── place_detail/              # 地点详情
│   │   │   └── place_detail_screen.dart
│   │   └── profile/                   # 个人中心
│   │       └── profile_screen.dart
│   │
│   ├── widgets/                       # 共享组件
│   │   ├── common/                    # 通用组件
│   │   │   ├── loading_indicator.dart
│   │   │   ├── error_view.dart
│   │   │   └── empty_view.dart
│   │   ├── comic_style/               # 漫画风格组件 ⭐
│   │   │   ├── comic_container.dart   # 漫画容器 (描边+阴影)
│   │   │   ├── comic_button.dart      # 漫画按钮
│   │   │   ├── comic_card.dart        # 漫画卡片
│   │   │   ├── speech_bubble.dart     # 气泡对话框
│   │   │   ├── comic_badge.dart       # 徽章/标签
│   │   │   └── comic_text_field.dart  # 漫画输入框
│   │   └── map/                       # 地图相关组件
│   │       ├── comic_map_marker.dart  # 漫画标记组件 ⭐
│   │       ├── map_style_loader.dart  # 地图样式加载
│   │       ├── route_line.dart        # 路线绘制
│   │       └── location_button.dart   # 定位按钮
│   │
│   ├── providers/                     # Riverpod Providers
│   │   ├── city_provider.dart         # 城市状态
│   │   ├── map_provider.dart          # 地图状态
│   │   ├── marker_provider.dart       # 标记状态
│   │   ├── ai_guide_provider.dart     # AI导游状态
│   │   └── user_provider.dart         # 用户状态
│   │
│   └── bloc/                          # 如使用 Bloc
│       └── (可选)
│
└── generated/                         # 代码生成文件
    ├── *.g.dart                       # Riverpod/Json 生成
    └── *.freezed.dart                 # Freezed 生成

assets/                                # 资源文件
├── images/                            # 图片
│   ├── comic_bg_pattern.png           # 漫画背景纹理
│   ├── halftone_pattern.png           # 网点图案
│   └── speed_line_bg.png              # 速度线背景
├── icons/                             # 图标
│   ├── marker_food.png                # 美食标记
│   ├── marker_attraction.png          # 景点标记
│   ├── marker_hotel.png               # 酒店标记
│   ├── marker_shopping.png            # 购物标记
│   └── pin_handdrawn.svg              # 手绘大头针
├── characters/                        # AI角色
│   ├── guide_avatar.png               # 导游头像
│   └── guide_expression_*.png         # 表情
├── cities/                            # 城市封面
│   ├── tokyo_cover.png
│   ├── kyoto_cover.png
│   └── osaka_cover.png
├── map_styles/                        # 地图样式 JSON
│   ├── comic_map_style.json           # 漫画风格地图
│   └── comic_map_style_dark.json      # 深色模式
├── animations/                        # Lottie 动画
│   └── loading_comic.json
└── config/                            # 配置文件
    ├── map_providers.json             # 地图提供商配置
    └── cities.json                    # 城市数据

test/                                  # 测试
├── unit/                              # 单元测试
├── widget/                            # 组件测试
└── integration/                       # 集成测试
```

## 关键设计模式

### 1. Repository Pattern (仓库模式)
```dart
// domain/repositories/map_repository.dart - 接口
abstract class MapRepository {
  Future<void> addMarker(MapMarker marker);
  Future<void> drawRoute(MapRoute route);
  // ...
}

// data/repositories/map_repository_impl.dart - 实现
class MapRepositoryImpl implements MapRepository {
  final MapProvider _provider; // Google/高德切换
  // ...
}
```

### 2. Dependency Injection (依赖注入)
```dart
// 使用 GetIt + injectable
@injectable
class MapRepositoryImpl implements MapRepository {
  // 自动注入
}
```

### 3. State Management (Riverpod)
```dart
// 定义 Provider
final selectedCityProvider = StateProvider<City>((ref) => cities.first);

// 使用
final city = ref.watch(selectedCityProvider);
ref.read(selectedCityProvider.notifier).state = newCity;
```

## 漫画风格实现要点

### 1. 描边效果 (Outline)
```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(color: ComicColors.outline, width: 3),
    boxShadow: ComicShadows.standard, // 硬边阴影
  ),
)
```

### 2. 自定义 Marker
使用 `CustomPainter` 绘制漫画风格大头针，支持：
- 分类颜色区分
- 选中弹跳动画
- 收藏标记徽章

### 3. 气泡对话框
```dart
SpeechBubble(
  type: BubbleType.speech,  // speech/thought/shout
  direction: BubbleDirection.leftBottom,
  child: Text('漫画风格对话框'),
)
```

## 地图多提供商切换

```dart
// 根据用户区域自动选择
MapProviderType autoSelectProvider(String region) {
  switch (region) {
    case 'CN': return MapProviderType.amap;    // 国内用高德
    case 'JP': return MapProviderType.google;  // 日本用Google
    default: return MapProviderType.google;
  }
}
```

## 下一步开发建议

1. **完善地图样式**: 创建 `comic_map_style.json` 配置地图底图颜色
2. **实现AI导游**: 接入 OpenAI API，实现对话式推荐
3. **添加收藏功能**: 使用 Isar 数据库本地存储
4. **路线规划**: 集成 Directions API，绘制漫画风格路线
5. **动画优化**: 添加页面切换、标记弹跳的漫画特效
