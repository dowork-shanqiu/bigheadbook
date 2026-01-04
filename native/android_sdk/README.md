# Android 平台 glue 占位

- 目标：封装 `libcross_core.so` 为 AAR，提供 Java/Kotlin 接口层。
- 步骤（TODO）：
  - 使用 NDK/Gradle 构建跨平台核心。
  - 通过 JNI 暴露初始化、记账、汇总接口。
  - 将生成的二进制发布到私有/公共仓库或内置于 app。
  - 配置 ProGuard / R8 规则。
