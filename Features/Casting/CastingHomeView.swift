import SwiftUI

struct CastingHomeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    @State private var question = ""
    @State private var isCasting = false
    @State private var didPrepareCasting = false
    @State private var revealedLineCount = 0
    @State private var activeThrowIndex = 0
    @State private var coinSpinAngle = 0.0
    @State private var coinDropProgress = 1.0
    @State private var currentCoinFaces: [CoinFace] = [.heads, .tails, .heads]
    @State private var castingResult: CastingResult?

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: hasCompletedCasting ? 12 : 13) {
                        header
                        questionEditor
                        castButton
                        coinCeremonyStage
                        hexagramStage
                            .id(CastingScrollTarget.result)
                        if hasCompletedCasting {
                            analysisPanel
                                .id(CastingScrollTarget.analysis)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        if !hasCompletedCasting {
                            Spacer(minLength: 0)
                        }
                    }
                    .frame(width: max(0, geometry.size.width - 40), alignment: .top)
                    .frame(minHeight: max(geometry.size.height - 96, hasCompletedCasting ? 760 : 700), alignment: .top)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 26)
                }
                .scrollContentBackground(.hidden)
                .onChange(of: isCasting) { _, newValue in
                    guard !newValue, hasCompletedCasting else {
                        return
                    }
                    scrollToResult(in: scrollProxy)
                }
                .background(appBackground)
            }
        }
        .background(appBackground)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("一事在心")
                .font(.system(size: 32, weight: .semibold, design: .serif))
                .foregroundStyle(ink)

            Text("缓书其事，静观其变。")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    private var questionEditor: some View {
        TextField("可书一事，亦可默问。", text: $question, axis: .vertical)
            .lineLimit(3...5)
            .textFieldStyle(.plain)
            .font(.body)
            .tint(cinnabar)
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
            .accessibilityLabel("所书之事")
            .accessibilityHint("可书一事，亦可默问。")
            .accessibilityIdentifier("casting.question")
        .background {
            smallPanelFrameSurface
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .modifier(InputPanelChrome())
    }

    private var castButton: some View {
        Button {
            beginCasting()
        } label: {
            ZStack {
                castButtonSurface

                Text(isCasting ? "铜钱将落" : didPrepareCasting ? "再取一卦" : "三钱取卦")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(canCast ? actionText : .secondary)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .padding(.horizontal, 44)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!canCast)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: actionShadow, radius: 10, y: 4)
        .contentShape(Rectangle())
        .animation(.easeOut(duration: 0.16), value: canCast)
        .accessibilityLabel(isCasting ? "铜钱将落" : didPrepareCasting ? "再取一卦" : "三钱取卦")
        .accessibilityIdentifier("casting.castButton")
        .accessibilityHint("以三枚铜钱生成六爻。")
    }

    private var coinCeremonyStage: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(isCasting ? "三钱既陈" : hasCompletedCasting ? "三钱已落" : "三钱静候")
                    .font(.system(.headline, design: .serif))
                Spacer()
                Text(coinStageLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                ForEach(Array(currentCoinFaces.enumerated()), id: \.offset) { index, face in
                    CoinView(
                        face: face,
                        spinAngle: coinSpinAngle + Double(index * 34),
                        dropProgress: coinDropProgress,
                        horizontalJitter: coinJitter(for: index),
                        restingTilt: coinRestingTilt(for: index)
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 58)

            coinLandingLine

            Text(isCasting ? "缓落一回，成爻一位；六爻具，则卦象成。" : "三枚铜钱常驻于此，取卦后逐爻落定。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
    }

    private var hexagramStage: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("本卦")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(resultPrimaryText)

                    Text(hasCompletedCasting ? originalStructureText : "六爻待成")
                        .font(.caption)
                        .foregroundStyle(resultSecondaryText)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(YiyaoPalette.paperWash(colorScheme).opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 5) {
                    Text("变爻")
                        .font(.caption)
                        .foregroundStyle(resultSecondaryText)
                    HStack(spacing: 5) {
                        Text(movingLinesSummary)
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(resultPrimaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                        Circle()
                            .fill(cinnabar)
                            .frame(width: 7, height: 7)
                            .opacity(hasCompletedCasting && !castingMovingLineNumbers.isEmpty ? 0.9 : 0.24)
                    }
                }
            }

            HStack(alignment: .center, spacing: 12) {
                Spacer(minLength: 0)

                HexagramPreviewView(
                    lines: displayLines,
                    revealedLineCount: previewRevealedLineCount,
                    movingColor: cinnabar,
                    stableColor: hasCompletedCasting ? resultLineColor : resultLineColor.opacity(0.70),
                    isResultStyle: true
                )
                .frame(width: 176)
                .padding(.vertical, 4)
                .sensoryFeedback(.selection, trigger: revealedLineCount)

                Spacer(minLength: 2)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(displayLines.enumerated().reversed()), id: \.offset) { index, line in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(line.isChanging ? cinnabar : resultLineColor.opacity(0.24))
                                .frame(width: 5, height: 5)
                                .opacity(index < previewRevealedLineCount ? 1 : 0.24)
                            Text(linePositionName(for: index, line: line))
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(line.isChanging ? cinnabar : resultSecondaryText)
                        }
                        .opacity(index < previewRevealedLineCount ? 1 : 0.36)
                    }
                }
                .frame(width: 44, alignment: .leading)

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(hasCompletedCasting ? "卦象已成" : "卦象未起")
                    .font(.system(size: hasCompletedCasting ? 28 : 24, weight: .semibold, design: .serif))
                    .foregroundStyle(resultPrimaryText)
                Text(hasCompletedCasting ? resultTrigramSummary : "静候三钱落定，再观上下卦与动爻。")
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundStyle(resultSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .frame(minHeight: hasCompletedCasting ? 238 : 204)
        .background {
            oraclePanelFrameSurface
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .modifier(OrnatePanelChrome())
        .animation(.easeInOut(duration: 0.32), value: didPrepareCasting)
        .animation(.easeInOut(duration: 0.32), value: isCasting)
    }

    private var analysisPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("卦意初读")
                .font(.system(.headline, design: .serif))

            VStack(spacing: 12) {
                AnalysisRow(title: "本卦", value: originalStructureText)
                AnalysisRow(title: "动爻", value: movingLinesText)
                AnalysisRow(title: "变卦", value: changedStructureText)
            }

            ceremonialDivider
                .padding(.vertical, 2)

            Text("此处只作周易学习与自我反思的线索，不作确定判断。")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background {
            oraclePanelFrameSurface
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .modifier(OrnatePanelChrome())
    }

    private var canCast: Bool {
        !isCasting
    }

    private var hasCompletedCasting: Bool {
        didPrepareCasting && !isCasting
    }

    private var coinStageLabel: String {
        if isCasting {
            return lineName(for: activeThrowIndex)
        }
        return hasCompletedCasting ? "正反已定" : "未起卦"
    }

    private var pageBackground: Color {
        YiyaoPalette.paperBase(colorScheme)
    }

    private var appBackground: some View {
        ZStack {
            Image("PaperInkBackground")
                .resizable()
                .scaledToFill()
                .opacity(colorScheme == .dark ? 0.32 : 1)
                .accessibilityHidden(true)

            pageBackground
                .opacity(colorScheme == .dark ? 0.76 : 0.08)
        }
        .ignoresSafeArea()
    }

    private var panelBackground: Color {
        YiyaoPalette.panelBase(colorScheme)
    }

    private var panelSurface: some View {
        ZStack {
            panelBackground

            Image("PaperPanelTexture")
                .resizable()
                .scaledToFill()
                .opacity(colorScheme == .dark ? 0.12 : 0.26)
                .blendMode(colorScheme == .dark ? .softLight : .multiply)
                .accessibilityHidden(true)

            LinearGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.02 : 0.18),
                    Color.clear,
                    paperJade.opacity(colorScheme == .dark ? 0.05 : 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @ViewBuilder
    private var castButtonSurface: some View {
        if canCast {
            Image("CastingButtonFrame")
                .resizable(
                    capInsets: EdgeInsets(top: 17, leading: 56, bottom: 17, trailing: 74),
                    resizingMode: .stretch
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
        } else {
            Image("CastingButtonFrame")
                .resizable(
                    capInsets: EdgeInsets(top: 17, leading: 56, bottom: 17, trailing: 74),
                    resizingMode: .stretch
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .saturation(0.25)
                .opacity(0.62)
                .accessibilityHidden(true)
        }
    }

    private var ink: Color {
        YiyaoPalette.ink(colorScheme)
    }

    private var actionText: Color {
        YiyaoPalette.ink(colorScheme)
    }

    private var cinnabar: Color {
        YiyaoPalette.cinnabar(colorScheme)
    }

    private var paperJade: Color {
        YiyaoPalette.paperWash(colorScheme)
    }

    private var resultPrimaryText: Color {
        YiyaoPalette.ink(colorScheme)
    }

    private var resultSecondaryText: Color {
        resultPrimaryText.opacity(colorScheme == .dark ? 0.70 : 0.66)
    }

    private var resultLineColor: Color {
        YiyaoPalette.grayGreen(colorScheme)
    }

    private var actionShadow: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.18)
            : Color(red: 0.34, green: 0.35, blue: 0.28).opacity(0.08)
    }

    private var oraclePanelFrameSurface: some View {
        ZStack {
            panelSurface

            Image("PaperInkBackground")
                .resizable()
                .scaledToFill()
                .opacity(colorScheme == .dark ? 0.04 : 0.08)
                .blendMode(colorScheme == .dark ? .softLight : .multiply)
                .accessibilityHidden(true)
        }
    }

    private var smallPanelFrameSurface: some View {
        ZStack {
            panelSurface

            Image("OracleSmallPanelFrame")
                .resizable(
                    capInsets: EdgeInsets(top: 16, leading: 48, bottom: 16, trailing: 48),
                    resizingMode: .stretch
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
        }
    }

    private var ceremonialDivider: some View {
        Image("CeremonialDivider")
            .resizable(
                capInsets: EdgeInsets(top: 0, leading: 72, bottom: 0, trailing: 72),
                resizingMode: .stretch
            )
            .frame(height: 15)
            .opacity(0.86)
            .accessibilityHidden(true)
    }

    private var coinLandingLine: some View {
        ceremonialDivider
            .padding(.horizontal, 14)
    }

    private var displayLines: [LineValue] {
        castingResult?.originalLines ?? placeholderLines
    }

    private var previewRevealedLineCount: Int {
        didPrepareCasting ? revealedLineCount : displayLines.count
    }

    private var castingMovingLineNumbers: [Int] {
        castingResult?.movingLineNumbers ?? []
    }

    private var placeholderLines: [LineValue] {
        [.youngYang, .youngYin, .youngYang, .youngYin, .youngYang, .youngYin]
    }

    private var coinThrows: [CoinThrow] {
        castingResult?.coinThrows ?? []
    }

    private var resultTrigramSummary: String {
        guard let castingResult else {
            return "上下卦待成"
        }
        return "上\(castingResult.upperTrigram.name)下\(castingResult.lowerTrigram.name)，\(castingResult.upperTrigram.imageName)\(castingResult.lowerTrigram.imageName)相承"
    }

    private var originalStructureText: String {
        guard let castingResult else {
            return "待起"
        }
        return "上\(castingResult.upperTrigram.name)下\(castingResult.lowerTrigram.name)"
    }

    private var changedStructureText: String {
        guard let castingResult else {
            return "待起"
        }
        guard !castingResult.movingLineNumbers.isEmpty else {
            return "无动爻，与本卦同"
        }
        return "上\(castingResult.changedUpperTrigram.name)下\(castingResult.changedLowerTrigram.name)"
    }

    private var movingLinesText: String {
        guard let castingResult else {
            return "待起"
        }
        let movingLineNumbers = castingResult.movingLineNumbers
        guard !movingLineNumbers.isEmpty else {
            return "无动爻，先观本卦"
        }
        return movingLineNumbers.map { lineName(for: $0 - 1) }.joined(separator: "、") + "为动"
    }

    private var movingLinesSummary: String {
        guard hasCompletedCasting else {
            return "待定"
        }
        let movingLineNumbers = castingMovingLineNumbers
        guard !movingLineNumbers.isEmpty else {
            return "无"
        }
        return movingLineNumbers
            .map { linePositionName(for: $0 - 1, line: displayLines[$0 - 1]) }
            .joined(separator: "、")
    }

    private func coinJitter(for index: Int) -> CGFloat {
        [-22, 4, 18][index]
    }

    private func coinRestingTilt(for index: Int) -> Double {
        [-8, 5, -3][index]
    }

    private func lineName(for index: Int) -> String {
        let names = ["初爻", "二爻", "三爻", "四爻", "五爻", "上爻"]
        return names[min(max(index, 0), names.count - 1)]
    }

    private func linePositionName(for index: Int, line: LineValue) -> String {
        let positions = ["初", "二", "三", "四", "五", "上"]
        let safeIndex = min(max(index, 0), positions.count - 1)
        let polarity = line.isYang ? "九" : "六"

        if safeIndex == 0 || safeIndex == positions.count - 1 {
            return "\(positions[safeIndex])\(polarity)"
        }

        return "\(polarity)\(positions[safeIndex])"
    }

    @MainActor
    private func beginCasting() {
        guard !isCasting else {
            return
        }

        let result = CastingEngine().cast()
        castingResult = result
        didPrepareCasting = true
        isCasting = true
        activeThrowIndex = 0
        revealedLineCount = reduceMotion ? result.originalLines.count : 0
        currentCoinFaces = [.heads, .tails, .heads]
        coinDropProgress = 1

        guard !reduceMotion else {
            isCasting = false
            return
        }

        Task {
            await runCastingAnimation()
        }
    }

    private func runCastingAnimation() async {
        let throwSnapshot = await MainActor.run {
            self.coinThrows
        }

        for index in throwSnapshot.indices {
            await MainActor.run {
                activeThrowIndex = index
                currentCoinFaces = [.heads, .tails, .heads]
                coinDropProgress = 0
            }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.78)) {
                    coinDropProgress = 1
                }
            }

            for spin in 0..<3 {
                try? await Task.sleep(nanoseconds: 190_000_000)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        coinSpinAngle += 180
                        currentCoinFaces = spin.isMultiple(of: 2)
                        ? [.tails, .heads, .tails]
                        : [.heads, .tails, .heads]
                    }
                }
            }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.34)) {
                    currentCoinFaces = throwSnapshot[index].faces
                    coinSpinAngle += 90
                }
            }

            try? await Task.sleep(nanoseconds: 520_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.52)) {
                    revealedLineCount = index + 1
                }
            }

            try? await Task.sleep(nanoseconds: 360_000_000)
        }

        await MainActor.run {
            isCasting = false
        }
    }

    private func scrollToResult(in proxy: ScrollViewProxy) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: reduceMotion ? 80_000_000 : 180_000_000)
            withAnimation(.easeInOut(duration: reduceMotion ? 0.01 : 0.48)) {
                proxy.scrollTo(CastingScrollTarget.result, anchor: .top)
            }
        }
    }
}

private enum CastingScrollTarget {
    static let result = "casting.result"
    static let analysis = "casting.analysis"
}

private struct InputPanelChrome: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(YiyaoPalette.grayGreen(colorScheme).opacity(0.18), lineWidth: 1)
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(YiyaoPalette.grayGreen(colorScheme).opacity(0.32))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.top, 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(YiyaoPalette.grayGreen(colorScheme).opacity(0.24))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 1)
            }
    }
}

private struct OrnatePanelChrome: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(YiyaoPalette.grayGreen(colorScheme).opacity(0.20), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                PanelCorner()
                    .padding(7)
            }
            .overlay(alignment: .topTrailing) {
                PanelCorner()
                    .scaleEffect(x: -1)
                    .padding(7)
            }
            .overlay(alignment: .bottomLeading) {
                PanelCorner()
                    .scaleEffect(y: -1)
                    .padding(7)
            }
            .overlay(alignment: .bottomTrailing) {
                PanelCorner()
                    .scaleEffect(x: -1, y: -1)
                    .padding(7)
            }
    }
}

private struct PanelDivider: View {
    let opacity: Double

    var body: some View {
        GeometryReader { proxy in
            Image("CeremonialDivider")
                .resizable(
                    capInsets: EdgeInsets(top: 0, leading: 72, bottom: 0, trailing: 72),
                    resizingMode: .stretch
                )
                .frame(width: proxy.size.width, height: 8)
                .accessibilityHidden(true)
        }
        .frame(height: 8)
        .opacity(opacity)
    }
}

private struct PanelCorner: View {
    var body: some View {
        Image("PanelCornerAccent")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .opacity(0.42)
            .accessibilityHidden(true)
    }
}

private struct CoinView: View {
    @Environment(\.colorScheme) private var colorScheme

    let face: CoinFace
    let spinAngle: Double
    let dropProgress: Double
    let horizontalJitter: CGFloat
    let restingTilt: Double

    var body: some View {
        ZStack {
            Image(faceImageName)
                .resizable()
                .scaledToFit()
                .opacity(1 - edgePresence)
                .rotation3DEffect(.degrees(spinAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.72)

            Image("CoinEdge")
                .resizable()
                .scaledToFit()
                .opacity(edgePresence)
        }
        .frame(width: 66, height: 66)
        .rotationEffect(.degrees(restingRotation))
        .saturation(0.92)
        .brightness(0.0)
        .offset(
            x: horizontalJitter * (1 - dropProgress),
            y: -68 * (1 - dropProgress)
        )
        .scaleEffect(0.82 + 0.18 * dropProgress)
        .opacity(0.18 + 0.82 * dropProgress)
        .blur(radius: 1.2 * (1 - dropProgress))
        .shadow(color: coinShadow, radius: 8, y: 4)
        .accessibilityLabel(face == .heads ? "铜钱正面" : "铜钱背面")
    }

    private var faceImageName: String {
        guard dropProgress > 0.96, edgePresence < 0.18 else {
            return face == .heads ? "CoinFront" : "CoinBack"
        }

        return face == .heads ? "CoinFrontOblique" : "CoinBackOblique"
    }

    private var normalizedSpin: Double {
        let value = spinAngle.truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }

    private var edgePresence: Double {
        let distanceToSide = min(
            abs(normalizedSpin - 90),
            abs(normalizedSpin - 270)
        )
        return max(0, min(1, 1 - distanceToSide / 34))
    }

    private var restingRotation: Double {
        guard dropProgress > 0.96 else {
            return 0
        }
        return restingTilt
    }

    private var coinShadow: Color {
        Color(red: 0.31, green: 0.25, blue: 0.16).opacity(0.12)
    }
}

private struct HexagramPreviewView: View {
    let lines: [LineValue]
    let revealedLineCount: Int
    let movingColor: Color
    let stableColor: Color
    let isResultStyle: Bool

    var body: some View {
        VStack(spacing: isResultStyle ? 13 : 11) {
            ForEach(Array(lines.enumerated().reversed()), id: \.offset) { index, line in
                HexagramLineView(
                    line: line,
                    movingColor: movingColor,
                    stableColor: stableColor,
                    isResultStyle: isResultStyle
                )
                    .opacity(index < revealedLineCount ? 1 : (isResultStyle ? 0 : 0.18))
                    .scaleEffect(index < revealedLineCount ? 1 : 0.96)
                    .accessibilityLabel(line.title)
            }
        }
        .frame(maxWidth: isResultStyle ? 230 : 250)
        .padding(.horizontal, isResultStyle ? 0 : 12)
    }
}

private struct HexagramLineView: View {
    let line: LineValue
    let movingColor: Color
    let stableColor: Color
    let isResultStyle: Bool

    var body: some View {
        Group {
            if line.isYang {
                Capsule()
            } else {
                HStack(spacing: 18) {
                    Capsule()
                    Capsule()
                }
            }
        }
        .frame(height: isResultStyle ? 10 : 9)
        .foregroundStyle(lineColor)
    }

    private var lineColor: Color {
        if line.isChanging {
            return movingColor
        }
        return isResultStyle ? stableColor : Color.primary
    }
}

private struct AnalysisRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .serif))
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        CastingHomeView()
            .navigationTitle("一事在心")
    }
}
