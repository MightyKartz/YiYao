# 一爻 PR1 UI Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish a focused PR1 refinement slice that makes the current YiYao shell feel quiet, slow, elegant, and traditionally Chinese while keeping the MVP scope to casting, result display, history, and settings.

**Architecture:** Keep the current SwiftUI project and three-tab information architecture. Improve the existing UI rather than introducing a new navigation model; create one small shared visual layer only if it reduces repeated paper/color code across Casting, History, and Settings. Generated image assets are decorative textures or coin material only, never the main input/button controls.

**Tech Stack:** SwiftUI, iOS 17+, XcodeBuildMCP, local asset catalog, optional ImageGen raster assets, XCTest.

---

## Scope

This slice should complete the current PR1 design direction:

- A direct entry screen: write one matter or silently ask, then cast.
- A ceremonial three-coin, six-throw animation with a calm "settle" moment.
- A result state whose hexagram and analysis are readable without the bottom tab covering content.
- A paper/jade/cinnabar color system that avoids black, heavy brown, cheap gold, and overdecorated symbols.
- Three tabs only: Casting, History, Settings.

Explicitly out of scope:

- Real 64-hexagram engine and data.
- AI, networking, accounts, ads, subscriptions, cloud sync.
- Manual line drawing.
- Reintroducing library or learning tabs.
- Complex 六爻纳甲, 八字, 风水.

## Skills And MCP

Use these skills when executing the goal:

- `superpowers:subagent-driven-development`: orchestrate fresh implementation and review subagents.
- `design-taste-frontend`: apply only the relevant taste principles to this native iOS UI; treat native iOS as an adaptation, not a web page.
- `animate`: refine the coin drop, reveal, and reduce-motion path.
- `colorize`: keep the palette integrated with the paper background.
- `polish`: final spacing, type, and state pass.
- `imagegen`: generate assets only if they improve paper texture or coin material; do not block the PR if image generation fails to produce a file.
- `build-ios-apps:ios-debugger-agent`: use XcodeBuildMCP for build, test, simulator launch, screenshots, and UI smoke checks.
- Optional if available: `product-design:get-context` and the existing Product Design audit in `docs/product-design-audit/2026-06-17-pr1-ui/revision-plan/ui-revision-plan.md`.

Use these MCP/tool capabilities:

- `multi_agent_v1.spawn_agent`: spawn worker/reviewer subagents only with disjoint file ownership.
- `mcp__xcodebuildmcp`: verify session defaults first, then build/test/run/screenshot/tap. If a required XcodeBuildMCP tool is not exposed, use `tool_search` to expose it.
- `image_gen`: generate raster assets when the `imagegen` skill calls for it.
- Shell fallback: `xcodebuild` only if XcodeBuildMCP is unavailable.

## Files

Likely modified files:

- `Features/Casting/CastingHomeView.swift`: primary UI, result layout, animation, button treatment.
- `Features/History/HistoryView.swift`: paper background and empty state polish.
- `Features/Settings/SettingsView.swift`: paper panels, copy presentation, destructive action treatment.
- `YiyaoApp/AppView.swift`: tab tint, possible native tab polish only.
- `Tests/YiYaoTests/AppShellTests.swift`: rename outdated test and keep IA/copy tests aligned.
- `Resources/Assets.xcassets/AccentColor.colorset/Contents.json`: palette if needed.
- `Resources/Assets.xcassets/PaperPanelTexture.imageset/*`: optional generated texture.
- `Resources/Assets.xcassets/CoinHeads.imageset/*` and `Resources/Assets.xcassets/CoinTails.imageset/*`: optional coin assets.
- `docs/product-design-audit/2026-06-17-pr1-ui/revision-plan/*`: update evidence and decisions.

Avoid adding a broad design-system directory unless repetition becomes a real bug. If adding a shared file, create `Features/Shared/YiYaoVisualStyle.swift` and update the Xcode project once in the style task.

## Multi-Agent Ownership

Run these tasks sequentially unless the orchestrator can guarantee disjoint write sets. Do not dispatch two workers that edit `CastingHomeView.swift` at the same time.

### Task 1: Orchestrator Setup

**Files:** no code edits unless documenting baseline evidence.

- [ ] Read `AGENTS.md`, `PRODUCT_BRIEF.md`, `ROADMAP.md`, `docs/multi-agent-plan.md`, and `docs/product-design-audit/2026-06-17-pr1-ui/revision-plan/ui-revision-plan.md`.
- [ ] Check `git status --short`. Preserve all existing user changes.
- [ ] Create or continue branch `feature/pr1-ui-refinement`.
- [ ] Use `tool_search` for `mcp__xcodebuildmcp` session/default/run/screenshot tools if they are not already exposed.
- [ ] Verify XcodeBuildMCP session defaults before any build or test. Expected project: `/Users/kartz/Development/YiYao/YiYao.xcodeproj`, scheme `YiYao`, simulator `iPhone 17e`.
- [ ] Capture baseline screenshots if the simulator can run; otherwise record that baseline screenshots are unavailable.

### Task 2: Visual Surface And Asset Worker

**Owned paths:**

- `Resources/Assets.xcassets/PaperPanelTexture.imageset/*`
- `Resources/Assets.xcassets/CoinHeads.imageset/*`
- `Resources/Assets.xcassets/CoinTails.imageset/*`
- Optional `Features/Shared/YiYaoVisualStyle.swift`
- Optional Xcode project file only if a new Swift source file is added.

- [ ] Use `imagegen` only for subtle assets. Generate a fine paper panel texture prompt:

```text
Create a subtle traditional Chinese xuan paper UI panel texture for an iOS app.
Warm ivory handmade paper, fine fibers, faint grey-green ink wash, extremely subtle cinnabar dust,
no readable text, no symbols, no coins, no hexagrams, no border, no strong corner decoration.
Low contrast, seamless-feeling, suitable as a low-opacity overlay behind text.
```

- [ ] If the generated file is available locally, add it as `PaperPanelTexture.imageset`; otherwise keep using `PaperInkBackground` and document the fallback in the PR risk section.
- [ ] Generate coin heads/tails only if files are available in a usable form. Coin prompt:

```text
Top-down ancient Chinese bronze coin for a quiet iOS casting animation.
Single round coin with square hole, refined aged bronze, museum-object lighting,
flat removable background, no readable text, no watermark, no strong shadow.
```

- [ ] If coin assets are not clean enough, do not integrate them. Keep the SwiftUI coin and only refine its color and motion in Task 3.
- [ ] If a shared style file is created, keep it small: colors, paper background, panel texture, panel stroke, and button surface only.

### Task 3: Casting UI And Animation Worker

**Owned paths:**

- `Features/Casting/CastingHomeView.swift`

- [ ] Add `ScrollViewReader` or equivalent layout handling so that after casting finishes, the result and `卦意初读` are readable and not covered by the tab bar.
- [ ] Increase bottom safe padding for the result state; verify on narrow simulator width.
- [ ] Make the cast button feel pressable without using black or heavy brown: pale paper-jade surface, subtle top highlight, subtle inner/outer shadow, cinnabar seal dot.
- [ ] Keep wording restrained:
  - Header: `一事在心`
  - Supporting line: `缓书其事，静观其变。`
  - Input placeholder: `可书一事，亦可默问。`
  - Primary action: `三钱取卦`
  - Casting state: `铜钱将落`
  - Recast: `再取一卦`
- [ ] Refine animation so each throw has three phases: rise/fall, settle pause, line reveal. Avoid bouncy or playful motion.
- [ ] Keep Reduce Motion path: one tap should immediately show all six lines and the result.
- [ ] Improve result card as "paper in paper": slightly cooler paper, light grey-green stroke, more breathing room between hexagram lines and name.
- [ ] Add non-color cue for moving lines when practical, such as accessibility labels or a tiny `动` text in analysis; do not rely only on cinnabar.
- [ ] Keep all copy as cultural learning/reflection, not deterministic prediction.

### Task 4: Secondary Surfaces Worker

**Owned paths:**

- `Features/History/HistoryView.swift`
- `Features/Settings/SettingsView.swift`
- `YiyaoApp/AppView.swift`

- [ ] Align History and Settings backgrounds with the casting page: warm paper in light mode, night paper in dark mode, not black/brown panels.
- [ ] Keep the History empty state quiet and useful:
  - Title: `尚无旧录`
  - Message: `成卦之后，可留作日后复看；所记只存于本机。`
- [ ] Keep Settings copy from `LocalOnlyPolicy`; do not introduce banned marketing or prediction claims.
- [ ] Adjust tab tint so it belongs to the paper/jade palette.
- [ ] Do not replace `TabView` with a custom tab bar in this slice unless native tab styling remains visibly inadequate after the P0 fixes.

### Task 5: Tests, Docs, And PR Worker

**Owned paths:**

- `Tests/YiYaoTests/AppShellTests.swift`
- `docs/product-design-audit/2026-06-17-pr1-ui/revision-plan/*`
- Optional `AGENTS.md`, `PRODUCT_BRIEF.md`, `ROADMAP.md`, `docs/multi-agent-plan.md` only if they drift from the implemented scope.

- [ ] Rename `testAppDefinesFivePrimaryTabsInProductOrder` to `testAppDefinesThreePrimaryTabsInProductOrder`.
- [ ] Keep IA tests asserting exactly `["起卦", "历史", "设置"]`.
- [ ] Keep copy boundary tests rejecting `精准预测`, `改命`, `开运`, `保证结果`, `付费`, `订阅`, `广告`, `AI`.
- [ ] Update the UI audit/revision notes with after-screenshots and what changed.
- [ ] Run `git diff --check`.
- [ ] Run XcodeBuildMCP build and tests. If XcodeBuildMCP is unavailable, run:

```bash
xcodebuild -project YiYao.xcodeproj -scheme YiYao -destination 'platform=iOS Simulator,name=iPhone 17e' build
xcodebuild -project YiYao.xcodeproj -scheme YiYao -destination 'platform=iOS Simulator,name=iPhone 17e' test
```

- [ ] Smoke test on simulator: open app, complete one cast, inspect result, switch to History and Settings, return to Casting.
- [ ] Capture light and dark screenshots. Verify text is not truncated, result analysis is not hidden by bottom tab, Reduce Motion path is acceptable.
- [ ] Commit with a clear message such as `feat: refine YiYao casting UI`.
- [ ] If remote and `gh` auth exist, push and create/update draft PR. If not, output exact commands and a Validation Handoff.

## Validation Agent Prompt

Use this prompt after the implementation commit exists:

```text
You are the Validation Agent for YiYao PR1 UI refinement.

Read AGENTS.md, PRODUCT_BRIEF.md, ROADMAP.md, docs/multi-agent-plan.md, and the latest handoff.
Validate only the latest head commit. Do not merge. Do not rewrite the implementation unless asked.

Check:
- Scope stayed within free/offline/no-account/no-AI/no-ads/no-subscription boundaries.
- IA remains exactly 起卦, 历史, 设置.
- Casting screen is direct and traditional in tone.
- Three-coin casting animation is calm, slow, and has a readable settle/reveal path.
- Result card and 卦意初读 are not covered by the bottom tab.
- Light and dark modes avoid black, heavy brown, cheap gold, and overdecorated symbols.
- Copy does not promise prediction, fate change, luck, or professional advice.
- XcodeBuildMCP build passes.
- Unit tests pass.
- Simulator smoke path passes: launch, cast once, inspect result, visit History, visit Settings.

Conclusion must be exactly one of:
- Blocked
- Pass but weak
- Merge candidate

Return evidence: head commit, commands run, screenshots or screenshot paths, failures, risks, and final conclusion.
```

## Copy-Ready `/goal` Prompt

```text
/goal 在 /Users/kartz/Development/YiYao 当前 iOS SwiftUI 项目中实施“一爻 PR1 UI refinement”。

先读取并遵守 AGENTS.md、PRODUCT_BRIEF.md、ROADMAP.md、docs/multi-agent-plan.md，以及 docs/product-design-audit/2026-06-17-pr1-ui/revision-plan/ui-revision-plan.md。若文档和当前用户方向冲突，以当前方向为准：首版只保留 起卦、历史、设置；不做卦库、学习页、手动画爻、AI、联网、订阅、内购、广告、账号、云同步、八字、风水、复杂六爻纳甲。所有文案必须克制，只定位为周易学习、反思与记录工具，不承诺精准预测、改命、开运或替代专业建议。

请使用这些技能/skill：superpowers:subagent-driven-development、design-taste-frontend、animate、colorize、polish、imagegen、build-ios-apps:ios-debugger-agent。可选使用 product-design:get-context；至少读取本地 Product Design audit。使用 multi_agent_v1 派发子 agent，但子 agent 写入范围必须互不冲突。使用 XcodeBuildMCP 优先完成构建、测试、截图和模拟器 smoke；第一次构建/测试前必须验证 session defaults。若 XcodeBuildMCP 某工具未暴露，先用 tool_search 查找。若 XcodeBuildMCP 不可用，再回退 xcodebuild。

目标切片：把当前 PR1 的起卦首屏、三枚铜钱六次抛落动画、结果卡、卦意初读、历史空状态、设置页做成安静、慢、雅、有中国传统美学气质的可交付 UI。不要扩大到真实 64 卦引擎和本地持久化。

多 agent 建议：
1. Orchestrator：读文档、建/继续 feature/pr1-ui-refinement 分支、检查 git status、拆分任务、整合、最终 commit/PR handoff。
2. Visual Surface Agent：只负责 Resources/Assets.xcassets 下 PaperPanelTexture/CoinHeads/CoinTails 可选素材，必要时新增很小的共享视觉文件。若 image_gen 无法落地文件，不阻塞，保留 SwiftUI 纹理方案并记录风险。
3. Casting UI + Animation Agent：只改 Features/Casting/CastingHomeView.swift。修复结果区被底部 Tab 遮挡；优化按钮为淡纸青/灰绿、压印高光、朱砂点；铜钱动画包含落下、落定、显爻，不做活泼弹跳；Reduce Motion 直接显示结果；结果卡是“纸中纸”，卦象条加颜色但不粗重。
4. Secondary UI Agent：只改 Features/History/HistoryView.swift、Features/Settings/SettingsView.swift、YiyaoApp/AppView.swift。统一纸感背景和灰青/朱砂色域，避免黑色、重褐、廉价金色；Tab tint 与背景融合。
5. Tests/Docs Agent：只改 Tests/YiYaoTests/AppShellTests.swift 和 docs/product-design-audit 下审计记录。把过时测试名从 five tabs 改为 three tabs；保留 IA 和文案边界测试；记录 after screenshots。
6. Validation Agent：独立验证最新 head commit，不能自动 merge，结论只能是 Blocked、Pass but weak、Merge candidate。

验收标准：
- App 首屏不显示“一爻”应用名作为主标题，只保留“ 一事在心 / 缓书其事，静观其变。 ”
- 输入文案为“可书一事，亦可默问。”，按钮为“三钱取卦 / 铜钱将落 / 再取一卦”。
- 点击后能看到三枚铜钱按六次成爻的庄重动画；动画慢、静、雅。
- 取卦完成后结果卡和“卦意初读”完整可读，不被底部 Tab 遮挡。
- 色彩和用户提供的宣纸水墨背景融合：纸白、灰青、黛青、少量朱砂；不要黑色大背景、深褐主色、金光、罗盘/龙纹/八卦大装饰。
- History 和 Settings 与主界面同一气质。
- VoiceOver 不朗读背景纹理；动爻不能只靠红色传达。
- 小屏不截断，深浅色不崩，Reduce Motion 有可用路径。

完成后运行：
- git diff --check
- XcodeBuildMCP build
- XcodeBuildMCP test
- XcodeBuildMCP 或模拟器 smoke：启动 App，完成一次取卦，查看结果，进入历史，进入设置，回到起卦
- 截取浅色和深色结果截图

最后 commit。若有 GitHub remote 且 gh 已登录，push 并创建/更新 draft PR；否则输出完整命令和 Validation Handoff。不要自动 merge。最终输出 PR 链接或创建 PR 命令、改动摘要、测试结果、截图路径、风险、Validation Agent 结论、下一建议 PR。
```
