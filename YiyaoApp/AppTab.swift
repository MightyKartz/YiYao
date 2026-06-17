import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case casting
    case library
    case journal
    case learning
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .casting:
            "起卦"
        case .library:
            "卦库"
        case .journal:
            "记录"
        case .learning:
            "学习"
        case .settings:
            "设置"
        }
    }

    var systemImage: String {
        switch self {
        case .casting:
            "circle.hexagongrid"
        case .library:
            "books.vertical"
        case .journal:
            "book.closed"
        case .learning:
            "leaf"
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
        case .library:
            HexagramLibraryView()
        case .journal:
            JournalView()
        case .learning:
            LearningView()
        case .settings:
            SettingsView()
        }
    }

    var label: some View {
        Label(title, systemImage: systemImage)
    }
}
