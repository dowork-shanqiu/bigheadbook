# 架构与模块边界

## 分层概览
- **apps/flutter_app**：Flutter UI 与大部分业务流程，可快速迭代，短期目标覆盖 Android/iOS。
- **packages/core**：Dart 层核心业务接口与参考实现，负责账务模型、基础校验、汇总等。
- **packages/ffibindings**：dart:ffi 封装层，桥接到原生跨平台核心库，保持 API 与 `native/cross_core` 一致。
- **native/cross_core**：跨平台核心（C/C++），暴露稳定的 C ABI，支持生成预编译二进制给 Flutter、Android、iOS、Harmony Next（ArkUI-X）复用。
- **native/android_sdk / native/ios_sdk**：平台 glue、打包说明和示例。

## 数据协议与序列化
- 推荐使用 **protobuf** 定义交易、账户、统计等消息，以便跨语言一致性。
- Dart/Flutter 可通过 `protobuf` 插件生成代码；原生层可用 `protoc` 对应语言插件生成。
- 与原生库交互时，可通过 C ABI 传递序列化后的二进制（`uint8_t*` + length），避免结构体对齐问题。

## FFI/ABI 设计要点
- 保持 C ABI（`extern "C"` + `typedef struct`），避免 C++ 名字改编。
- 函数示例（详见 `native/cross_core/cross_core.h`）：
  - `int crosscore_init(void);`
  - `int crosscore_add_transaction(double amount, const char* currency, const char* note);`
  - `int crosscore_query_summary(struct CrossCoreSummary* out);`
- 函数返回 `int` 状态码（0 表示成功），输出通过指针返回。
- Flutter 通过 `dart:ffi` 加载动态库，封装在 `packages/ffibindings`。

## 预编译库产出
- 目标产物：`libcross_core.so` (Android/Linux), `libcross_core.dylib` (macOS/iOS 模拟器), `libcross_core.a` (iOS 设备), Harmony 目标库待定。
- 构建脚本可放在 `native/cross_core/scripts` 或 `tooling/`，支持交叉编译（TODO）。
- CI 占位：在 Linux/macOS 上尝试编译示例 C 实现，后续可替换为正式构建。

## 待办与下一步
- 定义 protobuf schema（交易、账户、汇总）。
- 完善跨平台核心实现与测试（含精度与多币种处理）。
- 配置 Android/iOS 打包与签名流程，接入发布流水线。
- 增加 Flutter 侧的集成测试与 UI 测试。
