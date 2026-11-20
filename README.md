# LiquidGlas

iOS 控制中心液态玻璃风格插件（Theos tweak）。

- 包名 / 偏好域：`com.axs.liquidglas`
- 工程与类前缀：`AxsLiquidGlas`
- C 函数与新增 selector 前缀：`axs_liquidglas_`
- 注入目标：`com.apple.springboard`（Control Center 运行在 SpringBoard 进程内）
- 最低系统：iOS 14.0（rootless / roothide 需 iOS 15.0 以上）

## 工程结构

```text
LiquidGlas/
|-- .github/workflows/build.yml           GitHub Actions 构建与 Release
|-- control                               Debian 包信息
|-- Makefile                              主工程
|-- AxsLiquidGlasBuild.mk                 主工程与面板共享的 SDK / 架构配置
|-- AxsLiquidGlas.plist                   MobileSubstrate 注入过滤器
|-- build.sh                              rootful / rootless / roothide 打包
|-- tweak.json                            生成器身份记录
|-- Hooks/
|   `-- AxsLiquidGlasMain.xm              Control Center 模块容器 hook
|-- Headers/
|   `-- AxsLiquidGlasPrivate.h            Control Center 私有类声明
|-- Sources/
|   |-- AxsLiquidGlasConfig.h/.m          配置快照（读文件，失败回落偏好域）
|   |-- AxsLiquidGlasPreferences.h        唯一读写实现（面板写，Tweak 读）
|   |-- AxsLiquidGlasPaths.h              配置路径（rootless / roothide 适配）
|   |-- AxsLiquidGlasEffectManager.h/.m   玻璃层挂载与刷新
|   `-- AxsLiquidGlasGlassView.h/.m       玻璃视图（模糊材质 + 着色 + 高光）
|-- AxsLiquidGlasPrefs/                   设置面板（PreferenceBundle）
`-- layout/Library/PreferenceLoader/      设置入口
```

## 配置

| 键 | 含义 | 默认值 |
|---|---|---|
| `enabled` | 启用插件 | 关闭 |
| `glassOpacity` | 玻璃着色透明度 | 0.85 |
| `glassBlur` | 模糊强度（0–50，映射到材质透明度） | 15 |
| `glossLevel` | 高光强度 | 0.5 |
| `cornerRadius` | 圆角半径 | 25 |
| `colorTint` | 着色（`#RRGGBB`，解析失败用 `#2563eb`） | `#2563eb` |

面板是配置文件的唯一写入方：写入 `/var/mobile/Library/Preferences/com.axs.liquidglas.plist`
（roothide 下为隐根路径），并镜像到 `NSUserDefaults` 后广播
`com.axs.liquidglas.preferences-changed`。Tweak 只读快照，不写默认值。

## 构建

```sh
export THEOS=/path/to/theos
sh build.sh            # rootless
sh build.sh all        # rootful + rootless + roothide
```

推送 `main` / `master` 或手动触发工作流时，CI 用 `5.2.0-<run_number>` 作为包版本构建并发布 Release。

## 已知边界

- hook 目标是 `CCUIContentModuleContainerViewController`（ControlCenterUIKit）。启动时用
  `objc_getClass` 探测，类不存在则跳过 hook。若目标系统类名不同，只需改
  `Headers/AxsLiquidGlasPrivate.h` 与 `Hooks/AxsLiquidGlasMain.xm`。
- 玻璃层 `userInteractionEnabled = NO`，不接管控制中心触摸。
- `UIBlurEffect` 没有公开的半径 API，`glassBlur` 通过材质透明度近似强度。
