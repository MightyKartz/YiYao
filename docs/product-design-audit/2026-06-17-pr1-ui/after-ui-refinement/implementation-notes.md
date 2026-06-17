# PR1 UI Refinement Evidence

日期：2026-06-17

## 改动结论

- 首屏继续保持直接入口：`一事在心`、`缓书其事，静观其变。`、`可书一事，亦可默问。`
- 起卦按钮保留淡纸青底、黛青文字和朱砂点，加入压印式边线、轻微按压反馈。
- 三钱动画保留 SwiftUI 铜钱，不引入拟真铜钱贴图，避免道具感。
- 成卦前只显示生成过程和逐步显爻；六爻完成后才展示卦名、上下卦说明和 `卦意初读`。
- 结果态把 `再取一卦` 移到分析后方，避免顶部露出被裁切控件。
- 历史、设置统一到纸白、灰青、黛青、少量朱砂的色域。

## 素材

- 新增 `PaperPanelTexture`，由现有 `PaperInkBackground` 中心区域裁切生成。
- `PaperInkBackground` 继续作为整屏宣纸水墨背景。
- `PaperPanelTexture` 只作为控件和卡片的低透明纹理层。
- 未新增 `CoinHeads` / `CoinTails`，原因是 PR1 中 SwiftUI 铜钱更克制、可控。

## 截图证据

- 浅色结果态：`docs/product-design-audit/2026-06-17-pr1-ui/after-ui-refinement/01-light-result.jpg`
- 深色结果态：`docs/product-design-audit/2026-06-17-pr1-ui/after-ui-refinement/02-dark-result.jpg`

## 验证说明

- XcodeBuildMCP `build_run_sim` 可构建并启动 App。
- XcodeBuildMCP `tap` 可正常切换 Tab。
- `casting.castButton` 可被 runtime snapshot 识别，但 XcodeBuildMCP element `tap` 未触发该自定义触摸区；同一模拟器中使用系统级点击可触发真实取卦路径。
- XcodeBuildMCP `test_sim` 两次超过工具等待上限；fallback 使用 `xcodebuild -only-testing:YiYaoTests test` 在 iPhone 17 模拟器通过，3 个测试全部通过。
- `simctl ui` 当前只暴露 appearance、increase_contrast、content_size，未暴露 Reduce Motion 开关；Reduce Motion 通过 `@Environment(\.accessibilityReduceMotion)` 代码路径覆盖。
