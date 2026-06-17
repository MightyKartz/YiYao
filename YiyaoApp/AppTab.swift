import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case casting
    case history
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .casting:
            "起卦"
        case .history:
            "历史"
        case .settings:
            "设置"
        }
    }

    var navigationTitle: String {
        switch self {
        case .casting:
            "一爻"
        case .history:
            "历史"
        case .settings:
            "设置"
        }
    }

    var systemImage: String {
        switch self {
        case .casting:
            "circle.hexagongrid"
        case .history:
            "book.closed"
        case .settings:
            "gearshape"
        }
    }

    var accessibilityIdentifier: String {
        "tab.\(rawValue)"
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .casting:
            CastingHomeView()
        case .history:
            HistoryView()
        case .settings:
            SettingsView()
        }
    }

    var label: some View {
        Label(title, systemImage: systemImage)
    }
}
