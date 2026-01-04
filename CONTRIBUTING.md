## 贡献指南

感谢关注大头记账！为了保持代码质量和可维护性，请遵循以下流程：

1. **讨论与规划**：在提交较大变更前，先在 Issue 中简要描述需求与方案。
2. **分支策略**：从主分支拉取 feature 分支进行开发。
3. **开发约定**：
   - 尽量保持模块边界：UI 在 Flutter，业务在 `packages/core`，跨平台能力通过 `packages/ffibindings` / `native/cross_core`。
   - 数据协议推荐 protobuf；新增接口请同步更新 `docs/architecture.md`。
   - 代码需要通过现有的 lint/analyze/test（CI 会验证）。
4. **提交 PR**：
   - PR 描述中列出“已完成”、“未完成（后续任务）”、“注意事项”（如 iOS 签名、native 交叉编译依赖环境）。
   - 为新增功能补充必要的测试或示例。
5. **代码规范**：
   - Dart 遵循 `flutter format` / `dart format` 和 `flutter analyze`。
   - C/C++ 维持简洁的 C ABI，避免平台特化逻辑渗透核心。

欢迎提交 Issue 或 PR，一起完善多平台记账体验！
