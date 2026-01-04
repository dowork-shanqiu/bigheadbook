# cross_core

跨平台核心示例，以 C ABI 暴露给 Flutter/dart:ffi、Android、iOS、Harmony Next（ArkUI-X）等前端复用。

## 目标
- 提供稳定的 C 接口：初始化、记账、汇总查询。
- 后续通过 protobuf 传递复杂结构，当前为简单示例。
- 生成预编译库（`.so/.dylib/.a`）供各平台链接。

## 接口
见 `cross_core.h`：
- `crosscore_init`
- `crosscore_add_transaction`
- `crosscore_query_summary`

## 构建示例
```bash
clang -c cross_core.c -o cross_core.o
clang -shared cross_core.o -o libcross_core.so  # Linux/Android 示例
```

TODO:
- 跨平台构建脚本（Android NDK、iOS toolchain、Harmony）。
- Protobuf 协议与精度处理（小数/多币种）。
- 线程安全与持久化策略。
