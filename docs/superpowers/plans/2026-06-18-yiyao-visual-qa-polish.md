# YiYao Visual QA Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the remaining visual QA issues on the YiYao casting screen after PR #5: cramped result card, button dot alignment, noisy wash overlays, coin visual mismatch, heavy top background, and slightly awkward result scroll position.

**Architecture:** Keep the polish in the casting surface instead of introducing shared theme churn. The SwiftUI layout remains data-driven and accessible; decorative raster assets are still used only for paper frames, wash textures, and coins. If asset cropping proves necessary, only touch the specific coin assets.

**Tech Stack:** SwiftUI, local `.xcassets`, XcodeBuildMCP simulator build/test/screenshot, `xcodebuild`/`devicectl` for iPhone 16 Plus install.

---

### Task 1: Protect Branch State And Baseline Evidence

**Files:**
- Modify: none.
- Read: `Features/Casting/CastingHomeView.swift`
- Output screenshots: `/tmp/yiyao-visual-qa-polish/before-initial.jpg`, `/tmp/yiyao-visual-qa-polish/before-result.jpg`

- [ ] **Step 1: Create the feature branch without touching local signing changes**

Run:

```bash
git status --short --branch
git switch -c codex/yiyao-visual-qa-polish
```

Expected:

```text
## codex/yiyao-visual-qa-polish
 M YiYao.xcodeproj/project.pbxproj
 M YiYao.xcodeproj/xcshareddata/xcschemes/YiYao.xcscheme
```

- [ ] **Step 2: Keep the known dirty signing files unstaged**

Run:

```bash
git diff --name-only
```

Expected: the Xcode project/scheme may remain dirty, but implementation commits must not stage them.

### Task 2: Result Card Layout Breathing Room

**Files:**
- Modify: `Features/Casting/CastingHomeView.swift`

- [ ] **Step 1: Increase completed hexagram card height and tighten internal content**

Change the result card sizing in `hexagramStage` from:

```swift
.frame(height: hasCompletedCasting ? 266 : 226, alignment: .topLeading)
```

to:

```swift
.frame(height: hasCompletedCasting ? 286 : 226, alignment: .topLeading)
```

Change the bottom padding from:

```swift
.padding(.bottom, 18)
```

to:

```swift
.padding(.bottom, hasCompletedCasting ? 22 : 18)
```

- [ ] **Step 2: Keep the result summary clear of the card border**

Change the completed summary block spacing from:

```swift
VStack(alignment: .leading, spacing: 6) {
```

to:

```swift
VStack(alignment: .leading, spacing: 5) {
```

and use a slightly smaller title:

```swift
.font(OracleTypeface.title(26))
```

Expected screenshot outcome: “卦象已成” and `resultTrigramSummary` sit comfortably above the lower frame ornament with no visual clipping.

### Task 3: Button Dot Alignment

**Files:**
- Modify: `Features/Casting/CastingHomeView.swift`

- [ ] **Step 1: Replace the independent trailing overlay with a text+dot row**

Inside `castButton`, replace the current `Text(...)` and trailing `Image("CastingButtonDot")` siblings with:

```swift
HStack(spacing: 9) {
    Text(isCasting ? "铜钱将落" : didPrepareCasting ? "再取一卦" : "三钱取卦")
        .font(OracleTypeface.headline(19))
        .foregroundStyle(canCast ? actionText : .secondary)

    Image("CastingButtonDot")
        .resizable()
        .scaledToFit()
        .frame(width: 11, height: 11)
        .opacity(canCast ? 1 : 0.42)
        .accessibilityHidden(true)
}
.frame(maxWidth: .infinity, minHeight: 50)
.padding(.horizontal, 44)
```

Expected screenshot outcome: the cinnabar dot reads as a punctuation-like seal after the button label, not as a far-right decorative marker.

### Task 4: Wash Overlay Noise Reduction

**Files:**
- Modify: `Features/Casting/CastingHomeView.swift`

- [ ] **Step 1: Lower top background wash strength**

In `appBackground`, change:

```swift
.opacity(0.26)
```

to:

```swift
.opacity(0.18)
```

for `PaperInkBackground`, and change:

```swift
.opacity(0.92)
```

to:

```swift
.opacity(0.82)
```

for `OraclePageWash`.

- [ ] **Step 2: Move the analysis wash behind the lower-right corner and reduce opacity**

In `analysisPanelFrameSurface`, change:

```swift
.frame(width: 206)
.opacity(0.58)
.padding(.trailing, 6)
.padding(.bottom, 8)
```

to:

```swift
.frame(width: 188)
.opacity(0.36)
.padding(.trailing, 2)
.padding(.bottom, 4)
```

- [ ] **Step 3: Add a light text-side scrim for the right-side line labels**

In `hexagramStage`, add a subtle background to the right-side line label `VStack`:

```swift
.padding(.vertical, 4)
.padding(.horizontal, 5)
.background(Color.white.opacity(0.22))
.clipShape(RoundedRectangle(cornerRadius: 6))
```

Expected screenshot outcome: the line labels and analysis values remain legible without fighting the bamboo/mountain wash.

### Task 5: Coin Visual Consistency

**Files:**
- Modify: `Features/Casting/CastingHomeView.swift`

- [ ] **Step 1: Normalize coin display sizing by face**

Add a local computed size in `CoinView`:

```swift
private var coinDiameter: CGFloat {
    face == .heads ? 66 : 68
}
```

and change:

```swift
.frame(width: 68, height: 68)
```

to:

```swift
.frame(width: coinDiameter, height: coinDiameter)
```

- [ ] **Step 2: Use flatter settled rotations**

Change:

```swift
private func coinRestingTilt(for index: Int) -> Double {
    [-8, 5, -3][index]
}
```

to:

```swift
private func coinRestingTilt(for index: Int) -> Double {
    [-3, 2, -2][index]
}
```

Expected screenshot outcome: all three coins look intentionally flat and similarly weighted.

### Task 6: Result Scroll Position

**Files:**
- Modify: `Features/Casting/CastingHomeView.swift`

- [ ] **Step 1: Slightly reduce bottom spacer height**

Change:

```swift
.frame(height: 112)
```

to:

```swift
.frame(height: 92)
```

Expected screenshot outcome: the completed result still shows the full analysis note, while the top of the result state no longer feels jammed under the Dynamic Island.

### Task 7: Verification

**Files:**
- Modify: none.

- [ ] **Step 1: Format the touched Swift file**

Run:

```bash
xcrun swift-format format -i --configuration '{"version":1,"indentation":{"spaces":4}}' Features/Casting/CastingHomeView.swift
```

Expected: command exits 0.

- [ ] **Step 2: Build and test on simulator with XcodeBuildMCP**

Run with XcodeBuildMCP:

```text
session_show_defaults
build_run_sim
test_sim
```

Expected:

```text
build_run_sim: SUCCEEDED
test_sim: 11 passed, 0 failed
```

- [ ] **Step 3: Capture current screenshots**

Capture:

```text
/tmp/yiyao-visual-qa-polish/after-initial.jpg
/tmp/yiyao-visual-qa-polish/after-result.jpg
```

Manual acceptance checks:
- Input, hexagram, and analysis frames remain consistent.
- Button dot is round and visually attached to the label.
- Top wash no longer competes with the title.
- Coins are fully visible and visually similar in diameter.
- Result summary is not crowded by the lower border.
- Analysis disclaimer is fully visible above bottom nav.

- [ ] **Step 4: Install on iPhone 16 Plus if available**

Run:

```bash
xcodebuild -project YiYao.xcodeproj -scheme YiYao -configuration Debug -destination 'platform=iOS,id=00008140-000835003EEB001C' -derivedDataPath /tmp/YiYaoDeviceDerivedData build
xcrun devicectl device install app --device 686C4C3D-2992-5906-9B3C-DDBE23512D4F /tmp/YiYaoDeviceDerivedData/Build/Products/Debug-iphoneos/YiYao.app
xcrun devicectl device process launch --device 686C4C3D-2992-5906-9B3C-DDBE23512D4F com.kartz.yiyao
```

Expected: build succeeds, install succeeds, app launches.

### Task 8: Commit And Draft PR

**Files:**
- Stage: `Features/Casting/CastingHomeView.swift`
- Do not stage: `YiYao.xcodeproj/project.pbxproj`, `YiYao.xcodeproj/xcshareddata/xcschemes/YiYao.xcscheme`

- [ ] **Step 1: Stage only the UI file**

Run:

```bash
git add Features/Casting/CastingHomeView.swift
git status --short
```

Expected staged file:

```text
M  Features/Casting/CastingHomeView.swift
```

- [ ] **Step 2: Commit and push**

Run:

```bash
git commit -m "Polish casting visual QA issues"
git push -u origin codex/yiyao-visual-qa-polish
```

- [ ] **Step 3: Create draft PR**

Run:

```bash
gh pr create --draft --base main --head codex/yiyao-visual-qa-polish --title "Polish casting visual QA issues" --body "<summary and verification>"
```

Expected: a draft PR URL.

---

## Self-Review

- Spec coverage: covers all six observed visual issues: result card crowding, button dot placement, texture noise, coin mismatch, top background weight, and result scroll position.
- Placeholder scan: no TBD/TODO placeholders.
- Type consistency: all referenced Swift names exist in `CastingHomeView.swift`, except `coinDiameter`, which Task 5 introduces inside `CoinView` before use.
