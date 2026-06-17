# 可复制到 Codex `/goal` 的提示词

/goal 在当前新建的 iOS 项目目录中落地“一爻”免费版。请先阅读 AGENTS.md、PRODUCT_BRIEF.md、ROADMAP.md、docs/multi-agent-plan.md；若这些文件不存在，先按本提示创建它们。目标：用 SwiftUI 做一个免费、无广告、无账号、离线优先的周易学习与卦象记录 App MVP。

产品边界：App 名“一爻”；MVP 不做 AI、联网、订阅、内购、广告、云同步、八字、风水、复杂六爻纳甲。所有问卦记录只保存在本机。文案必须克制，不能承诺精准预测、改命、开运，只定位为传统文化学习、反思与记录工具。

多 agent 执行：由主线程担任 Orchestrator。按 ROADMAP 选择最小可交付切片；需要并行时派发子 agent，但必须职责互不冲突。建议角色：Content Agent 整理八卦/64卦数据与学习文案；Engine Agent 实现 LineValue、Trigram、Hexagram、CastingEngine 和本卦/变卦/动爻测试；UI Agent 实现 SwiftUI 起卦、卦库、记录、学习页；Persistence Agent 实现本地记录；Validation Agent 独立验证 PR。

第一阶段请自动完成 PR 1：项目骨架。若目录还不是 Xcode 项目，请创建 SwiftUI iOS App，建议最低 iOS 17；建立 Domain、Services、Features、Resources、Tests 结构；创建 TabView/NavigationStack App shell，包含“起卦、卦库、记录、学习、设置”入口；加入隐私与免责声明占位；确保 App 可构建启动。

PR 策略：每个切片新建 feature 分支，完成后运行构建和相关测试，commit、push，并使用 gh 创建或更新 draft PR。如果没有 GitHub remote 或 gh 未登录，输出完整命令和 Validation Handoff。不要自动 merge。Validation Agent 必须验证最新 head commit，结论只能是 Blocked、Pass but weak、Merge candidate。

验证：优先使用 XcodeBuildMCP；若不可用，用 xcodebuild。至少验证构建通过、单元测试通过或说明暂无测试、模拟器可启动。UI 改动需检查小屏不截断、深浅色不崩、完成一次基础路径。

完成 PR 1 后输出：PR 链接或创建 PR 所需命令、改动摘要、测试结果、风险、下一建议 PR。

