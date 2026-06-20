import SwiftUI
import UIKit

struct CastingHomeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    @State private var question = ""
    @State private var isCasting = false
    @State private var didPrepareCasting = false
    @State private var revealedLineCount = 0
    @State private var activeThrowIndex = 0
    @State private var coinAnimationFrame = 0
    @State private var isCoinFlipAnimating = false
    @State private var coinDropProgress = 1.0
    @State private var currentCoinFaces: [CoinFace] = [.heads, .tails, .heads]
    @State private var castingResult: CastingResult?

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 10) {
                        header
                        questionEditor
                        castButton
                        coinCeremonyStage
                        hexagramStage
                            .id(CastingScrollTarget.result)
                        if hasCompletedCasting {
                            resultCompletionStatus
                            analysisPanel
                                .id(CastingScrollTarget.analysis)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            Color.clear
                                .frame(height: 1)
                                .id(CastingScrollTarget.analysisBottomSpacer)
                        }

                    }
                    .frame(width: max(0, geometry.size.width - 40), alignment: .top)
                    .frame(
                        minHeight: max(0, geometry.size.height - 96),
                        alignment: .top
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .scrollContentBackground(.hidden)
                .onChange(of: isCasting) { _, newValue in
                    guard !newValue, hasCompletedCasting else {
                        return
                    }
                    scrollToCompletedReading(in: scrollProxy)
                }
                .background(appBackground)
            }
        }
        .background(appBackground)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("一事在心")
                .font(OracleTypeface.title(29))
                .foregroundStyle(ink)

            Text("缓书其事，静观其变。")
                .font(OracleTypeface.body(15))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 0)
    }

    private var questionEditor: some View {
        TextField("可书一事，亦可默问。", text: $question, axis: .vertical)
            .lineLimit(3...5)
            .textFieldStyle(.plain)
            .font(OracleTypeface.body(16))
            .tint(cinnabar)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
            .accessibilityLabel("所书之事")
            .accessibilityHint("可书一事，亦可默问。")
            .accessibilityIdentifier("casting.question")
            .background {
                questionPanelSurface
            }
    }

    private var castButton: some View {
        Button {
            beginCasting()
        } label: {
            ZStack {
                Color.clear

                ZStack {
                    castButtonSurface

                    HStack(spacing: 9) {
                        Text(isCasting ? "铜钱将落" : didPrepareCasting ? "再取一卦" : "三钱取卦")
                            .font(OracleTypeface.headline(18))
                            .foregroundStyle(canCast ? actionText : .secondary)

                        Image("CastingButtonDot")
                            .resizable()
                            .antialiased(true)
                            .scaledToFit()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 10, height: 10)
                            .opacity(canCast ? 1 : 0.42)
                            .accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .padding(.horizontal, 44)
                }
                .frame(maxWidth: 318)
                .frame(height: 46)
                .shadow(color: actionShadow, radius: 5, y: 2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(CeremonialPressButtonStyle())
        .disabled(!canCast)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .animation(.easeOut(duration: 0.16), value: canCast)
        .accessibilityLabel(isCasting ? "铜钱将落" : didPrepareCasting ? "再取一卦" : "三钱取卦")
        .accessibilityIdentifier("casting.castButton")
        .accessibilityHint("以三枚铜钱生成六爻。")
    }

    private var coinCeremonyStage: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack {
                HStack {
                    coinCloud
                        .frame(width: 34, height: 15)
                        .opacity(0.56)
                    Spacer()
                    coinCloud
                        .scaleEffect(x: -1)
                        .frame(width: 34, height: 15)
                        .opacity(0.56)
                }
                .padding(.horizontal, 22)

                GeometryReader { proxy in
                    let coinSize = min(CGFloat(96), max(CGFloat(76), (proxy.size.width - 62) / 3))
                    let spacing = min(CGFloat(18), max(CGFloat(10), (proxy.size.width - coinSize * 3) / 4))

                    HStack(spacing: spacing) {
                        ForEach(Array(currentCoinFaces.enumerated()), id: \.offset) { index, face in
                            CoinView(
                                face: face,
                                animationFrame: (coinAnimationFrame + index * 4) % 16,
                                dropProgress: coinDropProgress,
                                horizontalJitter: coinJitter(for: index),
                                isAnimating: isCoinFlipAnimating,
                                size: coinSize
                            )
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 82)

            Text(isCasting ? "正反流转，逐爻落定。" : "三枚铜钱常驻于此，取卦后逐爻落定。")
                .font(OracleTypeface.caption(12))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 1)
        .frame(maxWidth: .infinity)
    }

    private var hexagramStage: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("本卦")
                        .font(OracleTypeface.headline(16))
                        .foregroundStyle(resultPrimaryText)

                    Text(hasCompletedCasting ? originalStructureText : "六爻待成")
                        .font(OracleTypeface.caption(11))
                        .foregroundStyle(resultSecondaryText)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(YiyaoPalette.paperWash(colorScheme).opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 5) {
                    Text("变爻")
                        .font(OracleTypeface.caption(11))
                        .foregroundStyle(resultSecondaryText)
                    HStack(spacing: 5) {
                        Text(movingLinesBadgeText)
                            .font(OracleTypeface.caption(11))
                            .foregroundStyle(resultPrimaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                        Circle()
                            .fill(cinnabar)
                            .frame(width: 7, height: 7)
                            .opacity(
                                hasCompletedCasting && !castingMovingLineNumbers.isEmpty
                                    ? 0.9 : 0.24)
                    }
                }
            }

            HStack(alignment: .center, spacing: 12) {
                Spacer(minLength: 0)

                HexagramPreviewView(
                    lines: displayLines,
                    revealedLineCount: previewRevealedLineCount,
                    movingColor: cinnabar,
                    stableColor: hasCompletedCasting
                        ? resultLineColor : resultLineColor.opacity(0.70),
                    isResultStyle: true
                )
                .frame(width: 148)
                .padding(.vertical, 0)
                .sensoryFeedback(.selection, trigger: revealedLineCount)

                Spacer(minLength: 2)

                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(displayLines.enumerated().reversed()), id: \.offset) {
                        index, line in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(line.isChanging ? cinnabar : resultLineColor.opacity(0.24))
                                .frame(width: 4.5, height: 4.5)
                                .opacity(index < previewRevealedLineCount ? 1 : 0.24)
                            Text(linePositionName(for: index, line: line))
                                .font(OracleTypeface.caption(10.5))
                                .foregroundStyle(line.isChanging ? cinnabar : resultSecondaryText)
                        }
                        .opacity(index < previewRevealedLineCount ? 1 : 0.36)
                    }
                }
                .frame(width: 44, alignment: .leading)
                .padding(.vertical, 4)
                .padding(.horizontal, 5)

                Spacer(minLength: 0)
            }

        }
        .padding(.horizontal, 24)
        .padding(.top, 15)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 176, alignment: .topLeading)
        .background {
            oraclePanelFrameSurface
        }
        .animation(.easeInOut(duration: 0.32), value: didPrepareCasting)
        .animation(.easeInOut(duration: 0.32), value: isCasting)
    }

    private var analysisPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("卦意初读")
                .font(OracleTypeface.headline(15.5))

            Text("本卦：\(originalStructureText)。动爻：\(movingLinesText)。")
                .font(OracleTypeface.body(12.5))
                .foregroundStyle(resultPrimaryText.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            Text("此处只作周易学习与自我反思的线索，不作确定判断。")
                .font(OracleTypeface.caption(11.5))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22)
        .padding(.top, 13)
        .padding(.bottom, 11)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .background {
            analysisPanelFrameSurface
        }
    }

    private var resultCompletionStatus: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("卦象已成")
                .font(OracleTypeface.headline(16))
                .foregroundStyle(resultPrimaryText)

            Text(resultTrigramSummary)
                .font(OracleTypeface.caption(11.5))
                .foregroundStyle(resultSecondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 0)
        .padding(.bottom, 1)
    }

    private var canCast: Bool {
        !isCasting
    }

    private var hasCompletedCasting: Bool {
        didPrepareCasting && !isCasting
    }

    private var appBackground: some View {
        ZStack {
            YiyaoPalette.paperBase(colorScheme)

            Image("PaperInkBackground")
                .resizable()
                .scaledToFill()
                .opacity(colorScheme == .dark ? 0.22 : 0.72)
                .blendMode(colorScheme == .dark ? .softLight : .multiply)
                .accessibilityHidden(true)

            YiyaoPalette.paperWash(colorScheme)
                .opacity(colorScheme == .dark ? 0.34 : 0.10)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var castButtonSurface: some View {
        if canCast {
            Image("CastingButtonFrame")
                .resizable(
                    capInsets: EdgeInsets(top: 23, leading: 58, bottom: 23, trailing: 58),
                    resizingMode: .stretch
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .saturation(0.48)
                .opacity(0.96)
                .accessibilityHidden(true)
        } else {
            Image("CastingButtonFrame")
                .resizable(
                    capInsets: EdgeInsets(top: 23, leading: 58, bottom: 23, trailing: 58),
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
        GeometryReader { proxy in
            Image("OracleHexagramAreaBorder")
                .resizable(
                    capInsets: EdgeInsets(top: 42, leading: 54, bottom: 42, trailing: 54),
                    resizingMode: .stretch
                )
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .saturation(0.34)
                .opacity(0.62)
                .accessibilityHidden(true)
        }
    }

    private var questionPanelSurface: some View {
        GeometryReader { proxy in
            Image("OracleInputPanelFrame")
                .resizable(
                    capInsets: EdgeInsets(top: 35, leading: 48, bottom: 38, trailing: 48),
                    resizingMode: .stretch
                )
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .saturation(0.48)
                .opacity(0.92)
                .accessibilityHidden(true)
        }
    }

    private var analysisPanelFrameSurface: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                Image("OracleAnalysisLandscapeWash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(210, proxy.size.width * 0.56))
                    .opacity(0.22)
                    .padding(.trailing, 2)
                    .padding(.bottom, 3)
                    .accessibilityHidden(true)

                Image("OracleAnalysisAreaBorder")
                    .resizable(
                        capInsets: EdgeInsets(top: 42, leading: 54, bottom: 42, trailing: 54),
                        resizingMode: .stretch
                    )
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .saturation(0.34)
                    .opacity(0.62)
                    .accessibilityHidden(true)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var coinCloud: some View {
        Image("TinyCloudOrnament")
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
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
        return
            "上\(castingResult.upperTrigram.name)下\(castingResult.lowerTrigram.name)，\(castingResult.upperTrigram.imageName)\(castingResult.lowerTrigram.imageName)相承"
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
        return
            "上\(castingResult.changedUpperTrigram.name)下\(castingResult.changedLowerTrigram.name)"
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
        return
            movingLineNumbers
            .map { linePositionName(for: $0 - 1, line: displayLines[$0 - 1]) }
            .joined(separator: "、")
    }

    private var movingLinesBadgeText: String {
        guard hasCompletedCasting else {
            return "待定"
        }
        let movingLineNumbers = castingMovingLineNumbers
        guard !movingLineNumbers.isEmpty else {
            return "无"
        }
        guard movingLineNumbers.count == 1, let lineNumber = movingLineNumbers.first else {
            return "\(movingLineNumbers.count)爻动"
        }
        return linePositionName(for: lineNumber - 1, line: displayLines[lineNumber - 1])
    }

    private func coinJitter(for index: Int) -> CGFloat {
        [-14, 0, 10][index]
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
        coinAnimationFrame = 0
        isCoinFlipAnimating = false

        guard !reduceMotion else {
            currentCoinFaces = result.coinThrows.last?.faces ?? currentCoinFaces
            isCoinFlipAnimating = false
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
                coinAnimationFrame = 0
                isCoinFlipAnimating = true
            }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.54)) {
                    coinDropProgress = 1
                }
            }

            for frame in 1..<16 {
                try? await Task.sleep(nanoseconds: 36_000_000)
                await MainActor.run {
                    coinAnimationFrame = frame
                }
            }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.16)) {
                    currentCoinFaces = throwSnapshot[index].faces
                    coinAnimationFrame = 0
                    isCoinFlipAnimating = false
                }
            }

            try? await Task.sleep(nanoseconds: 320_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.38)) {
                    revealedLineCount = index + 1
                }
            }

            try? await Task.sleep(nanoseconds: 240_000_000)
        }

        await MainActor.run {
            coinAnimationFrame = 0
            isCoinFlipAnimating = false
            isCasting = false
        }
    }

    private func scrollToCompletedReading(in proxy: ScrollViewProxy) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: reduceMotion ? 80_000_000 : 220_000_000)
            withAnimation(.easeInOut(duration: reduceMotion ? 0.01 : 0.48)) {
                proxy.scrollTo(CastingScrollTarget.analysisBottomSpacer, anchor: .bottom)
            }
        }
    }
}

private enum CastingScrollTarget {
    static let result = "casting.result"
    static let analysis = "casting.analysis"
    static let analysisBottomSpacer = "casting.analysisBottomSpacer"
}

private enum OracleTypeface {
    private static let regularName = firstAvailableFont([
        "KaitiSC-Regular",
        "Kaiti SC Regular",
        "Kaiti SC",
        "STKaiti",
        "STKaiti-SC-Regular",
        "SongtiSC-Regular",
        "STSongti-SC-Regular",
        "Songti SC Regular",
    ])
    private static let boldName = firstAvailableFont([
        "KaitiSC-Bold",
        "Kaiti SC Bold",
        "STKaiti-SC-Bold",
        "KaitiSC-Regular",
        "Kaiti SC Regular",
        "SongtiSC-Bold",
        "STSongti-SC-Bold",
        "Songti SC Bold",
    ])
    private static let lightName = firstAvailableFont([
        "KaitiSC-Regular",
        "Kaiti SC Regular",
        "STKaiti",
        "SongtiSC-Light",
        "STSongti-SC-Light",
        "Songti SC Light",
    ])

    static func title(_ size: CGFloat) -> Font {
        make(regularName ?? boldName, size: size, relativeTo: .title, fallbackWeight: .medium)
    }

    static func headline(_ size: CGFloat) -> Font {
        make(regularName ?? boldName, size: size, relativeTo: .headline, fallbackWeight: .regular)
    }

    static func body(_ size: CGFloat) -> Font {
        make(regularName, size: size, relativeTo: .body, fallbackWeight: .regular)
    }

    static func caption(_ size: CGFloat) -> Font {
        make(lightName ?? regularName, size: size, relativeTo: .caption, fallbackWeight: .regular)
    }

    private static func make(
        _ name: String?,
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle,
        fallbackWeight: Font.Weight
    ) -> Font {
        guard let name else {
            return .system(size: size, weight: fallbackWeight, design: .serif)
        }
        return .custom(name, size: size, relativeTo: textStyle)
    }

    private static func firstAvailableFont(_ names: [String]) -> String? {
        names.first { UIFont(name: $0, size: 16) != nil }
    }
}

private struct InputPanelChrome: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(YiyaoPalette.grayGreen(colorScheme).opacity(0.34), lineWidth: 1)
            }
    }
}

private struct CeremonialPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
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
    let face: CoinFace
    let animationFrame: Int
    let dropProgress: Double
    let horizontalJitter: CGFloat
    let isAnimating: Bool
    let size: CGFloat

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .contentShape(Rectangle())
            .saturation(0.95)
            .offset(
                x: horizontalJitter * (1 - dropProgress),
                y: -48 * (1 - dropProgress)
            )
            .scaleEffect(0.90 + 0.10 * dropProgress)
            .opacity(0.34 + 0.66 * dropProgress)
            .blur(radius: 0.6 * (1 - dropProgress))
            .shadow(color: coinShadow, radius: 8, y: 4)
            .accessibilityLabel(face == .heads ? "铜钱正面" : "铜钱背面")
    }

    private var imageName: String {
        if isAnimating {
            return Self.animationFrameNames[animationFrame % Self.animationFrameNames.count]
        }
        return face == .heads ? "CoinRollFrame00" : "CoinRollFrame08"
    }

    private var coinShadow: Color {
        Color(red: 0.31, green: 0.25, blue: 0.16).opacity(0.12)
    }

    private static let animationFrameNames = [
        "CoinRollFrame00",
        "CoinRollFrame01",
        "CoinRollFrame02",
        "CoinRollFrame03",
        "CoinRollFrame04",
        "CoinRollFrame05",
        "CoinRollFrame06",
        "CoinRollFrame07",
        "CoinRollFrame08",
        "CoinRollFrame09",
        "CoinRollFrame10",
        "CoinRollFrame11",
        "CoinRollFrame12",
        "CoinRollFrame13",
        "CoinRollFrame14",
        "CoinRollFrame15",
    ]
}

private struct HexagramPreviewView: View {
    let lines: [LineValue]
    let revealedLineCount: Int
    let movingColor: Color
    let stableColor: Color
    let isResultStyle: Bool

    var body: some View {
        VStack(spacing: isResultStyle ? 7 : 11) {
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
        .frame(height: isResultStyle ? 7 : 9)
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
                .font(OracleTypeface.body(16))
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
