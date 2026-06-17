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
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: hasCompletedCasting ? 16 : 18) {
                    header
                    questionEditor
                    if !hasCompletedCasting {
                        castButton
                    }
                    if isCasting {
                        coinTossStage
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    hexagramStage
                        .id(CastingScrollTarget.result)
                    if hasCompletedCasting {
                        analysisPanel
                            .id(CastingScrollTarget.analysis)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        castButton
                            .padding(.top, 2)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, hasCompletedCasting ? 22 : 28)
                .padding(.bottom, hasCompletedCasting ? 280 : 112)
            }
            .onChange(of: isCasting) { _, newValue in
                guard !newValue, hasCompletedCasting else {
                    return
                }
                scrollToResult(in: scrollProxy)
            }
            .background(appBackground)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("一事在心")
                .font(.system(size: 36, weight: .semibold, design: .serif))
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
            .padding(14)
            .frame(minHeight: 108, alignment: .topLeading)
            .accessibilityLabel("所书之事")
            .accessibilityHint("可书一事，亦可默问。")
            .accessibilityIdentifier("casting.question")
        .background {
            panelSurface
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(panelBorder)
        }
    }

    private var castButton: some View {
        Button {
            beginCasting()
        } label: {
            ZStack {
                Rectangle()
                    .fill(Color.clear)

                HStack(spacing: 12) {
                    Text(isCasting ? "铜钱将落" : didPrepareCasting ? "再取一卦" : "三钱取卦")
                        .font(.system(.headline, design: .serif))

                    Circle()
                        .fill(cinnabar.opacity(canCast ? 0.92 : 0.35))
                        .frame(width: 7, height: 7)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background {
            castButtonSurface
        }
        .foregroundStyle(canCast ? actionText : .secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(actionBorder)
        }
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.34), lineWidth: 1)
                .blendMode(.softLight)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(actionText.opacity(colorScheme == .dark ? 0.08 : 0.10))
                .frame(height: 1)
                .padding(.horizontal, 10)
                .opacity(canCast ? 1 : 0)
        }
        .shadow(color: actionShadow, radius: 12, y: 5)
        .buttonStyle(.plain)
        .disabled(!canCast)
        .animation(.easeOut(duration: 0.16), value: canCast)
        .accessibilityLabel(isCasting ? "铜钱将落" : didPrepareCasting ? "再取一卦" : "三钱取卦")
        .accessibilityIdentifier("casting.castButton")
        .accessibilityAction {
            beginCasting()
        }
        .accessibilityHint("以三枚铜钱生成六爻。")
    }

    private var coinTossStage: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("三钱既陈")
                    .font(.system(.headline, design: .serif))
                Spacer()
                Text(lineName(for: activeThrowIndex))
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
                        cinnabar: cinnabar
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)

            Text("缓落一回，成爻一位；六爻具，则卦象成。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background {
            panelSurface
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(cinnabar.opacity(colorScheme == .dark ? 0.30 : 0.22))
        }
    }

    private var hexagramStage: some View {
        VStack(spacing: hasCompletedCasting ? 24 : 18) {
            HStack(alignment: .firstTextBaseline) {
                Text("卦象")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(hasCompletedCasting ? resultPrimaryText : Color.primary)
                Spacer()
                Text(stageLabel)
                    .font(.caption)
                    .foregroundStyle(hasCompletedCasting ? resultSecondaryText : .secondary)
            }

            HexagramPreviewView(
                lines: displayLines,
                revealedLineCount: revealedLineCount,
                movingColor: cinnabar,
                stableColor: hasCompletedCasting ? resultLineColor : Color.primary,
                isResultStyle: hasCompletedCasting
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, hasCompletedCasting ? 8 : 10)
            .sensoryFeedback(.selection, trigger: revealedLineCount)

            if hasCompletedCasting {
                VStack(spacing: 8) {
                    Text("卦象已成")
                        .font(.system(size: 36, weight: .semibold, design: .serif))
                        .foregroundStyle(resultPrimaryText)
                    Text(resultTrigramSummary)
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundStyle(resultSecondaryText)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(hasCompletedCasting ? 28 : 16)
        .background {
            if hasCompletedCasting {
                resultSurface
            } else {
                panelSurface
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(didPrepareCasting ? resultBorder : panelBorder)
        }
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

            Divider()

            Text("此处只作周易学习与自我反思的线索，不作确定判断。")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background {
            panelSurface
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(panelBorder)
        }
    }

    private var canCast: Bool {
        !isCasting
    }

    private var hasCompletedCasting: Bool {
        didPrepareCasting && !isCasting
    }

    private var stageLabel: String {
        if isCasting {
            return lineName(for: activeThrowIndex)
        }
        return hasCompletedCasting ? "卦成" : "待起"
    }

    private var pageBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.12, green: 0.155, blue: 0.14)
            : Color(red: 0.965, green: 0.946, blue: 0.90)
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
        colorScheme == .dark
            ? Color(red: 0.16, green: 0.20, blue: 0.175)
            : Color(red: 0.995, green: 0.982, blue: 0.94)
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
            ZStack {
                actionSurfaceBase

                Image("PaperPanelTexture")
                    .resizable()
                    .scaledToFill()
                    .opacity(colorScheme == .dark ? 0.14 : 0.22)
                    .blendMode(.softLight)
                    .accessibilityHidden(true)

                LinearGradient(
                    colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.08 : 0.24),
                        Color.clear,
                        paperJade.opacity(colorScheme == .dark ? 0.12 : 0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        } else {
            Color.secondary.opacity(0.18)
        }
    }

    private var panelBorder: Color {
        colorScheme == .dark
            ? Color(red: 0.76, green: 0.84, blue: 0.76).opacity(0.12)
            : Color(red: 0.38, green: 0.45, blue: 0.37).opacity(0.16)
    }

    private var ink: Color {
        colorScheme == .dark
            ? Color(red: 0.88, green: 0.86, blue: 0.80)
            : Color(red: 0.16, green: 0.22, blue: 0.19)
    }

    private var actionText: Color {
        colorScheme == .dark
            ? Color(red: 0.90, green: 0.94, blue: 0.88)
            : Color(red: 0.14, green: 0.24, blue: 0.21)
    }

    private var cinnabar: Color {
        Color(red: 0.56, green: 0.14, blue: 0.10)
    }

    private var paperJade: Color {
        colorScheme == .dark
            ? Color(red: 0.34, green: 0.47, blue: 0.39)
            : Color(red: 0.70, green: 0.76, blue: 0.65)
    }

    private var resultCardBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.18, green: 0.23, blue: 0.20).opacity(0.94)
            : Color(red: 0.958, green: 0.958, blue: 0.902).opacity(0.98)
    }

    private var actionSurfaceBase: Color {
        colorScheme == .dark
            ? Color(red: 0.24, green: 0.32, blue: 0.28)
            : Color(red: 0.90, green: 0.91, blue: 0.84)
    }

    private var resultPrimaryText: Color {
        colorScheme == .dark
            ? Color(red: 0.91, green: 0.95, blue: 0.88)
            : Color(red: 0.15, green: 0.25, blue: 0.21)
    }

    private var resultSecondaryText: Color {
        resultPrimaryText.opacity(colorScheme == .dark ? 0.70 : 0.66)
    }

    private var resultLineColor: Color {
        colorScheme == .dark
            ? Color(red: 0.91, green: 0.95, blue: 0.88)
            : Color(red: 0.28, green: 0.38, blue: 0.33)
    }

    private var resultBorder: Color {
        colorScheme == .dark
            ? Color(red: 0.70, green: 0.82, blue: 0.72).opacity(0.20)
            : Color(red: 0.42, green: 0.50, blue: 0.40).opacity(0.18)
    }

    private var actionBorder: Color {
        colorScheme == .dark
            ? Color(red: 0.78, green: 0.86, blue: 0.76).opacity(0.16)
            : Color(red: 0.42, green: 0.50, blue: 0.40).opacity(0.18)
    }

    private var actionShadow: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.18)
            : Color(red: 0.34, green: 0.35, blue: 0.28).opacity(0.08)
    }

    private var resultSurface: some View {
        ZStack {
            resultCardBackground

            Image("PaperPanelTexture")
                .resizable()
                .scaledToFill()
                .opacity(colorScheme == .dark ? 0.10 : 0.28)
                .blendMode(colorScheme == .dark ? .softLight : .multiply)
                .accessibilityHidden(true)

            RadialGradient(
                colors: [
                    paperJade.opacity(colorScheme == .dark ? 0.18 : 0.16),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 12,
                endRadius: 260
            )
        }
    }

    private var displayLines: [LineValue] {
        castingResult?.originalLines ?? placeholderLines
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

    private func coinJitter(for index: Int) -> CGFloat {
        [-22, 4, 18][index]
    }

    private func lineName(for index: Int) -> String {
        let names = ["初爻", "二爻", "三爻", "四爻", "五爻", "上爻"]
        return names[min(max(index, 0), names.count - 1)]
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

private struct CoinView: View {
    let face: CoinFace
    let spinAngle: Double
    let dropProgress: Double
    let horizontalJitter: CGFloat
    let cinnabar: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: coinColors,
                        center: .topLeading,
                        startRadius: 3,
                        endRadius: 38
                    )
                )

            Circle()
                .strokeBorder(Color.black.opacity(0.18), lineWidth: 1)

            Circle()
                .strokeBorder(Color.white.opacity(0.34), lineWidth: 1)
                .padding(7)

            RoundedRectangle(cornerRadius: 2)
                .fill(Color.black.opacity(0.18))
                .frame(width: 15, height: 15)
                .overlay {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
        }
        .frame(width: 58, height: 58)
        .offset(
            x: horizontalJitter * (1 - dropProgress),
            y: -68 * (1 - dropProgress)
        )
        .scaleEffect(0.82 + 0.18 * dropProgress)
        .opacity(0.18 + 0.82 * dropProgress)
        .blur(radius: 1.2 * (1 - dropProgress))
        .rotation3DEffect(.degrees(spinAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.72)
        .shadow(color: Color.black.opacity(0.13), radius: 12, y: 7)
        .accessibilityLabel(face == .heads ? "铜钱正面" : "铜钱背面")
    }

    private var coinColors: [Color] {
        switch face {
        case .heads:
            [
                Color(red: 0.83, green: 0.63, blue: 0.33),
                Color(red: 0.55, green: 0.36, blue: 0.18),
                Color(red: 0.32, green: 0.21, blue: 0.12)
            ]
        case .tails:
            [
                Color(red: 0.66, green: 0.50, blue: 0.31),
                Color(red: 0.40, green: 0.31, blue: 0.22),
                cinnabar.opacity(0.75)
            ]
        }
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
        .frame(maxWidth: isResultStyle ? 230 : nil)
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
