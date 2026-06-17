import SwiftUI

enum SettingsCopy {
    static let privacyBody = LocalOnlyPolicy.privacyBody
    static let disclaimerBody = LocalOnlyPolicy.disclaimerBody
}

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isShowingClearConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SettingsPanel(title: "本机自守", message: SettingsCopy.privacyBody)
                SettingsPanel(title: "卦象边界", message: SettingsCopy.disclaimerBody)

                VStack(alignment: .leading, spacing: 12) {
                    Text("旧录")
                        .font(.system(.headline, design: .serif))

                    Button(role: .destructive) {
                        isShowingClearConfirmation = true
                    } label: {
                        HStack {
                            Text("清去本机旧录")
                                .font(.system(.body, design: .serif))
                            Spacer()
                            Image(systemName: "trash")
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(YiyaoPalette.cinnabar(colorScheme).opacity(colorScheme == .dark ? 0.16 : 0.08))
                        .foregroundStyle(YiyaoPalette.cinnabar(colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(YiyaoPalette.cinnabar(colorScheme).opacity(colorScheme == .dark ? 0.34 : 0.20))
                        }
                    }
                    .buttonStyle(.plain)
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
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(paperBackground)
        .confirmationDialog("清去本机旧录", isPresented: $isShowingClearConfirmation) {
            Button("清去", role: .destructive) {}
            Button("取消", role: .cancel) {}
        } message: {
            Text("当前版本尚无已保存旧录。")
        }
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
}

#Preview {
    NavigationStack {
        SettingsView()
            .navigationTitle("设置")
    }
}

private struct SettingsPanel: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(YiyaoPalette.ink(colorScheme))
            Text(message)
                .font(.callout)
                .foregroundStyle(YiyaoPalette.secondaryInk(colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background {
            SettingsPanelSurface()
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(YiyaoPalette.panelBorder(colorScheme))
        }
    }
}

private struct SettingsPanelSurface: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
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
}
