# iOS 平台 glue 占位

- 目标：将 `libcross_core` 打包为 XCFramework，供 Swift/Objective-C 和 Flutter（iOS）链接。
- 步骤（TODO）：
  - 使用 Xcode / CMake 生成 `.a` 或 `.dylib`，再封装为 XCFramework。
  - Swift 包装层暴露友好的 API，并保持与 C ABI 对齐。
  - 集成到 Flutter iOS 构建流程（`flutter build ios --no-codesign`）。
  - 签名与发布配置留待后续。
