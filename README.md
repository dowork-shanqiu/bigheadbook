# 大头记账（bigheadbook）

一个面向多平台的记账应用基线。短期以 **Flutter** 为主要前端（Android/iOS），长期目标扩展到 **Harmony Next（ArkUI-X）** 及其他原生平台，通过复用同一套跨平台核心库（预编译二进制或 C ABI）。

## 路线图
- **短期**：Flutter (Dart) 应用，支持 Android / iOS；核心业务抽象为可复用的 Dart 包与 FFI 封装。
- **中期**：沉淀跨平台 C/C++ 核心（`native/cross_core`），产出预编译库，通过 dart:ffi/Android/iOS/Harmony 复用。
- **长期**：支持 Harmony Next（ArkUI-X）和其他原生前端，直接链接同一核心库。

## 仓库结构
- `apps/flutter_app/`：Flutter 最小可运行骨架。
- `packages/core/`：Dart 核心业务接口与示例实现。
- `packages/ffibindings/`：dart:ffi 封装示例，演示如何链接原生核心库。
- `native/cross_core/`：跨平台 C/C++ 核心接口头文件与示例实现。
- `native/android_sdk/`、`native/ios_sdk/`：平台 glue 说明。
- `docs/`：架构与协议说明。
- `.github/workflows/ci.yml`：CI 工作流（分析、测试、构建、原生编译占位）。

## 快速开始（Flutter 骨架）
```bash
cd apps/flutter_app
flutter pub get
flutter run    # 需已安装 Flutter SDK 与对应平台工具链
```

## 贡献
- 请先阅读 `CONTRIBUTING.md`。
- 提交 PR 时在描述中列出：已完成、未完成（后续任务）、注意事项（如 iOS 签名、native 交叉编译配置）。
- 推荐在变更中同步更新 `docs/architecture.md` 的决策或接口。

## 下一步（TODO）
- 完善跨平台核心实现与协议（推荐 protobuf）。
- 建立 Android / iOS 发布流水线（含签名配置）。
- 丰富自动化测试（Dart 单元测试、集成测试、原生层验证）。
