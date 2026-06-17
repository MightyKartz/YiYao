import SwiftUI

struct AppView: View {
    @State private var selectedTab: AppTab = .casting

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tab.content
                        .navigationTitle(tab.title)
                }
                .tabItem { tab.label }
                .tag(tab)
                .accessibilityIdentifier(tab.accessibilityIdentifier)
            }
        }
    }
}

#Preview {
    AppView()
}
