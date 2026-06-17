# 一爻 - Codex 项目规则

## 产品定位

一爻是一款免费的 iOS 周易学习与卦象记录应用。第一版目标是“清楚、克制、可信”，不是玄学营销，也不是付费算命。

核心气质：
- 免费、无广告、无账号、离线优先。
- 帮助初学者理解卦象如何生成、如何阅读、如何记录复盘。
- 所有占问内容仅作为文化学习、反思和记录工具，不提供确定性预测承诺。

## 技术边界

- 平台：iOS，SwiftUI。
- 建议最低系统：iOS 17，优先使用现代 SwiftUI 和 SwiftData；如项目选择 iOS 16，需改用 `ObservableObject` 与本地 JSON/FileManager。
- 数据：64 卦、八卦、卦辞、爻辞、白话释义使用本地 JSON 或 Swift fixtures。
- 网络：MVP 不需要网络。
- AI：MVP 不接入 AI。
- 商业化：MVP 免费，不做内购、订阅、广告。
- 隐私：问卦记录只保存在本机，不上传。

## MVP 功能范围

必须完成：
- 起卦：铜钱法自动起卦、手动画爻。
- 结果：展示本卦、动爻、变卦、上下卦、六爻结构。
- 卦库：64 卦浏览、搜索、详情页。
- 记录：保存问题、起卦方式、六爻值、结果、备注、时间。
- 学习：阴阳、八卦、六十四卦、动爻/变卦的入门解释。
- 设置：隐私说明、免责声明、数据清除。

暂不做：
- 登录、云同步、社区、推送、付费、AI 解读、复杂六爻纳甲、风水、八字。

## 代码组织建议

- `YiyaoApp/`: App entry 与根导航。
- `Features/Casting/`: 起卦流程、手动画爻、结果页。
- `Features/HexagramLibrary/`: 卦库列表、搜索、详情。
- `Features/Journal/`: 记录列表、详情、备注。
- `Features/Learning/`: 入门学习页。
- `Domain/`: Hexagram、Trigram、LineValue、CastingResult 等纯模型。
- `Services/`: HexagramStore、CastingEngine、JournalStore。
- `Resources/`: hexagrams.json、trigrams.json。
- `Tests/`: 起卦计算、变卦、搜索、持久化测试。

## 多 agent 工作方式

主线程是 orchestrator，负责整合与最终判断。可使用子 agent，但职责必须拆开，避免多人改同一核心文件。

推荐角色：
- Product/Content Agent：整理 64 卦数据结构、学习文案、免责声明。
- Engine Agent：实现阴阳爻、八卦、六十四卦、本卦/变卦计算。
- UI Agent：SwiftUI App shell、起卦、卦库、记录、学习页。
- Persistence Agent：SwiftData/本地存储与导入 fixture。
- Validation Agent：独立构建、测试、走查 UI，判断 PR 是否可合并。

## PR 与 Git 规则

- 每个实现 agent 使用独立分支：`feature/<slice-name>`。
- 每个 PR 必须是一个有价值的垂直切片，不接受只有零散样式或单行改动的 PR。
- 实现 agent 应自动提交、推送并创建或更新 draft PR；若没有 remote 或 GitHub auth，输出可执行命令和完整 handoff。
- Validation Agent 必须验证最新 head commit。
- 不自动合并。只有用户明确批准后才可 merge。
- 禁止 `git reset --hard`、强推、删除用户未确认的文件。

## 验证标准

每个 PR 至少运行：
- `xcodebuild` 或 XcodeBuildMCP 构建。
- 相关单元测试。
- 模拟器 smoke test：打开 App，完成一次起卦，查看卦库，保存记录。

UI PR 还需检查：
- 小屏 iPhone 宽度不截断。
- 深浅色至少不崩。
- 交互控件有清晰状态。
- 免责声明不制造恐惧或确定性预测。

## App Store 文案边界

允许：
- “周易学习”
- “卦象记录”
- “帮助理解变化与处境”

避免：
- “精准预测”
- “改命开运”
- “保证结果”
- “替代专业建议”

