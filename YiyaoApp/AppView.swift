import SwiftUI

struct AppView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: AppTab = .casting

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    NavigationStack {
                        tab.content
                            .navigationTitle(tab.navigationTitle)
                            .toolbar(.hidden, for: .navigationBar)
                            .toolbar(.hidden, for: .tabBar)
                    }
                    .tabItem { tab.label }
                    .tag(tab)
                    .accessibilityIdentifier(tab.accessibilityIdentifier)
                }
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .tint(YiyaoPalette.tabTint(colorScheme))
        .safeAreaInset(edge: .bottom) {
            YiYaoBottomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .background(YiyaoPalette.paperBase(colorScheme).ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

#Preview {
    AppView()
}

private struct YiYaoBottomTabBar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(
                                .system(size: 21, weight: selectedTab == tab ? .semibold : .regular)
                            )
                            .frame(width: 28, height: 24)
                        Text(tab.title)
                            .font(.custom("SongtiSC-Regular", size: 12, relativeTo: .caption))
                            .fontWeight(selectedTab == tab ? .medium : .regular)
                    }
                    .foregroundStyle(
                        selectedTab == tab
                            ? YiyaoPalette.grayGreen(colorScheme)
                            : YiyaoPalette.ink(colorScheme).opacity(0.74)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityIdentifier(tab.accessibilityIdentifier)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            Image("BottomNavCapsule")
                .resizable(
                    capInsets: EdgeInsets(top: 30, leading: 64, bottom: 30, trailing: 64),
                    resizingMode: .stretch
                )
                .opacity(0.98)
                .accessibilityHidden(true)
        }
        .shadow(color: Color(red: 0.34, green: 0.31, blue: 0.22).opacity(0.10), radius: 14, y: 6)
    }
}

enum YiyaoPalette {
    static func paperBase(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.12, green: 0.155, blue: 0.14)
            : Color(red: 0.965, green: 0.946, blue: 0.90)
    }

    static func paperWash(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.16, green: 0.22, blue: 0.19)
            : Color(red: 0.76, green: 0.82, blue: 0.76)
    }

    static func panelBase(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.16, green: 0.20, blue: 0.175)
            : Color(red: 0.995, green: 0.982, blue: 0.94)
    }

    static func panelBorder(_ colorScheme: ColorScheme) -> Color {
        grayGreen(colorScheme).opacity(colorScheme == .dark ? 0.24 : 0.18)
    }

    static func ink(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.88, green: 0.90, blue: 0.84)
            : Color(red: 0.16, green: 0.22, blue: 0.19)
    }

    static func secondaryInk(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.68, green: 0.74, blue: 0.68)
            : Color(red: 0.40, green: 0.47, blue: 0.42)
    }

    static func grayGreen(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.56, green: 0.70, blue: 0.63)
            : Color(red: 0.28, green: 0.38, blue: 0.32)
    }

    static func cinnabar(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.78, green: 0.32, blue: 0.26)
            : Color(red: 0.56, green: 0.14, blue: 0.10)
    }

    static func tabTint(_ colorScheme: ColorScheme) -> Color {
        grayGreen(colorScheme)
    }
}
