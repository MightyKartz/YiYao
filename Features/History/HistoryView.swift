import SwiftUI

struct HistoryView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 10) {
                    Capsule()
                        .fill(YiyaoPalette.cinnabar(colorScheme).opacity(colorScheme == .dark ? 0.78 : 0.70))
                        .frame(width: 28, height: 3)
                        .accessibilityHidden(true)

                    Text("尚无旧录")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(ink)

                    Text("成卦之后，可留作日后复看；所记只存于本机。")
                        .font(.callout)
                        .foregroundStyle(secondaryInk)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 42)
                .padding(.horizontal, 24)
                .background {
                    panelSurface
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(panelBorder)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .background(paperBackground)
    }

    private var paperBackground: some View {
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

    private var panelSurface: some View {
        ZStack {
            YiyaoPalette.panelBase(colorScheme)

            Image("PaperPanelTexture")
                .resizable()
                .scaledToFill()
                .opacity(colorScheme == .dark ? 0.10 : 0.22)
                .blendMode(colorScheme == .dark ? .softLight : .multiply)
                .accessibilityHidden(true)
        }
    }

    private var panelBorder: Color {
        YiyaoPalette.panelBorder(colorScheme)
    }

    private var ink: Color {
        YiyaoPalette.ink(colorScheme)
    }

    private var secondaryInk: Color {
        YiyaoPalette.secondaryInk(colorScheme)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .navigationTitle("历史")
    }
}
