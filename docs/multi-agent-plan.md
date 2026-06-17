# 一爻多 Agent 落地计划

## 总体模式

采用 Orchestrator + Implementation Agents + Validation Agent。

Orchestrator：
- 读取 `AGENTS.md`、`PRODUCT_BRIEF.md`、`ROADMAP.md`。
- 选择当前最小可交付切片。
- 分派互不冲突的子任务。
- 负责合并、构建、最终 PR handoff。

Implementation Agents：
- 只做被分派的明确切片。
- 不改无关文件。
- 完成后报告改动、测试、风险。

Validation Agent：
- 独立验证 draft PR。
- 不做业务功能开发。
- 可以修复明显测试配置或文档小问题，但不得重写实现。
- 输出 `Blocked`、`Pass but weak`、`Merge candidate`。

## 第一批 PR 建议

PR 1：项目骨架
- 创建 SwiftUI 项目、目录结构、基本 TabView/NavigationStack。
- 加入 AGENTS/产品文档。
- 验证：构建通过，App 可启动。

PR 2：领域模型与起卦引擎
- 实现 LineValue、Trigram、Hexagram、CastingEngine。
- 覆盖本卦、变卦、动爻测试。
- 验证：单元测试通过。

PR 3：本地卦库数据
- 加入 8 卦、64 卦数据结构和 fixture。
- 实现 HexagramStore 与完整性校验。
- 验证：64 条数据、卦号唯一、上下卦有效。

PR 4：起卦与结果页
- 问题输入、铜钱法、手动画爻、结果展示。
- 验证：模拟器完成一次起卦。

PR 5：卦库与学习页
- 64 卦列表、搜索、详情、基础学习内容。
- 验证：搜索和详情路径可用。

PR 6：记录系统
- 本地保存、列表、详情、备注、删除。
- 验证：记录重启后仍在。

PR 7：QA 与上架准备
- 深浅色、小屏、免责声明、隐私文案、App 图标占位。
- 验证：完整 smoke test。

## 自动 PR 策略

每个 PR：
1. 新建分支。
2. 实现一个切片。
3. 运行测试。
4. commit + push。
5. 创建 draft PR。
6. 生成 Validation Handoff。
7. 交给 Validation Agent。

不自动合并。只有用户明确说“合并”才可 merge。

