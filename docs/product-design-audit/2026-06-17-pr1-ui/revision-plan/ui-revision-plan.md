# 一爻 UI 修改方案 - Product Design Audit

日期：2026-06-17

## 审计范围

- 首屏：`01-current-home.jpg`
- 取卦结果态：`02-current-result.jpg`
- 暗色结果态：`03-current-dark-result.jpg`

目标：保持免费、离线、克制的周易学习与记录定位；视觉气质应为静、慢、雅，有中国传统审美，但不能显得玄学营销或沉重。

## 现状判断

当前版本已经比黑褐方案更接近方向：宣纸背景、淡青灰按钮、黛青文字和少量朱砂形成了统一色域。主要问题不是颜色大方向，而是材质层次、完成态信息和底部空间。

## Strengths

- 首屏简单直接：用户进入后只需要默问或写一事，再点击“三钱取卦”。
- 色彩已经从黑褐转向宣纸白、灰青、黛青、朱砂，和背景更融合。
- 文案语气比“问什么/分析/计算”更克制，符合传统文化工具定位。
- 卦象横条比例比早期大黑卡更雅，动爻有明确但不过多的朱砂强调。

## UX 风险

1. 结果态信息还像“预览卡”，不像完整结果页。
   - `02-current-result.jpg` 中，卦名与上下卦说明较好，但“卦意初读”被底部 Tab 遮挡，用户难以自然继续阅读。

2. 按钮可点状态略弱。
   - `01-current-home.jpg` 中按钮和背景融合后更雅，但触摸 affordance 下降，缺少“取卦是一件正式动作”的仪式感。

3. 起卦动画容器与结果容器风格还没有完全统一。
   - 当前按钮、铜钱、卦卡各自成立，但缺少一个共同的“案面/纸席”隐喻。

4. 深色模式气质偏沉。
   - `03-current-dark-result.jpg` 比黑褐版好，但仍偏“夜间工具”，传统雅感不足；应改成深黛青宣纸，而不是暗绿色面板。

## Accessibility 风险

- 结果区和底部 Tab 视觉重叠，需要增加底部安全留白或让结果页自动滚到卦卡顶部。
- 动爻只依赖朱砂红强调，后续需要补“动爻”文字或形态提示，避免只靠颜色识别。
- 三钱动画较慢，需要继续支持 Reduce Motion；当前已考虑，但后续素材动画也必须保留静态路径。

## 修改方案

### P0 必须改

1. 结果页底部空间
   - 将结果态 `analysisPanel` 与底部 Tab 的距离加大。
   - 取卦完成后可轻微自动滚动，让卦卡和“卦意初读”都进入可读区域。

2. 按钮融合但更可点
   - 保留淡青灰底，不回到黑色。
   - 加一层很淡的内阴影和上沿高光，让按钮像纸面压印。
   - 朱砂点改成更像印泥落点，可略小但更饱满。

3. 结果卡“纸中纸”
   - 结果卡底色不要再加深，改成比背景略冷、略浓的宣纸层。
   - 边线用浅灰青，不用黑线、白线。
   - 卡内卦名与卦象之间增加留白，强调完成态。

### P1 建议改

1. 生成一张专用 UI 纸纹素材
   - 用途：输入框、按钮、卦卡、分析区的统一 overlay。
   - 需要比当前背景更细，不能有大面积水墨边角，避免每个组件都像重复背景。
   - 建议资产名：`PaperPanelTexture`

2. 生成三枚铜钱贴图
   - 用途：替换纯 SwiftUI 圆形铜钱，提升抛落动画真实感。
   - 要求：俯视角、无阴影或极弱阴影、统一材质、正反两面各一张。
   - 可先不做透明原生图，用纯色背景生成后本地抠图。

3. 增加“落定”微动效
   - 铜钱落下后轻微停顿，不做弹跳。
   - 每一爻显现时从淡到实，动爻带一次极轻朱砂晕开。

4. 结果分析排版
   - 用三段式：`卦象`、`动爻`、`可记之处`。
   - 每段不超过两行，避免玄学承诺。
   - 结果页后续应支持保存历史入口，但当前 UI 可先占位。

### P2 暂不改

- 不做大面积黑底、褐底、金色边框。
- 不做复杂卷轴、龙纹、八卦图大装饰。
- 不把输入框和按钮整体做成图片；保留 SwiftUI 原生控件，素材只做纹理层。
- 不把主界面做成完整“卦库/学习”入口；当前三入口足够。

## Codex/ImageGen 素材建议

### 素材 1：PaperPanelTexture

用途：控件和卡片统一底纹。

Prompt 方向：

```text
Create a subtle traditional Chinese xuan paper UI panel texture for an iOS app.
Warm ivory handmade paper, fine fibers, faint grey-green ink wash, extremely subtle cinnabar dust,
no readable text, no symbols, no coins, no hexagrams, no border, no strong corner decoration.
Low contrast, seamless-feeling, suitable as a low-opacity overlay behind text.
```

### 素材 2：CoinHeads / CoinTails

用途：三钱动画。

Prompt 方向：

```text
Create a top-down ancient Chinese bronze coin for an iOS casting animation.
Single coin centered, circular coin with square hole, refined aged bronze, quiet museum-object lighting,
flat removable chroma-key background, no text, no watermark, no cast shadow.
```

### 素材 3：CinnabarReveal

用途：动爻显现时极淡朱砂晕。

Prompt 方向：

```text
Create a soft cinnabar mineral pigment bloom on xuan paper, very subtle, no symbols, no text,
transparent-ready composition on flat removable background, suitable for a tiny UI animation overlay.
```

## 实施顺序

1. 先修布局：结果态底部遮挡、完成后滚动位置、分析区间距。
2. 再修色彩 token：按钮、结果卡、暗色模式统一到宣纸/灰青色域。
3. 再生成 `PaperPanelTexture` 并替换组件 overlay。
4. 最后生成铜钱贴图并替换当前 SwiftUI 铜钱绘制。

## 验证

- iPhone 小屏首屏不截断。
- 取卦后结果卡和“卦意初读”不被底部 Tab 遮挡。
- 暗色模式不变成黑绿重色块。
- Reduce Motion 下能直接显示结果。
- VoiceOver 不朗读背景纹理素材。
